class HairStyleModel {
  final int id;
  final String styleName;
  final String displayUrl;
  final List<String> tags;

  HairStyleModel({
    required this.id,
    required this.styleName,
    required this.displayUrl,
    required this.tags,
  });

  factory HairStyleModel.fromJson(Map<String, dynamic> json) {
    return HairStyleModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      styleName: json['styleName'] ?? '',
      displayUrl: json['displayUrl'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
