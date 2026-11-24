import 'dart:io';

class BackgroundRemovalResult {
  final String imageUrl;
  final String? maskUrl;

  const BackgroundRemovalResult({
    required this.imageUrl,
    this.maskUrl,
  });
}

/// Provider-neutral contract used by feature repositories.
///
/// Vendor request fields, upload protocols, polling, and response schemas must
/// stay inside an implementation of this interface.
abstract interface class AiImageProvider {
  Future<String> changeOutfit({
    required File image,
    required String prompt,
  });

  Future<String> applyFilter({
    required File image,
    required String prompt,
    String? referenceImageUrl,
  });

  Future<String> textToImage({
    required String prompt,
    String resolution = '1:1',
    bool enhancePrompt = true,
  });

  Future<String> imageToImage({
    required File image,
    required String prompt,
  });

  Future<String> changeHairstyle({
    required File image,
    required String prompt,
  });

  Future<String> upscale({
    required File image,
    int quality = 2,
  });

  Future<BackgroundRemovalResult> removeBackground({
    required File image,
  });

  Future<String> generateBackground({
    required String imageUrl,
    required String prompt,
  });

  Future<String> createHeadshot({
    required File image,
    required String prompt,
  });
}

class AiProviderException implements Exception {
  final String message;
  final bool retryable;

  const AiProviderException(this.message, {this.retryable = false});

  @override
  String toString() => message;
}
