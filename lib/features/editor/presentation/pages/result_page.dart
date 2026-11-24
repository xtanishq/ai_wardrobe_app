import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/report_content_dialog.dart';

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/data/creations_store.dart';

class ResultPage extends StatefulWidget {
  final Map<String, dynamic>? extraData;

  const ResultPage({Key? key, this.extraData}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isSaved = false;
  bool _isDownloading = false;
  bool _isSharing = false;

  Future<void> _shareImage(String url) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          response.bodyBytes.isEmpty) {
        throw const HttpException(
            'The generated image could not be downloaded.');
      }
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/glimora_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(response.bodyBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Check out my creation from Glimora!',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sharing image: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _downloadToGallery(String url) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Downloading image...")),
      );

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          response.bodyBytes.isEmpty) {
        throw const HttpException(
            'The generated image could not be downloaded.');
      }
      final result = await ImageGallerySaverPlus.saveImage(
        response.bodyBytes,
        quality: 100,
        name: "glimora_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (mounted) {
        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Saved to Gallery successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to save to Gallery.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving image: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  void _handleBack(BuildContext context) async {
    if (_isSaved) {
      context.pop();
      return;
    }

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfacePrimary,
        title: const Text('Unsaved Changes',
            style: TextStyle(color: AppTheme.textMain)),
        content: const Text(
            'Do you want to continue without saving your creation?',
            style: TextStyle(color: AppTheme.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue',
                style: TextStyle(color: AppTheme.accentPurple)),
          ),
        ],
      ),
    );

    if (shouldPop == true) {
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultUrl = widget.extraData?['resultUrl'];
    if (resultUrl is! String || resultUrl.trim().isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(
          child: PrimaryButton(
            text: 'Return Home',
            onTap: () => context.go('/home'),
          ),
        ),
      );
    }

    final originalPath = widget.extraData?['originalPath'];
    final hasOriginal = originalPath is String &&
        originalPath.isNotEmpty &&
        File(originalPath).existsSync();

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          _handleBack(context);
        },
        child: Scaffold(
          backgroundColor: AppTheme.backgroundDark,
          appBar: AppBar(
            forceMaterialTransparency: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.textMain),
              onPressed: () => _handleBack(context),
            ),
            title: const Text(
              "Preview",
              style: TextStyle(
                  color: AppTheme.textMain, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.flag_outlined, color: Colors.redAccent),
                tooltip: "Report or flag offensive content",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ReportContentDialog(imageUrl: resultUrl),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: AppTheme.borderSubtle, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentPurple.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(23),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: resultUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppTheme.surfaceSecondary,
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: AppTheme.accentPurple),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                                Icons.error,
                                color: AppTheme.textMuted),
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppTheme.borderSubtle, width: 1),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: AppTheme.accentPurple,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (hasOriginal) ...[
                    const SizedBox(height: 24),
                    const Text(
                      "Before & After",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppTheme.borderSubtle, width: 1),
                              image: DecorationImage(
                                image: FileImage(File(originalPath)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.arrow_forward,
                            color: AppTheme.textMuted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppTheme.borderSubtle, width: 1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                imageUrl: resultUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(color: AppTheme.surfaceSecondary),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error,
                                        color: AppTheme.textMuted),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ] else ...[
                    const SizedBox(height: 32),
                  ],
                  PrimaryButton(
                    text: _isSaved ? "Saved" : "Save to My Creations",
                    onTap: _isSaved
                        ? () {}
                        : () async {
                            final rawFeature = widget.extraData?['feature'];
                            final feature = rawFeature is String &&
                                    rawFeature.trim().isNotEmpty
                                ? rawFeature
                                : 'AI Edit';
                            try {
                              await CreationsStore().addCreation(
                                Creation(
                                  imageUrl: resultUrl,
                                  featureLabel: feature,
                                  date: DateTime.now(),
                                ),
                              );
                              await _downloadToGallery(resultUrl);

                              if (mounted) {
                                setState(() => _isSaved = true);
                              }
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Could not save this creation.'),
                                  ),
                                );
                              }
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: "Download",
                          isSecondary: true,
                          onTap: () => _downloadToGallery(resultUrl),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: "Share",
                          isSecondary: true,
                          onTap: () => _shareImage(resultUrl),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ));
  }
}
