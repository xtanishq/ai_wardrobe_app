import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/feature_detail_layout.dart';
import '../../../../core/widgets/style_thumbnail_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../data/repositories/ai_filter_repository.dart';
import '../../../image_edit/art_styles/data/models/art_style_model.dart';

class AiFiltersPage extends StatefulWidget {
  const AiFiltersPage({super.key});

  @override
  State<AiFiltersPage> createState() => _AiFiltersPageState();
}

class _AiFiltersPageState extends State<AiFiltersPage> {
  final AiFilterRepository _repo = AiFilterRepository();

  Map<String, List<ArtStyleModel>> _categorizedFilters = {};
  String? _selectedCategory;
  ArtStyleModel? _selectedFilter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFilters();
  }

  Future<void> _fetchFilters() async {
    final result = await _repo.fetchFilters();
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    result.fold(
      (error) {
        AppSnackbar.error(context, error);
      },
      (filters) {
        setState(() {
          _categorizedFilters = filters;
          if (_categorizedFilters.isNotEmpty) {
            _selectedCategory = _categorizedFilters.keys.first;
            if (_categorizedFilters[_selectedCategory]!.isNotEmpty) {
              _selectedFilter = _categorizedFilters[_selectedCategory]!.first;
            }
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FeatureDetailLayout(
      title: "AI Filters",
      description: "Transform your photos with stunning creative AI filters.",
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
                  // padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    children: _categorizedFilters.keys.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                              if (_categorizedFilters[category]!.isNotEmpty) {
                                _selectedFilter =
                                    _categorizedFilters[category]!.first;
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

                // FILTERS — Horizontal Scroll
                if (_selectedCategory != null)
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      itemCount: _categorizedFilters[_selectedCategory]!.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final filter =
                            _categorizedFilters[_selectedCategory]![index];
                        final isSelected = _selectedFilter?.id == filter.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = filter),
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
                                    source: filter.displayUrl,
                                    fallbackIcon: Icons.auto_awesome,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 72,
                                child: Text(
                                  filter.style,
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
                const SizedBox(height: 8),
              ],
            ),
      onGenerate: (image) async {
        if (_selectedFilter == null) {
          throw Exception("Please select a filter.");
        }
        final resultUrl = await _repo.generateAiFilter(
          image,
          _selectedFilter!.style,
        );
        if (context.mounted) {
          context.push('/result', extra: {
            'feature': 'AI Filters',
            'style': _selectedFilter?.style ?? '',
            'resultUrl': resultUrl,
            'originalPath': image.path,
          });
        }
      },
    );
  }
}
