import 'package:teste/data/local/all_game_items.dart';
import 'package:teste/data/models/enemy_character_model.dart';

final allGameBosses = [
  EnemyCharacter(
    name: 'Dragão-Cospe-Fogo',
    texturePath: 'images/fire_dragon.webp',
    hp: 240,
    attack: 26,
    defense: 6,
    xpReward: 220,
    goldReward: 160,
    lootTable: [
      allGameItems[1], // Poção Grande
      allGameItems[3], // Espada Longa
      allGameItems[10], // Cajado Místico
    ],
  ),
  EnemyCharacter(
    name: 'Goblin Traiçoeiro',
    texturePath: 'images/goblin.webp',
    hp: 110,
    attack: 14,
    defense: 2,
    xpReward: 100,
    goldReward: 75,
    lootTable: [
      allGameItems[0], // Poção de Cura
      allGameItems[2], // Espada Curta
      allGameItems[7], // Adaga Sombria
    ],
  ),
  EnemyCharacter(
    name: 'Orc das Montanhas',
    texturePath: 'images/orc.webp',
    hp: 170,
    attack: 20,
    defense: 4,
    xpReward: 150,
    goldReward: 110,
    lootTable: [
      allGameItems[0], // Poção de Cura
      allGameItems[6], // Escudo de Carvalho
      allGameItems[9], // Armadura de Couro
    ],
  ),
  EnemyCharacter(
    name: 'Bruxa Malvada',
    texturePath: 'images/witch.webp',
    hp: 300,
    attack: 32,
    defense: 7,
    xpReward: 300,
    goldReward: 220,
    lootTable: [
      allGameItems[1], // Poção Grande
      allGameItems[8], // Arco de Caça
      allGameItems[11], // Anel de Rubi
    ],
  ),
  EnemyCharacter(
    name: 'Esqueleto Maldito',
    texturePath: 'images/skeleton.webp',
    hp: 380,
    attack: 38,
    defense: 9,
    xpReward: 450,
    goldReward: 300,
    lootTable: [
      allGameItems[1], // Poção Grande
      allGameItems[4], // Machado de Guerra
      allGameItems[5], // Armadura de Placas
    ],
  ),
];
