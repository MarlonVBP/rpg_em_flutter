import 'package:teste/data/enums/card_action_type.dart';
import 'package:teste/data/models/item_model.dart';

class BattleCard {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final CardActionType type;
  final int manaCost;
  final GameItem? sourceItem;

  BattleCard({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.type,
    this.manaCost = 0,
    this.sourceItem,
  });
}