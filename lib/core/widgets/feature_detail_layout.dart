import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../config/ai_runtime_config.dart';
import '../theme/app_theme.dart';
import '../utils/app_snackbar.dart';
import 'upload_card.dart';
import 'primary_button.dart';

class FeatureDetailLayout extends StatefulWidget {
  final String title;
  final String description;
  final Widget? chipsSelector;
  final Future<void> Function(File image) onGenerate;

  const FeatureDetailLayout({
    super.key,
    required this.title,
    required this.description,
    this.chipsSelector,
    required this.onGenerate,
  });

  @override
  State<FeatureDetailLayout> createState() => _FeatureDetailLayoutState();
}

class _FeatureDetailLayoutState extends State<FeatureDetailLayout> {
  File? _pickedImage;
  bool _isGenerating = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _printLightxKeyForDebug() async {
    if (!kDebugMode) return;

    try {
      final apiKey = await AiRuntimeConfig.instance.requireLightxApiKey();
      debugPrint('[Generate] LightX API key: $apiKey');
    } catch (error) {
      debugPrint('[Generate] LightX API key unavailable: $error');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          _pickedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Image selection failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppTheme.backgroundDark,
          appBar: AppBar(
            forceMaterialTransparency: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.textMain),
              onPressed: () => context.pop(),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textMain,
                  ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Description ───────────────────────────────
                        Text(
                          widget.description,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),

                        // ── Upload card ───────────────────────────────
                        UploadCard(
                          selectedImage: _pickedImage,
                          onTap: _pickImage,
                        ),
                        const Spacer(),

                        // ── Chips selector — animated, smooth expansion ──
                        AnimatedSize(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          alignment: Alignment.topCenter,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                    opacity: animation, child: child),
                            child: widget.chipsSelector != null
                                ? SizedBox(
                                    key: ValueKey(
                                        widget.chipsSelector.runtimeType),
                                    width: double.infinity,
                                    child: widget.chipsSelector,
                                  )
                                : const SizedBox(
                                    width: double.infinity, height: 0),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // ── Generate button (Pinned at bottom) ───────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: PrimaryButton(
                      text: _isGenerating ? "Generating..." : "Generate",
                      onTap: _isGenerating
                          ? () {}
                          : () async {
                              if (_isGenerating) return;
                              if (_pickedImage == null) {
                                AppSnackbar.info(
                                    context, 'Please upload an image first.');
                                return;
                              }
                              await _printLightxKeyForDebug();
                              if (!mounted) return;
                              setState(() => _isGenerating = true);
                              try {
                                await widget.onGenerate(_pickedImage!);
                              } catch (e) {
                                if (context.mounted) {
                                  AppSnackbar.error(context, e.toString());
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isGenerating = false);
                                }
                              }
                            },
                    ),
                  ),
                  const SizedBox(height: 16)
                ],
              ),
            ),
          ),
        ),
        if (_isGenerating)
          Container(
            color: AppTheme.backgroundDark.withValues(alpha: 0.7),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.accentPurple),
              ),
            ),
          ),
      ],
    );
  }
}
