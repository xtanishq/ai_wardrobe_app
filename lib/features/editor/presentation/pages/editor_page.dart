import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/feature_detail_layout.dart';
import '../../../../core/widgets/style_thumbnail_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/wardrobe_style_model.dart';
import '../../data/repositories/cloth_changer_repository.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final _repo = ClothChangerRepository();

  Map<String, List<WardrobeStyleModel>> _categorizedStyles = {};
  String? _selectedCategory;
  WardrobeStyleModel? _selectedStyle;
  bool _isLoadingStyles = true;

  @override
  void initState() {
    super.initState();
    _loadStyles();
  }

  Future<void> _loadStyles() async {
    try {
      final styles = await _repo.fetchStyles();
      if (!mounted) return;

      // Group styles by gender (male / female)
      final Map<String, List<WardrobeStyleModel>> grouped = {};
      for (final style in styles) {
        final category = style.gender.isNotEmpty
            ? style.gender[0].toUpperCase() + style.gender.substring(1)
            : 'Other';
        grouped.putIfAbsent(category, () => []).add(style);
      }

      setState(() {
        _categorizedStyles = grouped;
        if (_categorizedStyles.isNotEmpty) {
          _selectedCategory = _categorizedStyles.keys.first;
          final list = _categorizedStyles[_selectedCategory]!;
          if (list.isNotEmpty) _selectedStyle = list.first;
        }
        _isLoadingStyles = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStyles = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load styles: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FeatureDetailLayout(
      title: "Cloth Changer",
      description: "Try on new outfits instantly without changing clothes.",
      chipsSelector: _isLoadingStyles
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: AppTheme.accentPurple),
              ),
            )
          : _categorizedStyles.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Category Chips (Male / Female) ──────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categorizedStyles.keys.map((category) {
                          final isSelected = category == _selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                  final list = _categorizedStyles[category]!;
                                  _selectedStyle =
                                      list.isNotEmpty ? list.first : null;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.accentPurple
                                      : AppTheme.surfacePrimary,
                                  borderRadius: BorderRadius.circular(30),
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
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Style Grid ──────────────────────────────
                    if (_selectedCategory != null &&
                        _categorizedStyles[_selectedCategory] != null)
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
                            final isSelected = style.id == _selectedStyle?.id;
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
                                        fallbackIcon: Icons.checkroom,
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
                  ],
                ),
      onGenerate: (image) async {
        if (_selectedStyle == null) return;
        final resultUrl = await _repo.generateClothChange(
          image,
          _selectedStyle!.style,
        );
        if (context.mounted) {
          context.push('/result', extra: {
            'feature': 'Cloth Changer',
            'style': _selectedStyle?.style ?? '',
            'resultUrl': resultUrl,
            'originalPath': image.path,
          });
        }
      },
    );
  }
}
