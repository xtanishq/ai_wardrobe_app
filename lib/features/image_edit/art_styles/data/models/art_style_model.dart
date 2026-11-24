class ArtStyleModel {
  final int id;
  final String style;
  final String displayUrl;
  final List<String> tags;

  ArtStyleModel({
    required this.id,
    required this.style,
    required this.displayUrl,
    required this.tags,
  });

  factory ArtStyleModel.fromJson(Map<String, dynamic> json) {
    return ArtStyleModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      style: json['style'] ?? '',
      displayUrl: json['displayUrl'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
