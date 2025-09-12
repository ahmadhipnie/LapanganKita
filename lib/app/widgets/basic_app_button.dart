import 'package:flutter/material.dart';

class BasicAppButton extends StatelessWidget {
  final Future<void> Function()? onPressed;
  final String title;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? overlayColor;
  final FontWeight? fontWeight;
  final double? fontSize;
  final double? height;
  final double? width;
  final double? cornerRadius;

  const BasicAppButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.backgroundColor,
    this.height,
    this.width,
    this.textColor,
    this.cornerRadius,
    this.fontSize,
    this.fontWeight,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 150,
      height: height ?? 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Color(0xFF2563EB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius ?? 20),
          ),
          overlayColor: overlayColor ?? Colors.lightGreenAccent,
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: textColor ?? Colors.white,
            fontSize: fontSize ?? 20,
            fontWeight: fontWeight ?? FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
