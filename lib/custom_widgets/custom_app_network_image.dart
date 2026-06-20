import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'custom_colors.dart';

class AppNetworkImage extends StatelessWidget {
  final String? image;
  final double? height;
  final double? width;
  final Widget? errorWidget;
  final Widget? placeholder;
  final BoxFit? fit;

  const AppNetworkImage({
    super.key,
    this.image,
    this.height,
    this.width,
    this.errorWidget,
    this.placeholder,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fit: fit ?? BoxFit.cover,
      height: height,
      width: width,
      placeholder: (context, url) =>
      placeholder ??
          Center(
              child: LoadingAnimationWidget.threeRotatingDots(
                  color: MyColors.kAppThemeColor, size: 20)

          ),
      errorWidget: (context, url, error) =>
      errorWidget ??
          const Icon(
            Icons.error,
            color: Colors.red,
          ),
      imageUrl: image ?? '',
    );
  }
}