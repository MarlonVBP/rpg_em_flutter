import 'package:teste/models/character_model.dart';

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
}