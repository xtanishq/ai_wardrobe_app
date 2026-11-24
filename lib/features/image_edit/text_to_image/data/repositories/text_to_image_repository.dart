import 'package:fpdart/fpdart.dart';
import '../../../../../core/ai/ai_image_provider.dart';
import '../../../../../core/ai/ai_provider_registry.dart';

class TextToImageRepository {
  TextToImageRepository({AiImageProvider? provider})
      : _provider = provider ?? AiProviderRegistry.instance.provider;

  final AiImageProvider _provider;

  Future<Either<String, String>> generateImage(String prompt) async {
    try {
      return Right(await _provider.textToImage(prompt: prompt));
    } catch (e) {
      return Left(e.toString());
    }
  }
}
