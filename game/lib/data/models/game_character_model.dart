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
