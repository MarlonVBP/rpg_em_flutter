import 'package:teste/data/models/item_model.dart';

const List<GameItem> allGameItems = [
  // --- Básicos ---
  GameItem(
      name: 'Poção de Cura',
      description: 'Restaura 60 HP',
      type: ItemType.potion,
      imagePath: 'images/health_potion.webp',
      healAmount: 60,
      price: 20),
  GameItem(
      name: 'Poção Grande',
      description: 'Restaura 150 HP',
      type: ItemType.potion,
      imagePath: 'images/big_health_potion.webp',
      healAmount: 150,
      price: 45),

  // --- Guerreiro / Paladino ---
  GameItem(
      name: 'Espada Curta',
      description: '+8 de Ataque',
      type: ItemType.sword,
      imagePath: 'images/small_sword.webp',
      attackBonus: 8,
      price: 60),
  GameItem(
      name: 'Espada Longa',
      description: 'Lâmina balanceada (+15 Atk)',
      type: ItemType.sword,
      imagePath: 'images/long_sword.webp',
      attackBonus: 15,
      price: 130),
  GameItem(
      name: 'Machado de Guerra',
      description: 'Golpes pesados (+20 Atk)',
      type: ItemType.axe,
      imagePath: 'images/battle_axe.webp',
      attackBonus: 20,
      price: 180),
  GameItem(
      name: 'Armadura de Placas',
      description: 'Proteção pesada (+15 Def)',
      type: ItemType.armor,
      imagePath: 'images/plate_armor.webp',
      defenseBonus: 15,
      price: 200),
  GameItem(
      name: 'Escudo de Carvalho',
      description: 'Bloqueio sólido (+8 Def)',
      type: ItemType.shield,
      imagePath: 'images/wooden_shield.webp',
      defenseBonus: 8,
      price: 80),

  // --- Ladino / Caçador ---
  GameItem(
      name: 'Adaga Sombria',
      description: 'Rápida e letal (+10 Atk)',
      type: ItemType.dagger,
      imagePath: 'images/dagger.webp',
      attackBonus: 10,
      price: 70),
  GameItem(
      name: 'Arco de Caça',
      description: 'Ataque à distância (+14 Atk)',
      type: ItemType.bow,
      imagePath: 'images/bow.webp',
      attackBonus: 14,
      price: 110),
  GameItem(
      name: 'Armadura de Couro',
      description: 'Leve e flexível (+7 Def)',
      type: ItemType.armor,
      imagePath: 'images/armor_leather.webp',
      defenseBonus: 7,
      price: 65),

  // --- Mago ---
  GameItem(
      name: 'Cajado Místico',
      description: 'Potencializa magia (+15 Atk)',
      type: ItemType.staff,
      imagePath: 'images/magic_staff.webp',
      attackBonus: 15,
      price: 120),
  GameItem(
      name: 'Anel de Rubi',
      description: 'Poder arcano (+10 Atk / +5 Def)',
      type: ItemType.ring,
      imagePath: 'images/ruby_ring.webp',
      attackBonus: 10,
      defenseBonus: 5,
      price: 160),
];
