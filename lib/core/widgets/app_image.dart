import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

bool estImageLocale(String value) => value.startsWith('data:');

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.value,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  final String value;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    if (estImageLocale(value)) {
      try {
        final separateur = value.indexOf(',');
        final encoded = separateur == -1 ? '' : value.substring(separateur + 1);
        return Image.memory(
          base64Decode(encoded),
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (context, _, _) =>
              errorWidget ?? const SizedBox.shrink(),
        );
      } catch (_) {
        return errorWidget ?? const SizedBox.shrink();
      }
    }

    return CachedNetworkImage(
      imageUrl: value,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, _) => placeholder ?? const SizedBox.shrink(),
      errorWidget: (context, _, _) => errorWidget ?? const SizedBox.shrink(),
    );
  }
}
