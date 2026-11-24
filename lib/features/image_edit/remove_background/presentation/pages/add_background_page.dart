import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/app_snackbar.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/style_thumbnail_image.dart';
import '../../data/repositories/remove_background_repository.dart';
import '../../data/models/background_style_model.dart';

class AddBackgroundPage extends StatefulWidget {
  final String resultUrl;
  final String originalPath;

  const AddBackgroundPage({
    super.key,
    required this.resultUrl,
    required this.originalPath,
  });

  @override
  State<AddBackgroundPage> createState() => _AddBackgroundPageState();
}

class _AddBackgroundPageState extends State<AddBackgroundPage> {
  final RemoveBackgroundRepository _repository = RemoveBackgroundRepository();

  List<BackgroundStyleModel> _backgrounds = [];
  BackgroundStyleModel? _selectedBackground;
  bool _isLoadingBackgrounds = true;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _fetchBackgrounds();
  }

  Future<void> _fetchBackgrounds() async {
    final result = await _repository.fetchBackgrounds();
    if (!mounted) return;

    setState(() {
      _isLoadingBackgrounds = false;
    });

    result.fold(
      (error) {
        AppSnackbar.error(context, error);
      },
      (backgrounds) {
        setState(() {
          _backgrounds = backgrounds;
        });
      },
    );
  }

  Future<void> _applyBackground() async {
    if (_selectedBackground == null || _isGenerating) return;

    setState(() {
      _isGenerating = true;
    });

    final result = await _repository.applyBackground(
      widget.resultUrl,
      _selectedBackground!.style,
    );

    if (!mounted) return;

    setState(() {
      _isGenerating = false;
    });

    result.fold(
      (error) {
        AppSnackbar.error(context, error);
      },
      (finalImageUrl) {
        context.push('/result', extra: {
          'originalPath': widget.originalPath,
          'resultUrl': finalImageUrl,
          'feature': 'Remove & Add Background',
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
          "Select Background",
          style:
              TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(0, 176, 129, 129),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // PREVIEW IMAGE
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSecondary,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.borderSubtle, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentPurple.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: CachedNetworkImage(
                      imageUrl: widget.resultUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentPurple),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error, color: AppTheme.textMuted),
                    ),
                  ),
                ),
              ),
            ),

            // HORIZONTAL BACKGROUND SELECTOR
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                decoration: const BoxDecoration(
                  color: AppTheme.surfacePrimary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  border: Border(
                    top: BorderSide(color: AppTheme.borderSubtle, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        "Available Backgrounds",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _isLoadingBackgrounds
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.accentPurple),
                              ),
                            )
                          : _backgrounds.isEmpty
                              ? const Center(
                                  child: Text("No backgrounds found.",
                                      style:
                                          TextStyle(color: AppTheme.textMuted)))
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  itemCount: _backgrounds.length,
                                  itemBuilder: (context, index) {
                                    final bg = _backgrounds[index];
                                    final isSelected =
                                        _selectedBackground?.id == bg.id;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedBackground = bg;
                                        });
                                      },
                                      child: Container(
                                        width: 100,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceSecondary,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppTheme.accentPurple
                                                : Colors.transparent,
                                            width: isSelected ? 3 : 0,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: AppTheme.accentPurple
                                                        .withValues(alpha: 0.5),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            StyleThumbnailImage(
                                              source: bg.displayUrl,
                                              fallbackIcon:
                                                  Icons.wallpaper_rounded,
                                            ),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        6, 18, 6, 6),
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.transparent,
                                                      Color(0xD9000000),
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                ),
                                                child: Text(
                                                  bg.tags.isEmpty
                                                      ? bg.style
                                                      : bg.tags.first,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: _isGenerating
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.accentPurple),
                              ),
                            )
                          : PrimaryButton(
                              text: _selectedBackground == null
                                  ? "Skip & Continue"
                                  : "Apply Background ✨",
                              onTap: () {
                                if (_selectedBackground == null) {
                                  // Just go to result with transparent BG
                                  context.push('/result', extra: {
                                    'originalPath': widget.originalPath,
                                    'resultUrl': widget.resultUrl,
                                    'feature': 'Remove Background',
                                  });
                                } else {
                                  _applyBackground();
                                }
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
