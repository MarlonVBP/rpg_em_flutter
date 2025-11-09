import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:teste/models/character_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste/models/item_model.dart';
import 'package:teste/models/quest_model.dart';
import 'package:firebase_database/firebase_database.dart';

//
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

//
//
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

class GameState with ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  HeroCharacter? selectedHero;
  String? selectedScenario;
  List<GameItem> playerInventory = [];
  List<Quest> quests = [];
  int playerGold = 0;
  List<HeroCharacter> availableHeroes = [];

  final String _userId = "testUser123";

  GameState() {
    _initializeQuests();

    loadHeroes();
    _loadGameData();
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

  void _loadGameData() {
    _dbRef.child('users/$_userId').onValue.listen((event) {
      final data = event.snapshot.value;

      if (data != null && data is Map) {
        final userData = Map<String, dynamic>.from(data);

        playerGold = userData['playerGold'] as int? ?? 0;

        final List<dynamic>? inventoryNames =
            userData['playerInventory'] as List<dynamic>?;
        playerInventory.clear();
        if (inventoryNames != null) {
          for (final itemName in inventoryNames) {
            try {
              final item =
                  allGameItems.firstWhere((item) => item.name == itemName);
              playerInventory.add(item);
            } catch (e) {
              if (kDebugMode) {
                print("Item $itemName não encontrado na lista mestre.");
              }
            }
          }
        }

        final Map<dynamic, dynamic>? questStatus =
            userData['questStatus'] as Map<dynamic, dynamic>?;
        if (questStatus != null) {
          for (final quest in quests) {
            quest.isCompleted = questStatus[quest.id] as bool? ?? false;
          }
        }
      }

      notifyListeners();
    }, onError: (error) {
      if (kDebugMode) {
        print("Erro ao carregar dados do jogo: $error");
      }
    });
  }

  Future<void> loadHeroes() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      _dbRef.child('users/$_userId/heroes').onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null && data is Map) {
          final heroesMap = Map<String, dynamic>.from(data);
          availableHeroes = heroesMap.values.map((heroData) {
            return HeroCharacter.fromJson(Map<String, dynamic>.from(heroData));
          }).toList();
        } else {
          availableHeroes = List.from(defaultHeroes);

          _saveHeroesToFirebase();
        }

        final String? lastSelectedHeroName =
            prefs.getString('last_selected_hero');
        if (lastSelectedHeroName != null) {
          try {
            selectedHero = availableHeroes
                .firstWhere((h) => h.name == lastSelectedHeroName);
          } catch (e) {
            selectedHero = null;
          }
        }
        notifyListeners();
      });
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao carregar heróis do Firebase: $e");
      }

      availableHeroes = List.from(defaultHeroes);
      notifyListeners();
    }
  }

  Future<void> _saveHeroesToFirebase() async {
    Map<String, dynamic> heroesMap = {
      for (var hero in availableHeroes) hero.name: hero.toJson()
    };
    try {
      await _dbRef.child('users/$_userId/heroes').set(heroesMap);
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao salvar heróis no Firebase: $e");
      }
    }
  }

  Future<void> _updateHeroInFirebase(HeroCharacter hero) async {
    try {
      await _dbRef
          .child('users/$_userId/heroes/${hero.name}')
          .update(hero.toJson());
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao atualizar herói no Firebase: $e");
      }
    }
  }

  Future<void> _addHeroToFirebase(HeroCharacter hero) async {
    try {
      await _dbRef
          .child('users/$_userId/heroes/${hero.name}')
          .set(hero.toJson());
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao adicionar herói no Firebase: $e");
      }
    }
  }

  Future<void> _savePlayerInventory() async {
    List<String> itemNames = playerInventory.map((item) => item.name).toList();
    try {
      await _dbRef.child('users/$_userId/playerInventory').set(itemNames);
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao salvar inventário no Firebase: $e");
      }
    }
  }

  Future<void> _savePlayerGold() async {
    try {
      await _dbRef.child('users/$_userId/playerGold').set(playerGold);
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao salvar ouro no Firebase: $e");
      }
    }
  }

  Future<void> _saveQuestStatus(String questId, bool isCompleted) async {
    try {
      await _dbRef
          .child('users/$_userId/questStatus')
          .update({questId: isCompleted});
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao salvar status da missão: $e");
      }
    }
  }

  void completeQuest(String questId) {
    final quest = quests.firstWhere((q) => q.id == questId);
    quest.isCompleted = true;
    _saveQuestStatus(questId, true);
    notifyListeners();
  }

  void addGold(int amount) {
    playerGold += amount;
    _savePlayerGold();
    notifyListeners();
  }

  void selectAndSaveHero(HeroCharacter hero) {
    selectHero(hero);
  }

  void updateHero(HeroCharacter updatedHero) {
    final index = availableHeroes.indexWhere((h) => h.name == updatedHero.name);
    if (index != -1) {
      availableHeroes[index] = updatedHero;

      if (selectedHero?.name == updatedHero.name) {
        selectedHero = updatedHero;
      }

      _updateHeroInFirebase(updatedHero);
      notifyListeners();
    }
  }

  void selectHero(HeroCharacter hero) async {
    selectedHero = hero;

    bool heroExists = availableHeroes.any((h) => h.name == hero.name);

    if (!heroExists) {
      availableHeroes.add(hero);
      await _addHeroToFirebase(hero);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_selected_hero', hero.name);

    notifyListeners();
  }

  void selectScenario(String scenarioPath) {
    selectedScenario = scenarioPath;
    notifyListeners();
  }

  void addItemToInventory(GameItem item) {
    if (playerInventory.length < 5) {
      playerInventory.add(item);
      _savePlayerInventory();
      notifyListeners();
    }
  }

  void removeItemFromInventory(GameItem item) {
    playerInventory.remove(item);
    _savePlayerInventory();
    notifyListeners();
  }

  void clearInventory() {
    playerInventory.clear();
    _savePlayerInventory();
    notifyListeners();
  }
}
