import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Centralized snackbar utility.
///
/// Usage:
/// ```dart
/// AppSnackbar.error(context, 'Some internal error');
/// AppSnackbar.success(context, 'Image saved!');
/// AppSnackbar.info(context, 'Please select an image first.');
/// ```
class AppSnackbar {
  AppSnackbar._();

  // ── Error — generation failed / server error ─────────────────
  static void error(BuildContext context, [String? rawError]) {
    _show(
      context,
      message: _friendlyError(rawError),
      icon: Icons.error_outline_rounded,
      iconColor: const Color(0xFFFF6B6B),
      borderColor: const Color(0xFFFF6B6B),
    );
  }

  // ── Success ──────────────────────────────────────────────────
  static void success(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      iconColor: const Color(0xFF4ADE80),
      borderColor: const Color(0xFF4ADE80),
    );
  }

  // ── Info / validation ────────────────────────────────────────
  static void info(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_outline_rounded,
      iconColor: AppTheme.accentPurple,
      borderColor: AppTheme.accentPurple,
    );
  }

  // ── Core builder ─────────────────────────────────────────────
  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          duration: const Duration(seconds: 4),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfacePrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor.withOpacity(0.4), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: AppTheme.textMain,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  // ── Maps raw server/exception errors → user-friendly messages ─
  static String _friendlyError(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    final msg = raw.toLowerCase();

    if (msg.contains('image selection')) {
      return 'Could not open the selected image. Please try another photo.';
    }

    if (msg.contains('configuration') || msg.contains('remote config')) {
      return 'AI service setup is unavailable. Please restart the app and try again.';
    }

    // Network / connectivity
    if (msg.contains('socketexception') ||
        msg.contains('network') ||
        msg.contains('connection') ||
        msg.contains('no internet') ||
        msg.contains('failed host lookup')) {
      return 'No internet connection. Please check your network and try again.';
    }

    // Timeout
    if (msg.contains('timeout') || msg.contains('timed out')) {
      return 'Request timed out. Please try again.';
    }

    // Unauthorized / token
    if (msg.contains('401') ||
        msg.contains('403') ||
        msg.contains('authentication') ||
        msg.contains('unauthorized') ||
        msg.contains('forbidden')) {
      return 'AI service authentication failed. Please try again later.';
    }

    // Server errors
    if (msg.contains('500') ||
        msg.contains('502') ||
        msg.contains('503') ||
        msg.contains('server error')) {
      return 'Server is temporarily unavailable. Please try again later.';
    }

    // Rate limit
    if (msg.contains('429') ||
        msg.contains('too many requests') ||
        msg.contains('rate limit')) {
      return 'Too many requests. Please wait a moment and try again.';
    }

    // Provider quota exhausted
    if (msg.contains('credit') ||
        msg.contains('quota') ||
        msg.contains('limit exceeded')) {
      return 'The AI service limit has been reached. Please try again later.';
    }

    // Image issues
    if (msg.contains('image') &&
        (msg.contains('invalid') ||
            msg.contains('unsupported') ||
            msg.contains('corrupt'))) {
      return 'Invalid image format. Please try a different photo.';
    }

    // Generic fallback — never show raw internal error to user
    return 'Generation failed. Please try again.';
  }
}
