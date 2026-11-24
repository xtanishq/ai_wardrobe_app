import 'ai_image_provider.dart';
import '../config/ai_runtime_config.dart';
import 'providers/lightx_ai_provider.dart';

/// Single provider composition point for the entire application.
///
/// To replace LightX later, implement [AiImageProvider] and change only the
/// provider registered here (or inject a provider into an individual
/// repository during migration/testing).
class AiProviderRegistry {
  AiProviderRegistry._();

  static final AiProviderRegistry instance = AiProviderRegistry._();

  late AiImageProvider _provider;
  bool _initialized = false;

  AiImageProvider get provider {
    if (!_initialized) {
      _provider = LightxAiProvider(config: AiRuntimeConfig.instance);
      _initialized = true;
    }
    return _provider;
  }

  void register(AiImageProvider provider) {
    _provider = provider;
    _initialized = true;
  }
}
