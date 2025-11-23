import 'package:teste/data/models/enemy_character_model.dart';

final allGameBosses = [
  EnemyCharacter(
      name: 'Dragão-Cospe-Fogo',
      texturePath: 'images/fire_dragon.png',
      hp: 300,
      attack: 25,
      xpReward: 100,
      goldReward: 100),
  EnemyCharacter(
      name: 'Goblin Traiçoeiro',
      texturePath: 'images/goblin.png',
      hp: 350,
      attack: 30,
      xpReward: 250,
      goldReward: 120),
  EnemyCharacter(
      name: 'Orc das Montanhas',
      texturePath: 'images/orc.png',
      hp: 400,
      attack: 40,
      xpReward: 250,
      goldReward: 150),
  EnemyCharacter(
      name: 'Bruxa Malvada',
      texturePath: 'images/witch.png',
      hp: 700,
      attack: 150,
      xpReward: 400,
      goldReward: 150),
  EnemyCharacter(
      name: 'Esqueleto Maldito',
      texturePath: 'images/skeleton.png',
      hp: 2500,
      attack: 200,
      xpReward: 400,
      goldReward: 150),
];
