import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easefx_ai/core/ai/ai_image_provider.dart';
import 'package:easefx_ai/core/ai/providers/lightx_ai_provider.dart';
import 'package:easefx_ai/core/config/ai_runtime_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production polling uses an 8-second interval for 5 minutes', () {
    expect(
      LightxAiProvider.defaultPollInterval,
      const Duration(seconds: 8),
    );
    expect(
      LightxAiProvider.defaultPollTimeout,
      const Duration(minutes: 5),
    );
  });

  group('runtime config parsing', () {
    test('extracts and trims the LightX key', () {
      expect(
        AiRuntimeConfig.parseLightxApiKey('{"lightxkey":"  key-value  "}'),
        'key-value',
      );
    });

    test('rejects malformed or incomplete config', () {
      expect(
        () => AiRuntimeConfig.parseLightxApiKey('not-json'),
        throwsFormatException,
      );
      expect(
        () => AiRuntimeConfig.parseLightxApiKey('{"wrong":"value"}'),
        throwsFormatException,
      );
    });
  });

  test('textToImage submits the LightX request and polls until active',
      () async {
    final adapter = _QueuedAdapter([
      {
        'statusCode': 2000,
        'message': 'SUCCESS',
        'body': {
          'orderId': 'order-1',
          'maxRetriesAllowed': 5,
          'status': 'init',
        },
      },
      {
        'statusCode': 2000,
        'message': 'SUCCESS',
        'body': {
          'orderId': 'order-1',
          'status': 'active',
          'output': 'https://example.com/result.jpg',
        },
      },
    ]);
    final dio = Dio(
      BaseOptions(baseUrl: 'https://api.lightxeditor.com/external/api/v2'),
    )..httpClientAdapter = adapter;
    final provider = LightxAiProvider(
      config: _FakeCredentialSource(),
      dio: dio,
      pollInterval: Duration.zero,
    );

    final result = await provider.textToImage(prompt: 'A mountain at sunset');

    expect(result, 'https://example.com/result.jpg');
    expect(adapter.requests.map((request) => request.path), [
      '/text2image',
      '/order-status',
    ]);
    expect(adapter.requests.first.headers['x-api-key'], 'test-key');
    expect(adapter.requests.first.data, {
      'textPrompt': 'A mountain at sunset',
      'resolution': '1:1',
      'enhancePrompt': true,
    });
    expect(adapter.requests.last.data, {'orderId': 'order-1'});
  });

  test('order polling tolerates a transient server failure', () async {
    final adapter = _QueuedAdapter([
      {
        'statusCode': 2000,
        'body': {
          'orderId': 'order-2',
          'maxRetriesAllowed': 5,
          'status': 'init',
        },
      },
      const _StubResponse(statusCode: 503, body: {'message': 'busy'}),
      {
        'statusCode': 2000,
        'body': {
          'orderId': 'order-2',
          'status': 'active',
          'output': 'https://example.com/recovered.jpg',
        },
      },
    ]);
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    final provider = LightxAiProvider(
      config: _FakeCredentialSource(),
      dio: dio,
      pollInterval: Duration.zero,
    );

    expect(
      await provider.textToImage(prompt: 'A forest'),
      'https://example.com/recovered.jpg',
    );
    expect(adapter.requests, hasLength(3));
  });

  test('authentication failure refreshes Remote Config once', () async {
    final credentials = _FakeCredentialSource();
    final adapter = _QueuedAdapter([
      const _StubResponse(statusCode: 401, body: {'message': 'unauthorized'}),
      {
        'statusCode': 2000,
        'body': {
          'status': 'active',
          'output': 'https://example.com/refreshed.jpg',
        },
      },
    ]);
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    final provider = LightxAiProvider(
      config: credentials,
      dio: dio,
      pollInterval: Duration.zero,
    );

    expect(
      await provider.textToImage(prompt: 'A studio portrait'),
      'https://example.com/refreshed.jpg',
    );
    expect(credentials.refreshCount, 1);
    expect(adapter.requests.first.headers['x-api-key'], 'test-key');
    expect(adapter.requests.last.headers['x-api-key'], 'refreshed-test-key');
  });

  test('invalid prompts and resolutions fail before any request', () {
    final adapter = _QueuedAdapter(const []);
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    final provider = LightxAiProvider(
      config: _FakeCredentialSource(),
      dio: dio,
      pollInterval: Duration.zero,
    );

    expect(
      () => provider.textToImage(prompt: '   '),
      throwsA(isA<AiProviderException>()),
    );
    expect(
      () => provider.textToImage(prompt: 'valid', resolution: '5:7'),
      throwsA(isA<AiProviderException>()),
    );
    expect(adapter.requests, isEmpty);
  });
}

class _FakeCredentialSource implements AiCredentialSource {
  String _key = 'test-key';
  int refreshCount = 0;

  @override
  Future<String> requireLightxApiKey() async => _key;

  @override
  Future<String> refreshLightxApiKey() async {
    refreshCount++;
    _key = 'refreshed-test-key';
    return _key;
  }
}

class _QueuedAdapter implements HttpClientAdapter {
  _QueuedAdapter(this._responses);

  final List<Object> _responses;
  final List<RequestOptions> requests = [];
  var _responseIndex = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final response = _responses[_responseIndex++];
    final statusCode = response is _StubResponse ? response.statusCode : 200;
    final body = response is _StubResponse
        ? response.body
        : response as Map<String, dynamic>;
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _StubResponse {
  const _StubResponse({required this.statusCode, required this.body});

  final int statusCode;
  final Map<String, dynamic> body;
}
