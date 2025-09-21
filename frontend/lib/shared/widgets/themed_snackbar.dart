import 'package:flutter/material.dart';

/// Snackbar types for different message contexts
enum SnackbarType {
  info,
  success,
  warning,
  error,
}

/// Extension to get colors for snackbar types
extension SnackbarTypeColors on SnackbarType {
  Color get backgroundColor {
    switch (this) {
      case SnackbarType.info:
        return Colors.blue.shade50;
      case SnackbarType.success:
        return Colors.green.shade50;
      case SnackbarType.warning:
        return Colors.orange.shade50;
      case SnackbarType.error:
        return Colors.red.shade50;
    }
  }

  Color get foregroundColor {
    switch (this) {
      case SnackbarType.info:
        return Colors.blue.shade900;
      case SnackbarType.success:
        return Colors.green.shade900;
      case SnackbarType.warning:
        return Colors.orange.shade900;
      case SnackbarType.error:
        return Colors.red.shade900;
    }
  }

  IconData get icon {
    switch (this) {
      case SnackbarType.info:
        return Icons.info_outline;
      case SnackbarType.success:
        return Icons.check_circle_outline;
      case SnackbarType.warning:
        return Icons.warning_amber_outlined;
      case SnackbarType.error:
        return Icons.error_outline;
    }
  }
}

/// Custom themed snackbar with consistent styling
class ThemedSnackbar {
  ThemedSnackbar._();

  /// Show a themed snackbar
  static void show({
    required BuildContext context,
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              type.icon,
              color: type.foregroundColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: type.foregroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: type.backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: type.foregroundColor.withOpacity(0.2),
          ),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
        action: action,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.success,
      duration: duration,
      action: action,
    );
  }

  /// Show error snackbar
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 5),
    SnackBarAction? action,
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.error,
      duration: duration,
      action: action,
    );
  }

  /// Show warning snackbar
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.warning,
      duration: duration,
      action: action,
    );
  }

  /// Show info snackbar
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      context: context,
      message: message,
      duration: duration,
      action: action,
    );
  }
}

/// Snackbar with dismiss button
class DismissibleSnackbar extends StatelessWidget {
  final String message;
  final SnackbarType type;
  final VoidCallback? onDismiss;

  const DismissibleSnackbar({
    required this.message, super.key,
    this.type = SnackbarType.info,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: type.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: type.foregroundColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            type.icon,
            color: type.foregroundColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: type.foregroundColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss ?? () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            icon: Icon(
              Icons.close,
              color: type.foregroundColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating snackbar that stays on screen
class FloatingSnackbar extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final VoidCallback? onDismiss;
  final Duration autoHideDuration;

  const FloatingSnackbar({
    required this.message, super.key,
    this.type = SnackbarType.info,
    this.onDismiss,
    this.autoHideDuration = const Duration(seconds: 5),
  });

  @override
  State<FloatingSnackbar> createState() => _FloatingSnackbarState();
}

class _FloatingSnackbarState extends State<FloatingSnackbar> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    if (widget.autoHideDuration != Duration.zero) {
      Future.delayed(widget.autoHideDuration, () {
        if (mounted && _isVisible) {
          _hide();
        }
      });
    }
  }

  void _hide() {
    setState(() {
      _isVisible = false;
    });
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: DismissibleSnackbar(
          message: widget.message,
          type: widget.type,
          onDismiss: _hide,
        ),
      ),
    );
  }
}
