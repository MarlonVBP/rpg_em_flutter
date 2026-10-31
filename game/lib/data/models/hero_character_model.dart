import 'dart:math';

import 'package:teste/data/models/game_character_model.dart';

class HeroCharacter extends GameCharacter {
  final String heroClass;
  int xpToNextLevel;
  static const int maxLevel = 50;

  HeroCharacter({
    required super.name,
    required super.texturePath,
    required this.heroClass,
  }) : xpToNextLevel = 100;

  void restoreStats() {
    currentHp = maxHp;
    currentMana = maxMana;
  }

  void levelUp() {
    if (level >= maxLevel) {
      xp = 0;
      return;
    }

    while (xp >= xpToNextLevel && level < maxLevel) {
      level++;
      xp = xp - xpToNextLevel;

      maxHp += 25 + (level * 3);
      attack += 5 + (level ~/ 2);
      defense += 3 + (level ~/ 3);
      maxMana += 10;

      xpToNextLevel = (100 * pow(1.15, level - 1)).round();
    }

    if (level >= maxLevel) {
      xp = 0;
    }

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
      ..level = source.level
      ..xpToNextLevel = source.xpToNextLevel;
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
    final int level = json['level'] ?? 1;
    final int rawMaxHp = json['maxHp'] ?? 120;
    final int rawMaxMana = json['maxMana'] ?? 60;
    final int rawAttack = json['attack'] ?? 18;
    final int rawDefense = json['defense'] ?? 6;

    // Atualiza automaticamente heróis antigos que estavam com status base legados (100 HP / 10 ATK)
    final int balancedMaxHp = max(rawMaxHp, 120 + (level - 1) * 28);
    final int balancedMaxMana = max(rawMaxMana, 60 + (level - 1) * 10);
    final int balancedAttack = max(rawAttack, 18 + (level - 1) * 5);
    final int balancedDefense = max(rawDefense, 6 + (level - 1) * 3);

    final String rawTexture =
        (json['texturePath'] as String?) ?? 'images/warrior.webp';
    final String webpTexture =
        rawTexture.replaceAll(RegExp(r'\.(png|jpg)$'), '.webp');

    return HeroCharacter(
      name: json['name'],
      texturePath: webpTexture,
      heroClass: json['heroClass'],
    )
      ..maxHp = balancedMaxHp
      ..currentHp = balancedMaxHp
      ..maxMana = balancedMaxMana
      ..currentMana = balancedMaxMana
      ..attack = balancedAttack
      ..defense = balancedDefense
      ..xp = json['xp'] ?? 0
      ..level = level
      ..xpToNextLevel = json['xpToNextLevel'] ?? 100;
  }
}
