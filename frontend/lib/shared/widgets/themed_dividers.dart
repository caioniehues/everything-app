import 'package:flutter/material.dart';

/// Custom themed dividers with consistent styling
class ThemedDividers {
  ThemedDividers._();

  /// Standard divider with theme colors
  static Widget standard({double indent = 0, double endIndent = 0}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Divider(
          color: theme.colorScheme.outlineVariant,
          thickness: 1,
          indent: indent,
          endIndent: endIndent,
        );
      },
    );
  }

  /// Thick divider for section separation
  static Widget thick({double indent = 0, double endIndent = 0}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Divider(
          color: theme.colorScheme.outline,
          thickness: 2,
          indent: indent,
          endIndent: endIndent,
        );
      },
    );
  }

  /// Dotted divider for subtle separation
  static Widget dotted({double indent = 0, double endIndent = 0}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          margin: EdgeInsetsDirectional.only(start: indent, end: endIndent),
          child: CustomPaint(
            painter: _DottedLinePainter(
              color: theme.colorScheme.outlineVariant,
            ),
            child: const SizedBox(
              height: 1,
              width: double.infinity,
            ),
          ),
        );
      },
    );
  }

  /// Gradient divider with primary colors
  static Widget gradient({double indent = 0, double endIndent = 0}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          margin: EdgeInsetsDirectional.only(start: indent, end: endIndent),
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.3),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Vertical divider for side-by-side layouts
  static Widget vertical({double width = 1}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return VerticalDivider(
          color: theme.colorScheme.outlineVariant,
          thickness: width,
          width: 16,
        );
      },
    );
  }

  /// Section divider with padding and rounded corners
  static Widget section({String? label, double indent = 16, double endIndent = 16}) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          margin: EdgeInsets.symmetric(horizontal: indent, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  color: theme.colorScheme.outline,
                  thickness: 1,
                ),
              ),
              if (label != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border.all(
                      color: theme.colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Divider(
                  color: theme.colorScheme.outline,
                  thickness: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter for dotted lines
class _DottedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  _DottedLinePainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + dashWidth, y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DottedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}

/// Adaptive divider that adjusts based on screen size
class AdaptiveDivider extends StatelessWidget {
  final double mobileThickness;
  final double tabletThickness;
  final double desktopThickness;
  final double indent;
  final double endIndent;

  const AdaptiveDivider({
    super.key,
    this.mobileThickness = 1,
    this.tabletThickness = 1.5,
    this.desktopThickness = 2,
    this.indent = 0,
    this.endIndent = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final deviceType = MediaQuery.of(context).size.width < 600
            ? 'mobile'
            : MediaQuery.of(context).size.width < 1200
                ? 'tablet'
                : 'desktop';

        double thickness;
        switch (deviceType) {
          case 'mobile':
            thickness = mobileThickness;
            break;
          case 'tablet':
            thickness = tabletThickness;
            break;
          case 'desktop':
            thickness = desktopThickness;
            break;
          default:
            thickness = mobileThickness;
        }

        return Divider(
          color: theme.colorScheme.outlineVariant,
          thickness: thickness,
          indent: indent,
          endIndent: endIndent,
        );
      },
    );
  }
}
