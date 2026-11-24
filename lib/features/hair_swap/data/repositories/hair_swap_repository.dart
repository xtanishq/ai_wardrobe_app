import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../core/ai/ai_image_provider.dart';
import '../../../../core/ai/ai_provider_registry.dart';
import '../models/hair_swap_model.dart';

class HairSwapRepository {
  HairSwapRepository({AiImageProvider? provider})
      : _provider = provider ?? AiProviderRegistry.instance.provider;

  final AiImageProvider _provider;

  Future<Either<String, Map<String, List<HairStyleModel>>>>
      fetchHairStyles() async {
    return Right(_styles);
  }

  Future<String> generateHairSwap(File image, String prompt) {
    return _provider.changeHairstyle(image: image, prompt: prompt);
  }

  static final Map<String, List<HairStyleModel>> _styles = {
    'Women': [
      HairStyleModel(
          id: 1,
          styleName: 'Long Beach Waves',
          displayUrl: 'asset/hair_styles/women_beach_waves.png',
          tags: const ['popular']),
      HairStyleModel(
          id: 2,
          styleName: 'Classic Bob Cut',
          displayUrl: 'asset/hair_styles/women_bob.png',
          tags: const []),
      HairStyleModel(
          id: 3,
          styleName: 'Textured Pixie Cut',
          displayUrl: 'asset/hair_styles/women_pixie.png',
          tags: const []),
      HairStyleModel(
          id: 4,
          styleName: 'Elegant Braided Hair',
          displayUrl: 'asset/hair_styles/women_braid.png',
          tags: const []),
    ],
    'Men': [
      HairStyleModel(
          id: 5,
          styleName: 'Modern Pompadour',
          displayUrl: 'asset/hair_styles/men_pompadour.png',
          tags: const ['popular']),
      HairStyleModel(
          id: 6,
          styleName: 'Textured Crop',
          displayUrl: 'asset/hair_styles/men_crop.png',
          tags: const []),
      HairStyleModel(
          id: 7,
          styleName: 'Clean Buzz Cut',
          displayUrl: 'asset/hair_styles/men_buzz.png',
          tags: const []),
      HairStyleModel(
          id: 8,
          styleName: 'Shoulder Length Waves',
          displayUrl: 'asset/hair_styles/men_waves.png',
          tags: const []),
    ],
  };
}
