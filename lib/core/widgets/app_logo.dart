import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_assets.dart';

class AppLogo extends StatelessWidget {
  final double width;
  final double height;
  final BoxFit fit;

  const AppLogo({
    super.key,
    required this.width,
    required this.height,
    this.fit = BoxFit.contain,
  });

  factory AppLogo.small({Key? key, BoxFit fit = BoxFit.contain}) {
    return AppLogo(
      key: key,
      width: 48.w,
      height: 48.h,
      fit: fit,
    );
  }

  factory AppLogo.medium({Key? key, BoxFit fit = BoxFit.contain}) {
    return AppLogo(
      key: key,
      width: 96.w,
      height: 96.h,
      fit: fit,
    );
  }

  factory AppLogo.large({Key? key, BoxFit fit = BoxFit.contain}) {
    return AppLogo(
      key: key,
      width: 144.w,
      height: 144.h,
      fit: fit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.appLogo,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }
}
