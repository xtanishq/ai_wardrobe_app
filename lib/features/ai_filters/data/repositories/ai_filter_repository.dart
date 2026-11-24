import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/ai/ai_image_provider.dart';
import '../../../../core/ai/ai_provider_registry.dart';
import '../../../image_edit/art_styles/data/models/art_style_model.dart';

class AiFilterRepository {
  AiFilterRepository({AiImageProvider? provider})
      : _provider = provider ?? AiProviderRegistry.instance.provider;

  final AiImageProvider _provider;

  Future<Either<String, Map<String, List<ArtStyleModel>>>>
      fetchFilters() async {
    return Right(_filters);
  }

  Future<String> generateAiFilter(File image, String prompt) {
    return _provider.applyFilter(image: image, prompt: prompt);
  }

  static final Map<String, List<ArtStyleModel>> _filters = {
    'Creative': [
      ArtStyleModel(
          id: 1,
          style: 'Anime Portrait',
          displayUrl: 'asset/ai_filters/anime_portrait.png',
          tags: const []),
      ArtStyleModel(
          id: 2,
          style: '3D Cartoon',
          displayUrl: 'asset/ai_filters/cartoon_3d.png',
          tags: const []),
      ArtStyleModel(
          id: 3,
          style: 'Cyberpunk Neon',
          displayUrl: 'asset/ai_filters/cyberpunk_neon.png',
          tags: const []),
    ],
    'Photography': [
      ArtStyleModel(
          id: 4,
          style: 'Cinematic Film',
          displayUrl: 'asset/ai_filters/cinematic_film.png',
          tags: const []),
      ArtStyleModel(
          id: 5,
          style: 'Vintage Photograph',
          displayUrl: 'asset/ai_filters/vintage_photo.png',
          tags: const []),
      ArtStyleModel(
          id: 6,
          style: 'High Contrast Black and White',
          displayUrl: 'asset/ai_filters/black_white.png',
          tags: const []),
    ],
  };
}
