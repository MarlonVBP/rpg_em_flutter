import 'package:teste/models/item_model.dart';

// Enum para os tipos de carta
enum CardActionType { attack, magic, item, skill }

class BattleCard {
  final String id; // Um ID único, ex: 'attack', 'fireball', 'health_potion'
  final String name;
  final String description;
  final String imagePath; // Arte da carta
  final CardActionType type;
  final int manaCost;
  final GameItem? sourceItem; // Se esta carta veio de um item (ex: poção)

  BattleCard({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.type,
    this.manaCost = 0,
    this.sourceItem, // A poção original
  });
}