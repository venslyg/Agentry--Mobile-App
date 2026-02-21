import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 4)
class SettingsModel extends HiveObject {
  @HiveField(0)
  String languageCode; // 'en', 'si', 'ta'

  @HiveField(1)
  bool darkMode;

  SettingsModel({
    this.languageCode = 'en',
    this.darkMode = false,
  });
}
