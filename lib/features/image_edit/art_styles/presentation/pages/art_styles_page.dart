import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/style_thumbnail_image.dart';
import '../../../../../core/utils/app_snackbar.dart';
import '../../../../../core/utils/prompt_safety.dart';
import '../../data/repositories/art_styles_repository.dart';
import '../../data/models/art_style_model.dart';
import '../../../../../core/theme/app_theme.dart';

class ArtStylesPage extends StatefulWidget {
  const ArtStylesPage({super.key});

  @override
  State<ArtStylesPage> createState() => _ArtStylesPageState();
}

class _ArtStylesPageState extends State<ArtStylesPage> {
  final ArtStylesRepository _repository = ArtStylesRepository();
  final TextEditingController _promptController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isLoadingStyles = true;
  bool _isGenerating = false;

  Map<String, List<ArtStyleModel>> _categorizedStyles = {};
  String? _selectedCategory;
  ArtStyleModel? _selectedStyle;

  @override
  void initState() {
    super.initState();
    _fetchStyles();
  }

  Future<void> _fetchStyles() async {
    final result = await _repository.fetchStyles();
    if (!mounted) return;

    setState(() {
      _isLoadingStyles = false;
    });

    result.fold(
      (error) {
        AppSnackbar.error(context, error);
      },
      (styles) {
        setState(() {
          _categorizedStyles = styles;
          if (_categorizedStyles.isNotEmpty) {
            _selectedCategory = _categorizedStyles.keys.first;
            if (_categorizedStyles[_selectedCategory]!.isNotEmpty) {
              _selectedStyle = _categorizedStyles[_selectedCategory]!.first;
            }
          }
        });
      },
    );
  }

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

  void _generateArt() async {
    if (_isGenerating) return;
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      AppSnackbar.info(context, 'Please enter a prompt.');
      return;
    }

    if (_selectedStyle == null) {
      AppSnackbar.info(context, 'Please select an art style.');
      return;
    }

    if (!PromptSafety.isPromptSafe(prompt)) {
      AppSnackbar.error(context,
          'Your prompt contains blocked words. Please ensure it follows our safety guidelines.');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    final result = await _repository.generateArt(
      image: _selectedImage,
      prompt: prompt,
      stylePrompt: _selectedStyle!.style,
    );

    if (!mounted) return;

    setState(() {
      _isGenerating = false;
    });

    result.fold(
      (error) {
        AppSnackbar.error(context, error);
      },
      (imageUrl) {
        context.push('/result', extra: {
          'originalPath': _selectedImage?.path,
          'resultUrl': imageUrl,
          'feature': 'Art Styles',
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
          "Art Generator",
          style:
              TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoadingStyles
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // OPTIONAL IMAGE PICKER
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppTheme.surfacePrimary,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: AppTheme.borderSubtle, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.accentPurple.withValues(alpha: 0.15),
                              blurRadius: 20,
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
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate,
                                      size: 48, color: AppTheme.textMuted),
                                  SizedBox(height: 12),
                                  Text(
                                    "Tap to select an image (Optional)",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    if (_selectedImage != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          child: const Text("Remove Image",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // TEXT FIELD
                    const Text(
                      "Prompt",
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
                        border:
                            Border.all(color: AppTheme.borderSubtle, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentPurple.withValues(alpha: 0.1),
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
                              "E.g., A digital painting of a majestic lion...",
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
                    const SizedBox(height: 32),

                    // CATEGORIES
                    const Text(
                      "Categories",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categorizedStyles.keys.map((category) {
                          final isSelected = _selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                  if (_categorizedStyles[category]!
                                      .isNotEmpty) {
                                    _selectedStyle =
                                        _categorizedStyles[category]!.first;
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.accentPurple
                                      : AppTheme.surfaceSecondary,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.accentPurple
                                        : AppTheme.borderSubtle,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textMuted,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // STYLES — Horizontal Scroll
                    if (_selectedCategory != null)
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              _categorizedStyles[_selectedCategory]!.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final style =
                                _categorizedStyles[_selectedCategory]![index];
                            final isSelected = _selectedStyle?.id == style.id;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedStyle = style),
                              child: Column(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.accentPurple
                                            : AppTheme.borderSubtle,
                                        width: isSelected ? 2.5 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppTheme.accentPurple
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 10,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: StyleThumbnailImage(
                                        source: style.displayUrl,
                                        fallbackIcon: Icons.palette_outlined,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: 72,
                                    child: Text(
                                      style.style,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected
                                            ? AppTheme.accentPurple
                                            : AppTheme.textMuted,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 40),

                    // GENERATE BUTTON
                    _isGenerating
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.accentPurple),
                            ),
                          )
                        : PrimaryButton(
                            text: "Generate Art ✨",
                            onTap: _generateArt,
                          ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}
