import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'primary_button.dart';
import '../utils/app_snackbar.dart';

class ReportContentDialog extends StatefulWidget {
  final String imageUrl;

  const ReportContentDialog({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<ReportContentDialog> createState() => _ReportContentDialogState();
}

class _ReportContentDialogState extends State<ReportContentDialog> {
  int _selectedReasonIndex = -1;
  bool _isSubmitting = false;

  final List<String> _reasons = [
    "Nudity or sexual content",
    "Violent or repulsive content",
    "Hateful or abusive content",
    "Spam or misleading",
    "Other"
  ];

  Future<void> _submitReport() async {
    if (_selectedReasonIndex == -1) {
      AppSnackbar.info(context, "Please select a reason for reporting.");
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call to report endpoint
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.of(context).pop(); // Close dialog
    AppSnackbar.success(
      context, 
      "Content flagged for review. Thank you for keeping our community safe."
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfacePrimary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.borderSubtle, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_rounded, color: Colors.redAccent, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Report Content",
                    style: TextStyle(
                      color: AppTheme.textMain,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Why are you reporting this image? Your report will be sent to our trust & safety team for review.",
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            ...List.generate(_reasons.length, (index) {
              final isSelected = _selectedReasonIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedReasonIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentPurple.withOpacity(0.1) : AppTheme.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.accentPurple : AppTheme.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? AppTheme.accentPurple : AppTheme.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _reasons[index],
                          style: TextStyle(
                            color: isSelected ? AppTheme.accentPurple : AppTheme.textMain,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            _isSubmitting
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accentPurple))
                : PrimaryButton(
                    text: "Submit Report",
                    onTap: _submitReport,
                  ),
          ],
        ),
      ),
    );
  }
}
