import 'package:flutter/material.dart';
import '../AppColors/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final String? labelText;
  final String? initialValue;
  final TextInputAction? textInputAction;
  final bool autoFocus;
  final FocusNode? focusNode;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final String? obscuringCharacter;
  final bool enableInteractiveSelection;
  final TextCapitalization textCapitalization;
  final double? prefixIconSize;
  final double? suffixIconSize;
  final VoidCallback? onSuffixIconPressed;
  final bool showPasswordToggle;
  final Color? borderColor;
  final double borderRadius;
  final Color? iconColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? labelColor;
  final Color? cursorColor;
  final bool showShadow;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.labelText,
    this.initialValue,
    this.textInputAction,
    this.autoFocus = false,
    this.focusNode,
    this.fillColor,
    this.contentPadding,
    this.hintStyle,
    this.style,
    this.obscuringCharacter = '*',
    this.enableInteractiveSelection = true,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIconSize,
    this.suffixIconSize,
    this.onSuffixIconPressed,
    this.showPasswordToggle = true,
    this.borderColor,
    this.borderRadius = 10.0,
    this.iconColor,
    this.textColor,
    this.hintColor,
    this.labelColor,
    this.cursorColor,
    this.showShadow = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.showShadow
          ? BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      )
          : null,
      child: TextFormField(

        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText && !_showPassword,
        obscuringCharacter: widget.obscuringCharacter!,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        readOnly: widget.readOnly,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        initialValue: widget.initialValue,
        textInputAction: widget.textInputAction,
        autofocus: widget.autoFocus,
        focusNode: widget.focusNode,
        style: widget.style ??
            TextStyle(
              color: widget.textColor ?? Colors.black,
            ),
        cursorColor: widget.cursorColor ?? AppColors.appColor,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        textCapitalization: widget.textCapitalization,
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.fillColor ?? Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: widget.borderColor ?? Colors.transparent,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: widget.borderColor ?? Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: widget.borderColor ?? AppColors.appColor,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
          hintText: widget.hintText,
          hintStyle: widget.hintStyle ??
              TextStyle(
                color: widget.hintColor ?? Colors.grey[600],
              ),
          labelText: widget.labelText,
          labelStyle: TextStyle(
            color: widget.labelColor ?? Colors.grey[600],
          ),
          prefixIcon: Icon(
            widget.prefixIcon,
            color: widget.iconColor ?? Colors.grey[600],
            size: widget.prefixIconSize,
          ),
          suffixIcon: _buildSuffixIcon(),
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    // If custom suffix icon is provided
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: widget.iconColor ?? Colors.grey[600],
          size: widget.suffixIconSize,
        ),
        onPressed: widget.onSuffixIconPressed,
        padding: EdgeInsets.zero,
      );
    }
    // If it's a password field and toggle is enabled
    else if (widget.obscureText && widget.showPasswordToggle) {
      return IconButton(
        icon: Icon(
          _showPassword ? Icons.visibility : Icons.visibility_off,
          color: widget.iconColor ?? Colors.grey[600],
        ),
        onPressed: () {
          setState(() {
            _showPassword = !_showPassword;
          });
        },
        padding: EdgeInsets.zero,
      );
    }
    return null;
  }
}