import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../../core/ai/ai_image_provider.dart';
import '../../../../../core/ai/ai_provider_registry.dart';

class EnhanceRepository {
  EnhanceRepository({AiImageProvider? provider})
      : _provider = provider ?? AiProviderRegistry.instance.provider;

  final AiImageProvider _provider;

  Future<Either<String, String>> enhanceImage(File imageFile) async {
    try {
      return Right(await _provider.upscale(image: imageFile));
    } catch (e) {
      return Left(e.toString());
    }
  }
}
