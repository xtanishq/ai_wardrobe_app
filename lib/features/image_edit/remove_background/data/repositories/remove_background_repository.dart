import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../../core/ai/ai_image_provider.dart';
import '../../../../../core/ai/ai_provider_registry.dart';
import '../models/background_style_model.dart';

class RemoveBackgroundRepository {
  RemoveBackgroundRepository({AiImageProvider? provider})
      : _provider = provider ?? AiProviderRegistry.instance.provider;

  final AiImageProvider _provider;

  Future<Either<String, List<BackgroundStyleModel>>> fetchBackgrounds() async {
    return const Right(_backgrounds);
  }

  Future<Either<String, String>> applyBackground(
      String imageUrl, String prompt) async {
    try {
      return Right(await _provider.generateBackground(
          imageUrl: imageUrl, prompt: prompt));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> removeBackground(File imageFile) async {
    try {
      final result = await _provider.removeBackground(image: imageFile);
      return Right(result.imageUrl);
    } catch (e) {
      return Left(e.toString());
    }
  }

  static const List<BackgroundStyleModel> _backgrounds = [
    BackgroundStyleModel(
        id: 1,
        style: 'Professional photo studio with soft neutral lighting',
        displayUrl: 'asset/backgrounds/studio.png',
        tags: ['studio']),
    BackgroundStyleModel(
        id: 2,
        style: 'Sunny tropical beach with blue water',
        displayUrl: 'asset/backgrounds/beach.png',
        tags: ['outdoor']),
    BackgroundStyleModel(
        id: 3,
        style: 'Modern premium office interior',
        displayUrl: 'asset/backgrounds/office.png',
        tags: ['office']),
    BackgroundStyleModel(
        id: 4,
        style: 'Cinematic city street at night with neon lights',
        displayUrl: 'asset/backgrounds/neon_city.png',
        tags: ['city']),
    BackgroundStyleModel(
        id: 5,
        style: 'Lush green garden with soft natural light',
        displayUrl: 'asset/backgrounds/garden.png',
        tags: ['nature']),
    BackgroundStyleModel(
        id: 6,
        style: 'Luxury living room interior',
        displayUrl: 'asset/backgrounds/living_room.png',
        tags: ['interior']),
  ];
}
