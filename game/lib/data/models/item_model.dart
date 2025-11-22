enum ItemType { potion, sword, armor, staff }

class GameItem {
  final String name;
  final String description;
  final ItemType type;
  final String imagePath;
  final int attackBonus;
  final int defenseBonus;
  final int healAmount;
  final int price;

  const GameItem({
    required this.name,
    required this.description,
    required this.type,
    required this.imagePath,
    this.attackBonus = 0,
    this.defenseBonus = 0,
    this.healAmount = 0,
    this.price = 0,
  });
}
