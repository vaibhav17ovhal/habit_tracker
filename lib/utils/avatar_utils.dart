

import '../services/api_urls.dart';

/// Resolves avatar paths from API (relative URL, absolute URL, or asset).
String resolveAvatarUrl(String avatarPath) {
  if (avatarPath.isEmpty) {
    return 'assets/images/mahdi-chaghari-3xTP_gWUlrg-unsplash.jpg';
  }
  if (avatarPath.startsWith('assets/')) return avatarPath;
  if (avatarPath.startsWith('http://') || avatarPath.startsWith('https://')) {
    return avatarPath;
  }
  if (avatarPath.startsWith('/')) {
    return '${ApiUrls.baseUrl}$avatarPath';
  }
  return avatarPath;
}

bool isNetworkAvatar(String avatarPath) {
  final resolved = resolveAvatarUrl(avatarPath);
  return resolved.startsWith('http://') || resolved.startsWith('https://');
}
