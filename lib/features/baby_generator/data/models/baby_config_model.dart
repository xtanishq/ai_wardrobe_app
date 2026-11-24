class ConfigOption {
  final String id;
  final String label;

  ConfigOption({required this.id, required this.label});

  factory ConfigOption.fromJson(Map<String, dynamic> json) {
    return ConfigOption(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
    );
  }
}

class BabyConfigModel {
  final List<ConfigOption> genders;
  final List<ConfigOption> skins;

  BabyConfigModel({
    required this.genders,
    required this.skins,
  });

  factory BabyConfigModel.fromJson(Map<String, dynamic> json) {
    final parameters = json['parameters'] ?? {};
    
    final genderList = (parameters['gender'] as List?)
            ?.map((e) => ConfigOption.fromJson(e))
            .toList() ??
        [];
        
    final skinList = (parameters['skin'] as List?)
            ?.map((e) => ConfigOption.fromJson(e))
            .toList() ??
        [];

    return BabyConfigModel(
      genders: genderList,
      skins: skinList,
    );
  }
}
