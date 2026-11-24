import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/prompt_safety.dart';
import '../../data/repositories/kontext_flux_repository.dart';
import '../../../../core/theme/app_theme.dart';

class KontextFluxPage extends StatefulWidget {
  const KontextFluxPage({Key? key}) : super(key: key);

  @override
  State<KontextFluxPage> createState() => _KontextFluxPageState();
}

class _KontextFluxPageState extends State<KontextFluxPage> {
  final TextEditingController _promptController = TextEditingController();
  final KontextFluxRepository _repository = KontextFluxRepository();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (error) {
      if (mounted) AppSnackbar.error(context, 'Image selection failed: $error');
    }
  }

  void _generateImage() async {
    if (_isLoading) return;
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      AppSnackbar.info(context, 'Please enter a prompt first.');
      return;
    }

    if (_selectedImage == null) {
      AppSnackbar.info(context, 'Please select an image first.');
      return;
    }

    if (!PromptSafety.isPromptSafe(prompt)) {
      AppSnackbar.error(context,
          'Your prompt contains blocked words. Please ensure it follows our safety guidelines.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _repository.generateImage(_selectedImage!, prompt);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    result.fold(
      (error) {
        AppSnackbar.error(context, error);
      },
      (imageUrl) {
        context.push('/result', extra: {
          'originalPath': _selectedImage!.path,
          'resultUrl': imageUrl,
          'feature': 'Kontext Flux',
        });
      },
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textMain),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Kontext Flux",
          style:
              TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE PICKER
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppTheme.surfacePrimary,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.borderSubtle, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentPurple.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_photo_alternate,
                                size: 64, color: AppTheme.textMuted),
                            SizedBox(height: 16),
                            Text(
                              "Tap to select an image",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 32),

              // TEXT FIELD
              const Text(
                "Describe what to change",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMain,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentPurple.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _promptController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText:
                        "E.g., Replace the background with a sunny beach...",
                    hintStyle: TextStyle(color: AppTheme.textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textMain,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // GENERATE BUTTON
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.accentPurple),
                      ),
                    )
                  : PrimaryButton(
                      text: "Generate Magic ✨",
                      onTap: _generateImage,
                    ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
