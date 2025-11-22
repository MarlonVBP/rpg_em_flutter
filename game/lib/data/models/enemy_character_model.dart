import 'package:teste/data/models/game_character_model.dart';
import 'package:teste/data/models/item_model.dart';


class EnemyCharacter extends GameCharacter {
  final int xpReward;
  final int goldReward;
  final List<GameItem> lootTable;

  EnemyCharacter({
    required super.name,
    required super.texturePath,
    int hp = 200,
    super.attack = 15,
    super.defense = 3,
    this.xpReward = 50,
    this.goldReward = 10,
    this.lootTable = const [],
  }) : super(
            maxHp: hp,
            currentHp: hp,
            maxMana: 0,
            currentMana: 0);

  factory EnemyCharacter.clone(EnemyCharacter source) {
    return EnemyCharacter(
      name: source.name,
      texturePath: source.texturePath,
      xpReward: source.xpReward,
      goldReward: source.goldReward,
      lootTable: source.lootTable,
    )
      ..maxHp = source.maxHp
      ..currentHp = source.currentHp
      ..attack = source.attack
      ..defense = source.defense;
  }

  factory EnemyCharacter.fromJson(Map<String, dynamic> json) {
    return EnemyCharacter(
      name: json['name'] ?? 'Inimigo',
      texturePath: json['texturePath'] ?? 'images/placeholder.png',
      hp: json['hp'] ?? 200,
      attack: json['attack'] ?? 15,
      defense: json['defense'] ?? 3,
      xpReward: json['xpReward'] ?? 50,
      goldReward: json['goldReward'] ?? 10,
      lootTable: [],
    );
  }
}
