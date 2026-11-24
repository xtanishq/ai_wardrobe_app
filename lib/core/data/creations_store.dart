import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

class Creation {
  final String imageUrl;
  final String featureLabel;
  final DateTime date;

  Creation({
    required this.imageUrl,
    required this.featureLabel,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
        'featureLabel': featureLabel,
        'date': date.toIso8601String(),
      };

  factory Creation.fromJson(Map<String, dynamic> json) {
    return Creation(
      imageUrl: json['imageUrl'] as String,
      featureLabel: json['featureLabel'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class CreationsStore {
  static final CreationsStore _instance = CreationsStore._internal();
  factory CreationsStore() => _instance;
  CreationsStore._internal();

  List<Creation> creations = [];

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final creationsStr = prefs.getString('creations_data');
      if (creationsStr == null || creationsStr.isEmpty) {
        creations = [];
        return;
      }

      final decoded = jsonDecode(creationsStr);
      if (decoded is! List) {
        throw const FormatException('Saved creations must be a list.');
      }

      final restored = <Creation>[];
      for (final item in decoded.whereType<Map>()) {
        try {
          restored.add(Creation.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {
          // Keep valid creations when one legacy entry is malformed.
        }
      }
      creations = restored;
    } catch (error, stackTrace) {
      creations = [];
      AppLogger.warning(
        'Saved creations could not be restored and were reset',
        error,
        stackTrace,
      );
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('creations_data');
      } catch (_) {
        // Startup must continue even if local storage is unavailable.
      }
    }
  }

  Future<void> addCreation(Creation creation) async {
    creations.insert(0, creation);
    try {
      await _saveData();
    } catch (_) {
      creations.remove(creation);
      rethrow;
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
        jsonEncode(creations.map((e) => e.toJson()).toList());
    await prefs.setString('creations_data', encoded);
  }
}
