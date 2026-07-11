class SystemSettingModel {
  const SystemSettingModel({
    required this.key,
    required this.value,
    required this.description,
  });

  final String key;
  final String value;
  final String description;

  bool get boolValue => value.toLowerCase() == 'true';

  factory SystemSettingModel.fromJson(Map<String, dynamic> json) {
    return SystemSettingModel(
      key: (json['key'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }
}
