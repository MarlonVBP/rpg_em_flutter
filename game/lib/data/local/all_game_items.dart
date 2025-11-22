import 'package:teste/data/models/item_model.dart';

const List<GameItem> allGameItems = [
  GameItem(
      name: 'Poção de Cura',
      description: 'Restaura 50 HP',
      type: ItemType.potion,
      imagePath: 'images/health_potion.png',
      healAmount: 50,
      price: 10),
  GameItem(
      name: 'Espada Curta',
      description: '+5 de Ataque',
      type: ItemType.sword,
      imagePath: 'images/small_sword.png',
      attackBonus: 5,
      price: 100),
  GameItem(
      name: 'Armadura leve',
      description: '+5 de Defesa',
      type: ItemType.armor,
      imagePath: 'images/armor_leather.png',
      defenseBonus: 5,
      price: 80),
  GameItem(
      name: 'Cajado Místico',
      description: '+10 Ataque Mágico',
      type: ItemType.staff,
      imagePath: 'images/magic_staff.png',
      price: 150),
];