import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/utils/app_snackbar.dart';
import '../../../../../core/utils/prompt_safety.dart';
import '../../data/repositories/text_to_image_repository.dart';
import '../../../../../core/theme/app_theme.dart';

class TextToImagePage extends StatefulWidget {
  const TextToImagePage({Key? key}) : super(key: key);

  @override
  State<TextToImagePage> createState() => _TextToImagePageState();
}

class _TextToImagePageState extends State<TextToImagePage> {
  final TextEditingController _promptController = TextEditingController();
  final TextToImageRepository _repository = TextToImageRepository();
  bool _isLoading = false;

  void _generateImage() async {
    if (_isLoading) return;
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      AppSnackbar.info(context, 'Please enter a prompt first.');
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

    final result = await _repository.generateImage(prompt);

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
          'resultUrl': imageUrl,
          'feature': 'Text to Image',
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
          "Text to Image",
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
              // PREVIEW IMAGE
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentPurple.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('asset/text_to_img_preview_screen.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // TEXT FIELD
              const Text(
                "Describe your imagination",
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
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText:
                        "E.g., A girl running on the beach looking at the sky...",
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
