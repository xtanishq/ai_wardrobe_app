import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/utils/app_snackbar.dart';
import '../../data/repositories/enhance_repository.dart';
import '../../../../../core/theme/app_theme.dart';

class EnhancePage extends StatefulWidget {
  const EnhancePage({Key? key}) : super(key: key);

  @override
  State<EnhancePage> createState() => _EnhancePageState();
}

class _EnhancePageState extends State<EnhancePage> {
  final EnhanceRepository _repository = EnhanceRepository();
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

  void _enhanceImage() async {
    if (_isLoading) return;
    if (_selectedImage == null) {
      AppSnackbar.info(context, 'Please select an image first.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _repository.enhanceImage(_selectedImage!);

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
          'feature': 'AI Enhance',
        });
      },
    );
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
          "AI Enhance",
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
                  height: 400,
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
              const SizedBox(height: 40),

              // ENHANCE BUTTON
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.accentPurple),
                      ),
                    )
                  : PrimaryButton(
                      text: "Enhance Quality ✨",
                      onTap: _enhanceImage,
                    ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
