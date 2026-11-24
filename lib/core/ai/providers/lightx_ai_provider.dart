import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show compute, kDebugMode;
import 'package:image/image.dart' as image_lib;

import '../../config/ai_runtime_config.dart';
import '../../utils/app_logger.dart';
import '../../utils/image_compressor.dart';
import '../ai_image_provider.dart';

class LightxAiProvider implements AiImageProvider {
  LightxAiProvider({
    required AiCredentialSource config,
    Dio? dio,
    Duration pollInterval = defaultPollInterval,
    Duration pollTimeout = defaultPollTimeout,
  })  : _config = config,
        _pollInterval = pollInterval,
        _pollTimeout = pollTimeout,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _baseUrl,
                connectTimeout: const Duration(seconds: 120),
                sendTimeout: const Duration(seconds: 180),
                receiveTimeout: const Duration(seconds: 180),
                responseType: ResponseType.json,
              ),
            );

  static const String _baseUrl = 'https://api.lightxeditor.com/external/api/v2';
  static const int _maxUploadBytes = 5 * 1024 * 1024;
  static const Duration defaultPollInterval = Duration(seconds: 8);
  static const Duration defaultPollTimeout = Duration(minutes: 5);

  final AiCredentialSource _config;
  final Dio _dio;
  final Duration _pollInterval;
  final Duration _pollTimeout;

  @override
  Future<String> changeOutfit({
    required File image,
    required String prompt,
  }) async {
    final normalizedPrompt = _normalizedPrompt(prompt);
    final imageUrl = await _uploadFile(image);
    return _createAndAwait('/outfit', {
      'imageUrl': imageUrl,
      'textPrompt': normalizedPrompt,
    });
  }

  @override
  Future<String> applyFilter({
    required File image,
    required String prompt,
    String? referenceImageUrl,
  }) async {
    final normalizedPrompt = _normalizedPrompt(prompt);
    final imageUrl = await _uploadFile(image);
    final payload = <String, dynamic>{
      'imageUrl': imageUrl,
      'textPrompt': normalizedPrompt,
    };

    if (referenceImageUrl != null && referenceImageUrl.trim().isNotEmpty) {
      payload['filterReferenceUrl'] =
          await _uploadRemoteImage(referenceImageUrl.trim());
    }

    return _createAndAwait('/aifilter', payload);
  }

  @override
  Future<String> textToImage({
    required String prompt,
    String resolution = '1:1',
    bool enhancePrompt = true,
  }) {
    const supportedResolutions = {'1:1', '9:16', '3:4', '2:3', '16:9', '4:3'};
    if (!supportedResolutions.contains(resolution)) {
      throw const AiProviderException('Unsupported image resolution.');
    }
    return _createAndAwait('/text2image', {
      'textPrompt': _normalizedPrompt(prompt),
      'resolution': resolution,
      'enhancePrompt': enhancePrompt,
    });
  }

  @override
  Future<String> imageToImage({
    required File image,
    required String prompt,
  }) async {
    final normalizedPrompt = _normalizedPrompt(prompt);
    final imageUrl = await _uploadFile(image);
    return _createAndAwait('/image2image/', {
      'imageUrl': imageUrl,
      'textPrompt': normalizedPrompt,
    });
  }

  @override
  Future<String> changeHairstyle({
    required File image,
    required String prompt,
  }) async {
    final normalizedPrompt = _normalizedPrompt(prompt);
    final imageUrl = await _uploadFile(image);
    return _createAndAwait('/hairstyle', {
      'imageUrl': imageUrl,
      'textPrompt': normalizedPrompt,
    });
  }

  @override
  Future<String> upscale({
    required File image,
    int quality = 2,
  }) async {
    if (quality != 2 && quality != 4) {
      throw const AiProviderException('Upscale quality must be 2x or 4x.');
    }
    final imageUrl = await _uploadFile(image);
    return _createAndAwait('/upscale/', {
      'imageUrl': imageUrl,
      'quality': quality,
    });
  }

  @override
  Future<BackgroundRemovalResult> removeBackground({
    required File image,
  }) async {
    final imageUrl = await _uploadFile(image);
    final body = await _createAndAwaitBody('/remove-background', {
      'imageUrl': imageUrl,
      'background': 'transparent',
    });

    return BackgroundRemovalResult(
      imageUrl: _extractOutput(body),
      maskUrl: body['mask'] is String ? body['mask'] as String : null,
    );
  }

  @override
  Future<String> generateBackground({
    required String imageUrl,
    required String prompt,
  }) async {
    final normalizedPrompt = _normalizedPrompt(prompt);
    final uploadedUrl = await _uploadRemoteImage(imageUrl);
    return _createAndAwait('/background-generator', {
      'imageUrl': uploadedUrl,
      'textPrompt': normalizedPrompt,
    });
  }

  @override
  Future<String> createHeadshot({
    required File image,
    required String prompt,
  }) async {
    final normalizedPrompt = _normalizedPrompt(prompt);
    final imageUrl = await _uploadFile(image);
    return _createAndAwait('/headshot/', {
      'imageUrl': imageUrl,
      'textPrompt': normalizedPrompt,
    });
  }

  Future<String> _uploadFile(File source) async {
    try {
      _debug('Preparing local image for LightX upload');
      final prepared = await ImageCompressor.compress(
        source,
        maxSizeBytes: _maxUploadBytes,
        forceJpeg: true,
      );
      final bytes = await prepared.readAsBytes();
      final normalizedBytes = await compute(_normalizeLightxJpeg, bytes);
      _debug('Image prepared (${normalizedBytes.length} bytes)');
      return _uploadBytes(normalizedBytes, 'image/jpeg');
    } on AiProviderException {
      rethrow;
    } on FormatException catch (error) {
      throw AiProviderException(error.message);
    } catch (error, stackTrace) {
      AppLogger.error('Input image preparation failed', error, stackTrace);
      throw const AiProviderException(
        'The selected image could not be processed. Please choose another image.',
      );
    }
  }

  Future<String> _uploadRemoteImage(String sourceUrl) async {
    try {
      _debug('Downloading reference image');
      final validatedSourceUrl = _validatedHttpsUrl(
        sourceUrl,
        'The reference image URL is invalid.',
      );
      final response = await _dio.get<List<int>>(
        validatedSourceUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        throw const AiProviderException('Could not load the reference image.');
      }
      if (data.length > _maxUploadBytes) {
        throw const AiProviderException(
          'The reference image is larger than 5 MB.',
        );
      }
      final supportedType = _detectImageContentType(data);
      if (supportedType == null) {
        throw const AiProviderException(
          'The reference image format is unsupported.',
        );
      }
      _debug('Reference image downloaded (${data.length} bytes, '
          '$supportedType)');
      return _uploadBytes(Uint8List.fromList(data), supportedType);
    } on AiProviderException {
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.error('Reference image download failed', error, stackTrace);
      throw const AiProviderException('Could not load the reference image.');
    }
  }

  Future<String> _uploadBytes(Uint8List bytes, String contentType) async {
    if (bytes.isEmpty || bytes.length > _maxUploadBytes) {
      throw const AiProviderException(
        'Please select an image smaller than 5 MB.',
      );
    }

    _debug(
        'Requesting signed upload URL ($contentType, ${bytes.length} bytes)');
    final body = await _post('/uploadImageUrl', {
      'uploadType': 'imageUrl',
      'size': bytes.length,
      'contentType': contentType,
    });

    final uploadUrl = _validatedHttpsUrl(
      body['uploadImage'],
      'Image upload could not be prepared.',
    );
    final imageUrl = _validatedHttpsUrl(
      body['imageUrl'],
      'Image upload could not be prepared.',
    );

    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        _debug('Uploading image to signed URL (attempt ${attempt + 1}/2)');
        await _dio.put<void>(
          uploadUrl,
          data: bytes,
          options: Options(
            contentType: contentType,
            responseType: ResponseType.plain,
            headers: {'Content-Length': bytes.length},
          ),
        );
        _debug('Image upload completed');
        return imageUrl;
      } on DioException catch (error, stackTrace) {
        if (attempt == 0 && _isTransientDioError(error)) {
          _debug('Transient upload failure; retrying once');
          await Future<void>.delayed(const Duration(milliseconds: 500));
          continue;
        }
        AppLogger.error(
            'LightX image upload failed', error.message, stackTrace);
        throw const AiProviderException(
          'Image upload failed. Please try again.',
          retryable: true,
        );
      } catch (error, stackTrace) {
        AppLogger.error('LightX image upload failed', error, stackTrace);
        throw const AiProviderException(
          'Image upload failed. Please try again.',
        );
      }
    }

    throw const AiProviderException('Image upload failed. Please try again.');
  }

  Future<String> _createAndAwait(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    final body = await _createAndAwaitBody(endpoint, payload);
    return _extractOutput(body);
  }

  Future<Map<String, dynamic>> _createAndAwaitBody(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    _debug('Starting LightX generation request: $endpoint');
    final created = await _post(endpoint, payload);
    final immediateStatus = created['status'] as String?;
    _debug('LightX creation response status: ${immediateStatus ?? 'pending'}');
    if (immediateStatus == 'active') {
      _debug('LightX request completed immediately: $endpoint');
      return created;
    }
    if (immediateStatus == 'failed') {
      throw const AiProviderException('Image generation failed.');
    }

    final orderId = created['orderId'] as String?;
    if (orderId == null || orderId.isEmpty) {
      throw const AiProviderException('AI request did not return an order ID.');
    }

    // LightX can legitimately remain in `init` longer than the API-provided
    // retry hint. Keep polling on our own five-minute deadline instead.
    final pollLimit = _pollInterval == Duration.zero
        ? 100
        : (_pollTimeout.inMicroseconds ~/ _pollInterval.inMicroseconds)
            .clamp(1, 10000);
    final stopwatch = Stopwatch()..start();
    _debug('Polling LightX order $orderId every '
        '${_pollInterval.inSeconds}s for up to ${_pollTimeout.inMinutes}m '
        '(maximum $pollLimit attempts)');

    for (var attempt = 0; attempt < pollLimit; attempt++) {
      if (stopwatch.elapsed >= _pollTimeout) break;
      if (_pollInterval > Duration.zero &&
          stopwatch.elapsed + _pollInterval > _pollTimeout) {
        break;
      }
      await Future<void>.delayed(_pollInterval);
      final Map<String, dynamic> statusBody;
      try {
        statusBody = await _post('/order-status', {'orderId': orderId});
      } on AiProviderException catch (error) {
        if (!error.retryable) rethrow;
        _debug('Transient polling error on attempt ${attempt + 1}; continuing');
        continue;
      }
      final status = statusBody['status'] as String?;
      _debug('LightX order $orderId poll ${attempt + 1}/$pollLimit: '
          '${status ?? 'unknown'}');
      if (status == 'active') {
        _debug('LightX order $orderId completed');
        return statusBody;
      }
      if (status == 'failed') {
        throw const AiProviderException('Image generation failed.');
      }
    }
    stopwatch.stop();

    throw const AiProviderException(
      'Image generation timed out after 5 minutes. Please try again.',
      retryable: true,
    );
  }

  Future<Map<String, dynamic>> _post(
      String endpoint, Map<String, dynamic> payload,
      {bool allowCredentialRefresh = true}) async {
    try {
      _debug('POST $endpoint');
      final apiKey = await _config.requireLightxApiKey();
      final response = await _dio.post<dynamic>(
        endpoint,
        data: payload,
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'x-api-key': apiKey},
        ),
      );

      final data = response.data;
      if (data is! Map) {
        throw const AiProviderException(
            'AI service returned an invalid response.');
      }

      final normalized = Map<String, dynamic>.from(data);
      final statusCode = normalized['statusCode'];
      if (statusCode != 2000 && statusCode != '2000') {
        final message = normalized['message'];
        if (allowCredentialRefresh &&
            message is String &&
            _isAuthenticationMessage(message)) {
          return _refreshCredentialsAndRetry(endpoint, payload);
        }
        throw AiProviderException(
          message is String && message.isNotEmpty
              ? message
              : 'AI service request failed.',
        );
      }

      final body = normalized['body'];
      if (body is! Map) {
        throw const AiProviderException(
            'AI service returned an invalid result.');
      }
      _debug('LightX request accepted: $endpoint');
      return Map<String, dynamic>.from(body);
    } on AiProviderException {
      rethrow;
    } on DioException catch (error, stackTrace) {
      if (allowCredentialRefresh &&
          (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403)) {
        return _refreshCredentialsAndRetry(endpoint, payload);
      }
      AppLogger.error(
        'LightX request failed (${error.response?.statusCode ?? 'network'})',
        error.message,
        stackTrace,
      );
      throw _exceptionForDioError(error);
    } on FormatException catch (error) {
      throw AiProviderException(error.message);
    } catch (error, stackTrace) {
      AppLogger.error('LightX request failed', error, stackTrace);
      throw const AiProviderException('AI service is unavailable.');
    }
  }

  String _extractOutput(Map<String, dynamic> body) {
    final output = body['output'];
    if (output is String && output.isNotEmpty) {
      return _validatedHttpsUrl(
        output,
        'AI service returned an invalid output image.',
      );
    }
    if (output is List && output.isNotEmpty && output.first is String) {
      return _validatedHttpsUrl(
        output.first,
        'AI service returned an invalid output image.',
      );
    }
    throw const AiProviderException('AI service returned no output image.');
  }

  Future<Map<String, dynamic>> _refreshCredentialsAndRetry(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    try {
      _debug('LightX authentication rejected; refreshing credentials');
      await _config.refreshLightxApiKey();
      _debug('Credential refresh completed; retrying $endpoint once');
      return _post(
        endpoint,
        payload,
        allowCredentialRefresh: false,
      );
    } on FormatException catch (error) {
      throw AiProviderException(error.message);
    } catch (error, stackTrace) {
      AppLogger.warning(
        'AI credential refresh failed',
        error,
        stackTrace,
      );
      throw const AiProviderException(
        'AI service configuration could not be refreshed.',
        retryable: true,
      );
    }
  }

  AiProviderException _exceptionForDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return const AiProviderException('AI service authentication failed.');
    }
    if (statusCode == 429) {
      return const AiProviderException(
        'AI service limit reached. Please try again later.',
      );
    }
    if (statusCode != null && statusCode >= 500) {
      return const AiProviderException(
        'AI service is temporarily unavailable.',
        retryable: true,
      );
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const AiProviderException(
        'AI service timed out. Please try again.',
        retryable: true,
      );
    }
    return AiProviderException(
      'Could not connect to the AI service.',
      retryable: _isTransientDioError(error),
    );
  }

  bool _isTransientDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        (statusCode != null && statusCode >= 500);
  }

  bool _isAuthenticationMessage(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('api key') ||
        normalized.contains('unauthorized') ||
        normalized.contains('authentication');
  }

  String _validatedHttpsUrl(dynamic value, String errorMessage) {
    if (value is! String) throw AiProviderException(errorMessage);
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw AiProviderException(errorMessage);
    }
    return value;
  }

  String _normalizedPrompt(String prompt) {
    final normalized = prompt.trim();
    if (normalized.isEmpty) {
      throw const AiProviderException('Please enter a prompt.');
    }
    return normalized;
  }

  String? _detectImageContentType(List<int> bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return 'image/png';
    }
    return null;
  }

  void _debug(String message) {
    if (kDebugMode) AppLogger.debug('[LightX] $message');
  }
}

Uint8List _normalizeLightxJpeg(Uint8List bytes) {
  final decoded = image_lib.decodeImage(bytes);
  if (decoded == null) {
    throw const FormatException(
      'The selected image is unsupported or corrupted.',
    );
  }

  var normalized = image_lib.bakeOrientation(decoded);
  const minimumDimension = 512;
  if (normalized.width < minimumDimension ||
      normalized.height < minimumDimension) {
    final scale = [
      minimumDimension / normalized.width,
      minimumDimension / normalized.height,
    ].reduce((largest, value) => value > largest ? value : largest);
    normalized = image_lib.copyResize(
      normalized,
      width: (normalized.width * scale).ceil(),
      height: (normalized.height * scale).ceil(),
      interpolation: image_lib.Interpolation.cubic,
    );
  }

  for (var quality = 90; quality >= 40; quality -= 10) {
    final encoded = Uint8List.fromList(
      image_lib.encodeJpg(normalized, quality: quality),
    );
    if (encoded.length <= LightxAiProvider._maxUploadBytes) return encoded;
  }

  throw const FormatException(
    'The selected image could not be reduced below 5 MB.',
  );
}
