import 'dart:convert';
import 'dart:math';
import 'package:teste/models/item_model.dart';

class GameCharacter {
  final String name;
  final String texturePath;
  int maxHp;
  int currentHp;
  int maxMana;
  int currentMana;
  int attack;
  int defense;
  int xp;
  int level;

  GameCharacter({
    required this.name,
    required this.texturePath,
    this.maxHp = 100,
    this.currentHp = 100,
    this.maxMana = 50,
    this.currentMana = 50,
    this.attack = 10,
    this.defense = 5,
    this.xp = 0,
    this.level = 1,
  });
}

class HeroCharacter extends GameCharacter {
  final String heroClass;
  int xpToNextLevel;
  static const int maxLevel = 50;

  HeroCharacter({
    required String name,
    required String texturePath,
    required this.heroClass,
  })  : xpToNextLevel = 100,
        super(name: name, texturePath: texturePath);

  void restoreStats() {
    currentHp = maxHp;
    currentMana = maxMana;
  }

  void levelUp() {
    if (level >= maxLevel) {
      xp = 0;
      return;
    }

    level++;
    xp = xp - xpToNextLevel;

    maxHp += (15 * (level / 5)).round();
    attack += (3 * (level / 10)).round() + 1;
    defense += (2 * (level / 10)).round() + 1;
    maxMana += (10 * (level / 8)).round();

    xpToNextLevel = (100 * pow(1.15, level - 1)).round();

    restoreStats();
  }

  factory HeroCharacter.clone(HeroCharacter source) {
    return HeroCharacter(
      name: source.name,
      texturePath: source.texturePath,
      heroClass: source.heroClass,
    )
      ..maxHp = source.maxHp
      ..currentHp = source.currentHp
      ..maxMana = source.maxMana
      ..currentMana = source.currentMana
      ..attack = source.attack
      ..defense = source.defense
      ..xp = source.xp
      ..level = source.level;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'texturePath': texturePath,
        'heroClass': heroClass,
        'maxHp': maxHp,
        'currentHp': currentHp,
        'maxMana': maxMana,
        'currentMana': currentMana,
        'attack': attack,
        'defense': defense,
        'xp': xp,
        'level': level,
        'xpToNextLevel': xpToNextLevel,
      };

  factory HeroCharacter.fromJson(Map<String, dynamic> json) {
    return HeroCharacter(
      name: json['name'],
      texturePath: json['texturePath'],
      heroClass: json['heroClass'],
    )
      ..maxHp = json['maxHp']
      ..currentHp = json['currentHp']
      ..maxMana = json['maxMana']
      ..currentMana = json['currentMana']
      ..attack = json['attack']
      ..defense = json['defense']
      ..xp = json['xp']
      ..level = json['level']
      ..xpToNextLevel = json['xpToNextLevel'];
  }
}

class EnemyCharacter extends GameCharacter {
  final int xpReward;
  final int goldReward;
  final List<GameItem> lootTable;

  EnemyCharacter({
    required String name,
    required String texturePath,
    int hp = 200,
    int attack = 15,
    int defense = 3,
    this.xpReward = 50,
    this.goldReward = 10,
    this.lootTable = const [],
  }) : super(
            name: name,
            texturePath: texturePath,
            maxHp: hp,
            currentHp: hp,
            attack: attack,
            defense: defense,
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
}
