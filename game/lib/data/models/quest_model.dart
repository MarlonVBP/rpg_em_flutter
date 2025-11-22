import 'package:teste/data/models/enemy_character_model.dart';

class Quest {
  final String id;
  final String title;
  final String description;
  final EnemyCharacter boss;
  bool isCompleted;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.boss,
    this.isCompleted = false,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Missão',
      description: json['description'] ?? '',
      boss: EnemyCharacter.fromJson(
        Map<String, dynamic>.from(json['boss'] ?? {}),
      ),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}