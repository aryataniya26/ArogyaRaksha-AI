import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;
  final Gradient? gradient;
  final bool isOutlined;
  final Color? borderColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.icon,
    this.gradient,
    this.isOutlined = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? Theme.of(context).primaryColor,
            side: BorderSide(
              color: borderColor ?? Theme.of(context).primaryColor,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? Theme.of(context).primaryColor,
              ),
            ),
          )
              : _buildButtonContent(),
        ),
      );
    }

    if (gradient != null) {
      return Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: textColor ?? Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : _buildButtonContent(),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          foregroundColor: textColor ?? Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import '../../core/constants/app_colors.dart';
//
// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   final bool isOutlined;
//   final bool isLoading;
//   final Gradient? gradient;
//   final Color? backgroundColor;
//   final Color? textColor;
//   final Color? borderColor;
//   final double? width;
//   final double height;
//   final double borderRadius;
//   final IconData? icon;
//   final bool isDisabled;
//
//   const CustomButton({
//     super.key,
//     required this.text,
//     required this.onPressed,
//     this.isOutlined = false,
//     this.isLoading = false,
//     this.gradient,
//     this.backgroundColor,
//     this.textColor,
//     this.borderColor,
//     this.width,
//     this.height = 54,
//     this.borderRadius = 12,
//     this.icon,
//     this.isDisabled = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (isOutlined) {
//       return _buildOutlinedButton(context);
//     }
//     return _buildGradientButton(context);
//   }
//
//   Widget _buildGradientButton(BuildContext context) {
//     return Container(
//       width: width ?? double.infinity,
//       height: height,
//       decoration: BoxDecoration(
//         gradient: isDisabled
//             ? LinearGradient(
//           colors: [
//             AppColors.backgroundGrey,
//             AppColors.backgroundGrey,
//           ],
//         )
//             : gradient ?? AppColors.primaryGradient,
//         borderRadius: BorderRadius.circular(borderRadius),
//         boxShadow: isDisabled
//             ? null
//             : [
//           BoxShadow(
//             color: (gradient?.colors.first ?? AppColors.primaryTeal)
//                 .withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: isDisabled || isLoading ? null : onPressed,
//           borderRadius: BorderRadius.circular(borderRadius),
//           child: Center(
//             child: isLoading
//                 ? const SizedBox(
//               width: 24,
//               height: 24,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2.5,
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   AppColors.white,
//                 ),
//               ),
//             )
//                 : Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (icon != null) ...[
//                   Icon(
//                     icon,
//                     color: textColor ?? AppColors.white,
//                     size: 20,
//                   ),
//                   const SizedBox(width: 8),
//                 ],
//                 Text(
//                   text,
//                   style:
//                   Theme.of(context).textTheme.labelLarge?.copyWith(
//                     color: textColor ?? AppColors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOutlinedButton(BuildContext context) {
//     return Container(
//       width: width ?? double.infinity,
//       height: height,
//       decoration: BoxDecoration(
//         color: backgroundColor ?? Colors.transparent,
//         borderRadius: BorderRadius.circular(borderRadius),
//         border: Border.all(
//           color: isDisabled
//               ? AppColors.backgroundGrey
//               : (borderColor ?? AppColors.primaryTeal),
//           width: 2,
//         ),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: isDisabled || isLoading ? null : onPressed,
//           borderRadius: BorderRadius.circular(borderRadius),
//           child: Center(
//             child: isLoading
//                 ? SizedBox(
//               width: 24,
//               height: 24,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2.5,
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   textColor ?? AppColors.primaryTeal,
//                 ),
//               ),
//             )
//                 : Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (icon != null) ...[
//                   Icon(
//                     icon,
//                     color: isDisabled
//                         ? AppColors.textLight
//                         : (textColor ?? AppColors.primaryTeal),
//                     size: 20,
//                   ),
//                   const SizedBox(width: 8),
//                 ],
//                 Text(
//                   text,
//                   style:
//                   Theme.of(context).textTheme.labelLarge?.copyWith(
//                     color: isDisabled
//                         ? AppColors.textLight
//                         : (textColor ?? AppColors.primaryTeal),
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }