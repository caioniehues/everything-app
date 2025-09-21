import 'package:flutter/material.dart';

/// Branded loading indicator with Everything App styling
/// Features animated logo and consistent theming
class BrandedLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final String? message;
  final bool showMessage;
  final Duration animationDuration;

  const BrandedLoadingIndicator({
    super.key,
    this.size = 48.0,
    this.color,
    this.message,
    this.showMessage = true,
    this.animationDuration = const Duration(seconds: 2),
  });

  @override
  State<BrandedLoadingIndicator> createState() => _BrandedLoadingIndicatorState();
}

class _BrandedLoadingIndicatorState extends State<BrandedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.2)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = widget.color ?? theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: effectiveColor.withOpacity(0.1),
                      border: Border.all(
                        color: effectiveColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: widget.size * 0.6,
                      color: effectiveColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.showMessage && widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Compact version for inline use
class CompactBrandedLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const CompactBrandedLoadingIndicator({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );
  }
}

/// Full-screen loading overlay
class FullScreenLoading extends StatelessWidget {
  final String? message;
  final bool dismissible;

  const FullScreenLoading({
    super.key,
    this.message = 'Loading...',
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
      child: Center(
        child: BrandedLoadingIndicator(
          message: message,
          size: 64,
        ),
      ),
    );
  }
}
