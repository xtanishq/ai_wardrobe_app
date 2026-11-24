import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import '../theme/app_theme.dart';

class UploadCard extends StatelessWidget {
  final VoidCallback onTap;
  final File? selectedImage;

  const UploadCard({
    Key? key,
    required this.onTap,
    this.selectedImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: selectedImage != null
          ? Container(
              width: double.infinity,
              height: MediaQuery.sizeOf(context).height * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderSubtle, width: 1.5),
                image: DecorationImage(
                  image: FileImage(selectedImage!),
                  fit: BoxFit.contain,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.borderSubtle, width: 1),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            )
          : DottedBorder(
              options: RoundedRectDottedBorderOptions(
                color: AppTheme.accentPurple.withOpacity(0.5),
                strokeWidth: 2,
                dashPattern: const [8, 4],
                radius: const Radius.circular(24),
              ),
              child: Container(
                width: double.infinity,
                height: MediaQuery.sizeOf(context).height * 0.4,
                decoration: BoxDecoration(
                  color: AppTheme.surfacePrimary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: AppTheme.accentPurple,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Tap to upload image",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "JPG, PNG up to 10MB",
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
