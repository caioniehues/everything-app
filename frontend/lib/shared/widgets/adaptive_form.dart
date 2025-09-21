import 'package:flutter/material.dart';

import 'responsive_builder.dart';

/// Adaptive form layout that adjusts field organization and spacing
class AdaptiveForm extends StatelessWidget {
  final GlobalKey<FormState>? formKey;
  final List<Widget> children;
  final EdgeInsets? padding;
  final double? spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const AdaptiveForm({
    required this.children, super.key,
    this.formKey,
    this.padding,
    this.spacing,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final deviceType = ResponsiveUtils.getDeviceType(context);

        // Adaptive spacing
        final double effectiveSpacing = spacing ?? _getDefaultSpacing(deviceType);

        // Create spaced children
        final spacedChildren = <Widget>[];
        for (int i = 0; i < children.length; i++) {
          spacedChildren.add(children[i]);
          if (i < children.length - 1) {
            spacedChildren.add(SizedBox(height: effectiveSpacing));
          }
        }

        Widget form = Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          children: spacedChildren,
        );

        if (formKey != null) {
          form = Form(
            key: formKey,
            child: form,
          );
        }

        return Padding(
          padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
          child: form,
        );
      },
    );
  }

  double _getDefaultSpacing(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 20;
      case DeviceType.desktop:
        return 24;
    }
  }
}

/// Adaptive form row that arranges fields horizontally on larger screens
class AdaptiveFormRow extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const AdaptiveFormRow({
    required this.children, super.key,
    this.spacing,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final deviceType = ResponsiveUtils.getDeviceType(context);

        // On mobile, arrange vertically
        if (deviceType == DeviceType.mobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        }

        // On tablet/desktop, arrange horizontally
        final double effectiveSpacing = spacing ?? 16;

        final spacedChildren = <Widget>[];
        for (int i = 0; i < children.length; i++) {
          spacedChildren.add(Expanded(child: children[i]));
          if (i < children.length - 1) {
            spacedChildren.add(SizedBox(width: effectiveSpacing));
          }
        }

        return Row(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          children: spacedChildren,
        );
      },
    );
  }
}

/// Adaptive text field with platform-specific styling
class AdaptiveTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool enabled;
  final VoidCallback? onTap;
  final Function(String)? onChanged;

  const AdaptiveTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final theme = Theme.of(context);
        final deviceType = ResponsiveUtils.getDeviceType(context);

        // Adaptive padding
        EdgeInsets contentPadding;
        switch (deviceType) {
          case DeviceType.mobile:
            contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
            break;
          case DeviceType.tablet:
            contentPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18);
            break;
          case DeviceType.desktop:
            contentPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
            break;
        }

        return TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          enabled: enabled,
          onTap: onTap,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: contentPadding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Adaptive button that adjusts size and spacing
class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const AdaptiveButton({
    required this.text, super.key,
    this.onPressed,
    this.type = ButtonType.filled,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final deviceType = ResponsiveUtils.getDeviceType(context);

        // Adaptive sizing
        Size buttonSize;
        switch (deviceType) {
          case DeviceType.mobile:
            buttonSize = const Size.fromHeight(48);
            break;
          case DeviceType.tablet:
            buttonSize = const Size.fromHeight(52);
            break;
          case DeviceType.desktop:
            buttonSize = const Size.fromHeight(56);
            break;
        }

        Widget button = _buildButton(context, buttonSize);

        if (width != null) {
          button = SizedBox(width: width, child: button);
        }

        return button;
      },
    );
  }

  Widget _buildButton(BuildContext context, Size size) {
    final content = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    switch (type) {
      case ButtonType.filled:
        return FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            minimumSize: size,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: content,
        );
      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: size,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: content,
        );
      case ButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            minimumSize: size,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: content,
        );
    }
  }
}

enum ButtonType {
  filled,
  outlined,
  text,
}

/// Adaptive button bar that arranges buttons based on screen size
class AdaptiveButtonBar extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment alignment;
  final double? spacing;

  const AdaptiveButtonBar({
    required this.children, super.key,
    this.alignment = MainAxisAlignment.end,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final deviceType = ResponsiveUtils.getDeviceType(context);

        final double effectiveSpacing = spacing ?? 12;

        // On mobile, stack buttons vertically if more than 2
        if (deviceType == DeviceType.mobile && children.length > 2) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children
                .map((child) => Padding(
                      padding: EdgeInsets.only(bottom: effectiveSpacing),
                      child: child,
                    ))
                .toList(),
          );
        }

        // On tablet/desktop or mobile with ≤2 buttons, arrange horizontally
        return Row(
          mainAxisAlignment: alignment,
          children: children
              .map((child) => Padding(
                    padding: EdgeInsets.only(right: effectiveSpacing),
                    child: child,
                  ))
              .toList(),
        );
      },
    );
  }
}

/// Adaptive card for form sections
class AdaptiveFormCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? titleWidget;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const AdaptiveFormCard({
    required this.child, super.key,
    this.title,
    this.titleWidget,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenSize) {
        final theme = Theme.of(context);
        final deviceType = ResponsiveUtils.getDeviceType(context);

        // Adaptive elevation
        double elevation;
        switch (deviceType) {
          case DeviceType.mobile:
            elevation = 1;
            break;
          case DeviceType.tablet:
            elevation = 2;
            break;
          case DeviceType.desktop:
            elevation = 4;
            break;
        }

        return Card(
          margin: margin ?? ResponsiveUtils.getResponsiveMargin(context),
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null || titleWidget != null) ...[
                  titleWidget ??
                      Text(
                        title!,
                        style: theme.textTheme.titleLarge,
                      ),
                  const SizedBox(height: 16),
                ],
                child,
              ],
            ),
          ),
        );
      },
    );
  }
}