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
    this.maxHp = 120,
    this.currentHp = 120,
    this.maxMana = 60,
    this.currentMana = 60,
    this.attack = 18,
    this.defense = 6,
    this.xp = 0,
    this.level = 1,
  });
}
