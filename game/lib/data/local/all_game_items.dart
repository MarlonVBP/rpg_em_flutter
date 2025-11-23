import 'package:teste/data/models/item_model.dart';

const List<GameItem> allGameItems = [
  // --- Básicos ---
  GameItem(
      name: 'Poção de Cura',
      description: 'Restaura 50 HP',
      type: ItemType.potion,
      imagePath: 'images/health_potion.png',
      healAmount: 50,
      price: 20), // Ajustei preço
  GameItem(
      name: 'Poção Grande',
      description: 'Restaura 150 HP',
      type: ItemType.potion,
      imagePath: 'images/big_health_potion.png',
      healAmount: 150,
      price: 50),
      
  // --- Guerreiro / Paladino ---
  GameItem(
      name: 'Espada Curta',
      description: '+5 de Ataque',
      type: ItemType.sword,
      imagePath: 'images/small_sword.png',
      attackBonus: 5,
      price: 100),
  GameItem(
      name: 'Espada Longa',
      description: 'Lâmina balanceada (+12 Atk)',
      type: ItemType.sword,
      imagePath: 'images/long_sword.png',
      attackBonus: 12,
      price: 250),
  GameItem(
      name: 'Machado de Guerra',
      description: 'Golpes pesados (+15 Atk)',
      type: ItemType.axe,
      imagePath: 'images/battle_axe.png',
      attackBonus: 15,
      price: 300),
  GameItem(
      name: 'Armadura de Placas',
      description: 'Proteção pesada (+15 Def)',
      type: ItemType.armor,
      imagePath: 'images/plate_armor.png',
      defenseBonus: 15,
      price: 400),
  GameItem(
      name: 'Escudo de Carvalho',
      description: 'Bloqueio sólido (+8 Def)',
      type: ItemType.shield,
      imagePath: 'images/wooden_shield.png',
      defenseBonus: 8,
      price: 150),

  // --- Ladino / Caçador ---
  GameItem(
      name: 'Adaga Sombria',
      description: 'Rápida e letal (+8 Atk)',
      type: ItemType.dagger,
      imagePath: 'images/dagger.png',
      attackBonus: 8,
      price: 120),
  GameItem(
      name: 'Arco de Caça',
      description: 'Ataque à distância (+10 Atk)',
      type: ItemType.bow,
      imagePath: 'images/bow.png',
      attackBonus: 10,
      price: 180),
  GameItem(
      name: 'Armadura de Couro',
      description: 'Leve e flexível (+6 Def)',
      type: ItemType.armor,
      imagePath: 'images/armor_leather.png',
      defenseBonus: 6,
      price: 100),

  // --- Mago ---
  GameItem(
      name: 'Cajado Místico',
      description: 'Potencializa magia (+10 Atk)',
      type: ItemType.staff,
      imagePath: 'images/magic_staff.png',
      attackBonus: 10,
      price: 200),
  GameItem(
      name: 'Anel de Rubi',
      description: 'Poder arcano (+5 Atk / +2 Def)',
      type: ItemType.ring,
      imagePath: 'images/ruby_ring.png',
      attackBonus: 5,
      defenseBonus: 2,
      price: 350),
];