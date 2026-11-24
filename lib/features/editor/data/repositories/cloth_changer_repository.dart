import 'dart:io';
import '../../../../core/ai/ai_image_provider.dart';
import '../../../../core/ai/ai_provider_registry.dart';
import '../models/wardrobe_style_model.dart';

class ClothChangerRepository {
  ClothChangerRepository({AiImageProvider? provider})
      : _provider = provider ?? AiProviderRegistry.instance.provider;

  final AiImageProvider _provider;

  Future<List<WardrobeStyleModel>> fetchStyles() async {
    return _styles;
  }

  Future<String> generateClothChange(File imageFile, String prompt) {
    return _provider.changeOutfit(image: imageFile, prompt: prompt);
  }

  static const List<WardrobeStyleModel> _styles = [
    WardrobeStyleModel(
        id: 'female-casual',
        style: 'Casual Chic',
        gender: 'female',
        displayUrl: 'asset/wardrobe_styles/female_casual.png',
        beforeUrl: '',
        hot: true,
        showFirst: true,
        usageCount: ''),
    WardrobeStyleModel(
        id: 'female-evening',
        style: 'Elegant Evening Dress',
        gender: 'female',
        displayUrl: 'asset/wardrobe_styles/female_evening.png',
        beforeUrl: '',
        hot: true,
        showFirst: false,
        usageCount: ''),
    WardrobeStyleModel(
        id: 'female-traditional',
        style: 'Traditional Indian Outfit',
        gender: 'female',
        displayUrl: 'asset/wardrobe_styles/female_traditional.png',
        beforeUrl: '',
        hot: false,
        showFirst: false,
        usageCount: ''),
    WardrobeStyleModel(
        id: 'female-business',
        style: 'Modern Business Wear',
        gender: 'female',
        displayUrl: 'asset/wardrobe_styles/female_business.png',
        beforeUrl: '',
        hot: false,
        showFirst: false,
        usageCount: ''),
    WardrobeStyleModel(
        id: 'male-streetwear',
        style: 'Casual Streetwear',
        gender: 'male',
        displayUrl: 'asset/wardrobe_styles/male_streetwear.png',
        beforeUrl: '',
        hot: true,
        showFirst: true,
        usageCount: ''),
    WardrobeStyleModel(
        id: 'male-formal',
        style: 'Tailored Formal Suit',
        gender: 'male',
        displayUrl: 'asset/wardrobe_styles/male_formal.png',
        beforeUrl: '',
        hot: true,
        showFirst: false,
        usageCount: ''),
    WardrobeStyleModel(
        id: 'male-traditional',
        style: 'Traditional Indian Outfit',
        gender: 'male',
        displayUrl: 'asset/wardrobe_styles/male_traditional.png',
        beforeUrl: '',
        hot: false,
        showFirst: false,
        usageCount: ''),
    WardrobeStyleModel(
        id: 'male-business',
        style: 'Smart Business Casual',
        gender: 'male',
        displayUrl: 'asset/wardrobe_styles/male_business.png',
        beforeUrl: '',
        hot: false,
        showFirst: false,
        usageCount: ''),
  ];
}
