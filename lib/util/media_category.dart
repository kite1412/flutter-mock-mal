import 'dart:ui';

class MediaCategory {
  final int index;
  final String category;
  final String description;
  final String path;
  final List<Color> gradients;
  final Map<String, dynamic> queryParams;

  const MediaCategory({
    required this.index,
    required this.category,
    required this.description,
    required this.path,
    required this.gradients,
    required this.queryParams
  });
}