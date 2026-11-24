import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../../core/ai/ai_image_provider.dart';
import '../../../../../core/ai/ai_provider_registry.dart';
import '../models/art_style_model.dart';

class ArtStylesRepository {
  ArtStylesRepository({AiImageProvider? provider})
      : _provider = provider ?? AiProviderRegistry.instance.provider;

  final AiImageProvider _provider;

  Future<Either<String, Map<String, List<ArtStyleModel>>>> fetchStyles() async {
    return Right(_styles);
  }

  Future<Either<String, String>> generateArt({
    File? image,
    required String prompt,
    required String stylePrompt,
  }) async {
    try {
      final combinedPrompt = '$prompt. Render in $stylePrompt style.';
      if (image != null) {
        return Right(
            await _provider.imageToImage(image: image, prompt: combinedPrompt));
      }
      return Right(await _provider.textToImage(prompt: combinedPrompt));
    } catch (e) {
      return Left(e.toString());
    }
  }

  static final Map<String, List<ArtStyleModel>> _styles = {
    'Painting': [
      ArtStyleModel(
          id: 1,
          style: 'Watercolor Painting',
          displayUrl: 'asset/art_styles/watercolor.png',
          tags: const []),
      ArtStyleModel(
          id: 2,
          style: 'Oil Painting',
          displayUrl: 'asset/art_styles/oil_painting.png',
          tags: const []),
      ArtStyleModel(
          id: 3,
          style: 'Ink Illustration',
          displayUrl: 'asset/art_styles/ink_illustration.png',
          tags: const []),
    ],
    'Digital': [
      ArtStyleModel(
          id: 4,
          style: 'Anime Art',
          displayUrl: 'asset/art_styles/anime_art.png',
          tags: const []),
      ArtStyleModel(
          id: 5,
          style: '3D Render',
          displayUrl: 'asset/art_styles/render_3d.png',
          tags: const []),
      ArtStyleModel(
          id: 6,
          style: 'Fantasy Concept Art',
          displayUrl: 'asset/art_styles/fantasy_concept.png',
          tags: const []),
    ],
  };
}
