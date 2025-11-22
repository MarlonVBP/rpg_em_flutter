import 'package:teste/data/models/enemy_character_model.dart';

final allGameBosses = [
  EnemyCharacter(
      name: 'Dragão-Cospe-Fogo',
      texturePath: 'images/fire_dragon.png',
      hp: 300,
      attack: 25,
      xpReward: 100,
      goldReward: 50),
  EnemyCharacter(
      name: 'Goblin Traiçoeiro',
      texturePath: 'images/goblin.png',
      hp: 200,
      attack: 10,
      xpReward: 250,
      goldReward: 120),
  EnemyCharacter(
      name: 'Orc das Montanhas',
      texturePath: 'images/orc.png',
      hp: 400,
      attack: 20,
      xpReward: 250,
      goldReward: 120),
  EnemyCharacter(
      name: 'Bruxa Malvada',
      texturePath: 'images/witch.png',
      hp: 60,
      attack: 15,
      xpReward: 250,
      goldReward: 120),
  EnemyCharacter(
      name: 'Esqueleto Maldito',
      texturePath: 'images/skeleton.png',
      hp: 250,
      attack: 15,
      xpReward: 250,
      goldReward: 120),
];
