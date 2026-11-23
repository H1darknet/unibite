import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DishImage extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const DishImage({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder(context);
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (context, url, error) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(Icons.fastfood, size: 48, color: scheme.outline),
    );
  }
}