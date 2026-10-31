import 'package:teste/data/models/hero_character_model.dart';

final List<HeroCharacter> defaultHeroes = [
  HeroCharacter(
    name: 'Guerreiro velho',
    texturePath: 'images/warrior.webp',
    heroClass: 'Guerreiro',
  ),
  HeroCharacter(
      name: 'Mago ancião', texturePath: 'images/mage.webp', heroClass: 'Mago'),
  HeroCharacter(
      name: 'Vigia ancestral',
      texturePath: 'images/ladino.webp',
      heroClass: 'Ladino'),
];
