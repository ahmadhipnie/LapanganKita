// import 'package:flutter/material.dart';

// class BorderInputField extends StatefulWidget {
//   final bool isLoading;
//   final Widget? prefixIcon;
//   final String? hint;
//   final String? label;
//   final TextInputType? keyType;
//   final int? maxLength;
//   final bool? isPassword;
//   final bool? ischanged;
//   final String? Function(String?)? validator;
//   final TextEditingController? controller;
//   final double? hintSize;
//   final double? fontSize;
//   final FontWeight? hintWeight;
//   final FontWeight? fontWeight;
//   final TextAlign? textAlign;

//   const BorderInputField({
//     super.key,
//     required this.isLoading,
//     this.prefixIcon,
//     this.hint,
//     this.label,
//     this.keyType,
//     this.maxLength,
//     this.isPassword,
//     this.validator,
//     this.controller,
//     this.hintSize,
//     this.hintWeight,
//     this.ischanged,
//     this.fontSize,
//     this.fontWeight,
//     this.textAlign,
//   });

//   @override
//   State<BorderInputField> createState() => _BorderInputFieldState();
// }

// class _BorderInputFieldState extends State<BorderInputField> {
//   var textLength = 0;

//   bool showPassword = false;
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       style: TextStyle(
//         fontSize: widget.fontSize ?? 24,
//         fontWeight: widget.fontWeight ?? FontWeight.bold,
//       ),
//       textAlign: widget.textAlign ?? TextAlign.center,
//       controller: widget.controller,
//       validator: widget.validator,
//       obscuringCharacter: '*',
//       keyboardType: widget.keyType,
//       enabled: !widget.isLoading,
//       maxLength: widget.maxLength,
//       obscureText: widget.isPassword == true ? !showPassword : false,
//       decoration: InputDecoration(
//         suffixIcon: widget.isPassword == true
//             ? GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     showPassword = !showPassword;
//                   });
//                 },
//                 child: Icon(
//                   showPassword ? Icons.visibility : Icons.visibility_off,
//                   color: Colors.lightBlue,
//                 ),
//               )
//             : null,
//         counterText: '',
//         contentPadding: const EdgeInsets.all(10),
//         prefixIcon: widget.prefixIcon,
//         filled: true,
//         fillColor: Colors.white,
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Color(0xFF2563EB)),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.redAccent),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(color: Colors.redAccent),
//         ),
//         hintText: widget.hint,
//         hintStyle: TextStyle(
//           color: Colors.grey.shade400,
//           fontSize: widget.hintSize ?? 16,
//           fontWeight: widget.hintWeight ?? FontWeight.w500,
//         ),
//         labelText: widget.label,
//       ),
//       onChanged: widget.ischanged == true
//           ? (val) {
//               if (val.length == 1) {
//                 FocusScope.of(context).nextFocus();
//               } else if (val.length != 1) {
//                 FocusScope.of(context).previousFocus();
//               }
//             }
//           : null,
//     );
//   }
// }

// border_input_field.dart
import 'package:flutter/material.dart';

class BorderInputField extends StatelessWidget {
  final bool isLoading;
  final Widget? prefixIcon;
  final String? hint;
  final String? label;
  final TextInputType? keyType;
  final int? maxLength;
  final bool? isPassword;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final double? hintSize;
  final double? fontSize;
  final FontWeight? hintWeight;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const BorderInputField({
    super.key,
    required this.isLoading,
    this.prefixIcon,
    this.hint,
    this.label,
    this.keyType,
    this.maxLength,
    this.isPassword,
    this.validator,
    this.controller,
    this.hintSize,
    this.hintWeight,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: fontSize ?? 24,
        fontWeight: fontWeight ?? FontWeight.bold,
      ),
      textAlign: textAlign ?? TextAlign.center,
      controller: controller,
      validator: validator,
      obscuringCharacter: '*',
      keyboardType: keyType,
      enabled: !isLoading,
      maxLength: maxLength,
      obscureText: isPassword == true,
      decoration: InputDecoration(
        suffixIcon: isPassword == true
            ? const Icon(Icons.visibility, color: Colors.lightBlue)
            : null,
        counterText: '',
        contentPadding: const EdgeInsets.all(10),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2563EB)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: hintSize ?? 16,
          fontWeight: hintWeight ?? FontWeight.w500,
        ),
        labelText: label,
      ),
    );
  }
}
