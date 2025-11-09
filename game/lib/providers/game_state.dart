import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:teste/models/character_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste/models/item_model.dart';
import 'package:teste/models/quest_model.dart';

final List<HeroCharacter> defaultHeroes = [
  HeroCharacter(
    name: 'Guerreiro velho',
    texturePath: 'images/warrior.png',
    heroClass: 'Guerreiro',
  ),
  HeroCharacter(
      name: 'Mago ancião', texturePath: 'images/mage.png', heroClass: 'Mago'),
  HeroCharacter(
      name: 'Vigia ancestral',
      texturePath: 'images/ladino.png',
      heroClass: 'Ladino'),
];

class GameState with ChangeNotifier {
  HeroCharacter? selectedHero;
  String? selectedScenario;
  List<GameItem> playerInventory = [];
  List<Quest> quests = [];

  List<HeroCharacter> availableHeroes = [];

  GameState() {
    _initializeQuests();
    loadHeroes();
  }

  void _initializeQuests() {
    final bosses = [
      EnemyCharacter(
          name: 'Círculo Vermelho da Fúria',
          texturePath: 'images/blue_texture.png',
          hp: 300,
          attack: 20,
          xpReward: 100,
          goldReward: 50),
      EnemyCharacter(
          name: 'Círculo Sombrio do Abismo',
          texturePath: 'images/red_texture.png',
          hp: 500,
          attack: 12,
          defense: 8,
          xpReward: 250,
          goldReward: 120),
    ];

    quests = [
      Quest(
          id: 'boss1',
          title: 'A Ameaça Vermelha',
          description: 'Derrote o Círculo da Fúria que aterroriza a cidade.',
          boss: bosses[0]),
      Quest(
          id: 'boss2',
          title: 'Escuridão Profunda',
          description: 'Enfrente o Círculo Sombrio que emerge das ruínas.',
          boss: bosses[1]),
    ];
  }

  void completeQuest(String questId) {
    final quest = quests.firstWhere((q) => q.id == questId);
    quest.isCompleted = true;
    notifyListeners();
  }

  int playerGold = 0;

  void addGold(int amount) {
    playerGold += amount;
    notifyListeners();
  }

  void selectAndSaveHero(HeroCharacter hero) {
    selectedHero = hero;
    if (!availableHeroes.any((h) => h.name == hero.name)) {
      availableHeroes.add(hero);
      _saveHeroes();
    }
    notifyListeners();
  }

  void updateHero(HeroCharacter updatedHero) {
    final index = availableHeroes.indexWhere((h) => h.name == updatedHero.name);
    if (index != -1) {
      availableHeroes[index] = updatedHero;

      if (selectedHero?.name == updatedHero.name) {
        selectedHero = updatedHero;
      }

      _saveHeroes();
      notifyListeners();
    }
  }

  Future<void> _saveHeroes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> heroesJsonList =
        availableHeroes.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList('saved_heroes_list', heroesJsonList);
  }

  Future<void> loadHeroes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? heroesJsonList =
        prefs.getStringList('saved_heroes_list');

    if (heroesJsonList != null && heroesJsonList.isNotEmpty) {
      availableHeroes = heroesJsonList
          .map((hJson) => HeroCharacter.fromJson(jsonDecode(hJson)))
          .toList();
    } else {
      availableHeroes = List.from(defaultHeroes);
    }

    final String? lastSelectedHeroName = prefs.getString('last_selected_hero');
    if (lastSelectedHeroName != null) {
      try {
        selectedHero =
            availableHeroes.firstWhere((h) => h.name == lastSelectedHeroName);
      } catch (e) {
        selectedHero = null;
      }
    }
    notifyListeners();
  }

  void selectHero(HeroCharacter hero) {
    selectedHero = hero;

    if (!availableHeroes.any((h) => h.name == hero.name)) {
      availableHeroes.add(hero);
    }

    _saveHeroes();
    notifyListeners();
  }

  void selectScenario(String scenarioPath) {
    selectedScenario = scenarioPath;
    notifyListeners();
  }

  void addItemToInventory(GameItem item) {
    if (playerInventory.length < 5) {
      playerInventory.add(item);
      notifyListeners();
    }
  }

  void removeItemFromInventory(GameItem item) {
    playerInventory.remove(item);
    notifyListeners();
  }

  void clearInventory() {
    playerInventory.clear();
    notifyListeners();
  }
}
