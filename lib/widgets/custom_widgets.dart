import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isPassword;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.validator,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          readOnly: widget.readOnly,
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            labelText: widget.labelText,
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: widget.validator,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.padding,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppTheme.primaryColor,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        text,
        style: textStyle ?? const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}
