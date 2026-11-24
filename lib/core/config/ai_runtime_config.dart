import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/app_logger.dart';

abstract interface class AiCredentialSource {
  Future<String> requireLightxApiKey();

  Future<String> refreshLightxApiKey();
}

/// Loads AI runtime configuration from Firebase Remote Config.
///
/// The `gilmora` parameter contains JSON. The LightX credential is cached in
/// Android encrypted storage so transient Remote Config failures do not make
/// the app unusable. The credential is printed only in debug builds after a
/// successful Firebase fetch to make development configuration easy to verify.
class AiRuntimeConfig implements AiCredentialSource {
  AiRuntimeConfig._();

  static final AiRuntimeConfig instance = AiRuntimeConfig._();

  static const String _remoteParameter = 'gilmora';
  static const String _lightxJsonField = 'lightxkey';
  static const String _lightxStorageKey = 'lightx_api_key';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  bool _firebaseReady = false;
  Future<void>? _initialization;
  Future<void>? _fetchInFlight;

  Future<void> initialize() {
    return _initialization ??= _initializeOnce();
  }

  Future<void> _initializeOnce() async {
    _debug('Initializing Firebase-backed AI runtime configuration');
    if (kIsWeb || !Platform.isAndroid) {
      AppLogger.info(
          'Firebase AI config is currently enabled for Android only');
      return;
    }

    try {
      await _ensureFirebaseReady();
      unawaited(_warmRemoteConfig());
      AppLogger.info('AI runtime configuration initialized');
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Firebase initialization failed; cached AI config will be used',
        error,
        stackTrace,
      );
    }
  }

  @override
  Future<String> requireLightxApiKey() async {
    final cached = await _storage.read(key: _lightxStorageKey);
    if (cached != null && cached.trim().isNotEmpty) {
      _debug('Using LightX API key from secure storage');
      return cached.trim();
    }

    _debug('No cached LightX API key found; fetching Remote Config');
    await _ensureFirebaseReady();
    await _fetchAndCache();

    return _readCachedKey();
  }

  @override
  Future<String> refreshLightxApiKey() async {
    _debug('Forcing LightX API key refresh from Remote Config');
    await _ensureFirebaseReady();
    await _fetchAndCache(force: true);
    return _readCachedKey();
  }

  Future<String> _readCachedKey() async {
    final cached = await _storage.read(key: _lightxStorageKey);
    if (cached == null || cached.trim().isEmpty) {
      throw const FormatException(
        'AI service configuration is unavailable. Please try again later.',
      );
    }
    return cached.trim();
  }

  Future<void> _ensureFirebaseReady() async {
    if (_firebaseReady) {
      _debug('Firebase is already initialized');
      return;
    }
    if (kIsWeb || !Platform.isAndroid) {
      throw const FormatException(
        'AI service configuration is available on Android only.',
      );
    }

    _debug('Initializing Firebase');
    await Firebase.initializeApp();
    _firebaseReady = true;
    _debug('Firebase initialized successfully');
  }

  Future<void> _warmRemoteConfig() async {
    try {
      await _fetchAndCache();
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Remote AI config refresh failed; cached config will be used',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _fetchAndCache({bool force = false}) {
    final activeFetch = _fetchInFlight;
    if (activeFetch != null) {
      _debug('Joining the Remote Config fetch already in progress');
      return activeFetch;
    }

    final fetch = _doFetchAndCache(force: force);
    _fetchInFlight = fetch;
    return fetch.whenComplete(() {
      if (identical(_fetchInFlight, fetch)) _fetchInFlight = null;
    });
  }

  Future<void> _doFetchAndCache({required bool force}) async {
    _debug('Fetching Firebase Remote Config parameter "$_remoteParameter" '
        '(force: $force)');
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval:
            force || kDebugMode ? Duration.zero : const Duration(hours: 12),
      ),
    );
    final activated = await remoteConfig.fetchAndActivate();
    _debug('Remote Config fetch completed (new values activated: $activated)');

    final rawConfig = remoteConfig.getString(_remoteParameter).trim();
    if (rawConfig.isEmpty) {
      throw const FormatException('Remote AI configuration is empty.');
    }

    final lightxKey = parseLightxApiKey(rawConfig);

    // Deliberately requested for development diagnostics. Never emit the
    // credential from profile or release builds.
    if (kDebugMode) {
      AppLogger.debug(
        'Firebase Remote Config LightX key fetched: $lightxKey',
      );
    }

    await _storage.write(
      key: _lightxStorageKey,
      value: lightxKey,
    );
    _debug('Fetched LightX API key saved to secure storage');
  }

  void _debug(String message) {
    if (kDebugMode) AppLogger.debug('[AiRuntimeConfig] $message');
  }

  @visibleForTesting
  static String parseLightxApiKey(String rawConfig) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(rawConfig);
    } on FormatException {
      throw const FormatException('Remote AI configuration must be JSON.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Remote AI configuration must be JSON.');
    }

    final lightxKey = decoded[_lightxJsonField];
    if (lightxKey is! String || lightxKey.trim().isEmpty) {
      throw const FormatException('Remote AI configuration is incomplete.');
    }
    return lightxKey.trim();
  }
}
