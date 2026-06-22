import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/avatar_utils.dart';

class UserAvatar extends StatelessWidget {
  final String imagePath;
  final double radius;

  const UserAvatar({
    super.key,
    required this.imagePath,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = resolveAvatarUrl(imagePath);

    ImageProvider provider;
    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      provider = CachedNetworkImageProvider(resolved);
    } else if (resolved.startsWith('assets/')) {
      provider = AssetImage(resolved);
    } else if (File(resolved).existsSync()) {
      provider = FileImage(File(resolved));
    } else {
      provider = const AssetImage(
        'assets/images/mahdi-chaghari-3xTP_gWUlrg-unsplash.jpg',
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: provider,
    );
  }
}
