import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final TextEditingController? controller;
  final String? errorMessage;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onTogglePassword;
  final VoidCallback? onClear;
  final IconData? prefixIcon;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;

  const AppTextField({
    super.key,
    required this.label,
    this.placeholder,
    this.controller,
    this.errorMessage,
    this.isPassword = false,
    this.obscureText = false,
    this.onTogglePassword,
    this.onClear,
    this.prefixIcon,
    this.maxLength,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;

    // Sin error se usan los bordes del tema. Con un error del servidor, el
    // borde pasa a Rosa Oscuro, como en Stitch.
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colorScheme.error, width: 2),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(prefixIcon, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            if (maxLength != null && controller != null)
              ValueListenableBuilder(
                valueListenable: controller!,
                builder: (context, value, _) {
                  return Text(
                    '${value.text.length}/$maxLength',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.secondary,
                    ),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          maxLength: maxLength,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          validator: validator,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            counterText: '',
            enabledBorder: hasError ? errorBorder : null,
            focusedBorder: hasError ? errorBorder : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: colorScheme.secondary,
                    ),
                    onPressed: onTogglePassword,
                  )
                : (onClear != null && (controller?.text.isNotEmpty ?? false))
                ? IconButton(
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: colorScheme.secondary,
                      size: 20,
                    ),
                    onPressed: onClear,
                  )
                : null,
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.error_outline, size: 16, color: colorScheme.error),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
