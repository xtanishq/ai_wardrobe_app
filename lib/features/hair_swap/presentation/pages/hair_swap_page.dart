import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/feature_detail_layout.dart';
import '../../../../core/widgets/style_thumbnail_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../data/repositories/hair_swap_repository.dart';
import '../../data/models/hair_swap_model.dart';

class HairSwapPage extends StatefulWidget {
  const HairSwapPage({super.key});

  @override
  State<HairSwapPage> createState() => _HairSwapPageState();
}

class _HairSwapPageState extends State<HairSwapPage> {
  final HairSwapRepository _repo = HairSwapRepository();

  Map<String, List<HairStyleModel>> _categorizedStyles = {};
  String? _selectedCategory;
  HairStyleModel? _selectedStyle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStyles();
  }

  Future<void> _fetchStyles() async {
    final result = await _repo.fetchHairStyles();
    if (!mounted) return;

    setState(() {
      _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return FeatureDetailLayout(
      title: "HairSwap",
      description: "Experiment with new hairstyles instantly using AI.",
      chipsSelector: _isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.accentPurple),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CATEGORIES
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    children: _categorizedStyles.keys.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                              if (_categorizedStyles[category]!.isNotEmpty) {
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
                const SizedBox(height: 16),

                // STYLES — Horizontal Scroll
                if (_selectedCategory != null)
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      itemCount: _categorizedStyles[_selectedCategory]!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final style =
                            _categorizedStyles[_selectedCategory]![index];
                        final isSelected = _selectedStyle?.id == style.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedStyle = style),
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
                                    fallbackIcon: Icons.content_cut,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 72,
                                child: Text(
                                  style.styleName,
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
                const SizedBox(height: 24),
              ],
            ),
      onGenerate: (image) async {
        if (_selectedStyle == null) {
          throw Exception("Please select a hairstyle.");
        }
        final resultUrl = await _repo.generateHairSwap(
          image,
          _selectedStyle!.styleName,
        );
        if (context.mounted) {
          context.push('/result', extra: {
            'feature': 'HairSwap',
            'style': _selectedStyle?.styleName ?? '',
            'resultUrl': resultUrl,
            'originalPath': image.path,
          });
        }
      },
    );
  }
}
