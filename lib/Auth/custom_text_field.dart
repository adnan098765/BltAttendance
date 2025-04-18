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
    this.obscuringCharacter = "*",
    this.enableInteractiveSelection = true,
    this.textCapitalization = TextCapitalization.none,
    this.prefixIconSize,
    this.suffixIconSize,
    this.onSuffixIconPressed,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
        style: widget.style,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        textCapitalization: widget.textCapitalization,
        decoration: InputDecoration(
          filled: true,
          fillColor: widget.fillColor ?? Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AppColors.orangeShade,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
          hintText: widget.hintText,
          hintStyle: widget.hintStyle ?? TextStyle(color: Colors.grey[600]),
          labelText: widget.labelText,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(
            widget.prefixIcon,
            color: Colors.grey[600],
            size: widget.prefixIconSize,
          ),
          suffixIcon: _buildSuffixIcon(),
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 15,
              ),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: Colors.grey[600],
          size: widget.suffixIconSize,
        ),
        onPressed: widget.onSuffixIconPressed,
      );
    } else if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _showPassword ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey[600],
        ),
        onPressed: () {
          setState(() {
            _showPassword = !_showPassword;
          });
        },
      );
    }
    return null;
  }
}