import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:teste/models/character_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste/models/item_model.dart';
import 'package:teste/models/quest_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:teste/models/user_model.dart';

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
  final User? _currentUser;
  final List<StreamSubscription> _subscriptions = [];

  HeroCharacter? selectedHero;
  String? selectedScenario;
  List<GameItem> playerInventory = [];
  List<Quest> quests = [];
  int playerGold = 0;
  List<HeroCharacter> availableHeroes = [];

  String? get currentUserId => _currentUser?.uid;

  GameState(this._currentUser) {
    _initializeQuests();

    if (currentUserId != null) {
      loadHeroes();
      _loadGameData();
    } else {
      availableHeroes = List.from(defaultHeroes);
    }
  }

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.dispose();
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
    if (currentUserId == null) return;

    final goldSub =
        _dbRef.child('users/$currentUserId').onValue.listen((event) {
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
      }
      notifyListeners();
    }, onError: (error) {
      if (kDebugMode) {
        print("Erro ao carregar dados do jogo: $error");
      }
    });
    _subscriptions.add(goldSub);

    final questSub = _dbRef
        .child('users/$currentUserId/questStatus')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;

      if (data != null && data is Map) {
        final questStatus = Map<dynamic, dynamic>.from(data);
        for (final quest in quests) {
          quest.isCompleted = questStatus[quest.id] as bool? ?? false;
        }
      } else {
        _uploadInitialQuestStatus();
      }
      notifyListeners();
    });
    _subscriptions.add(questSub);
  }

  Future<void> _uploadInitialQuestStatus() async {
    if (currentUserId == null) return;

    final Map<String, bool> initialStatus = {
      for (var quest in quests) quest.id: false
    };

    try {
      await _dbRef.child('users/$currentUserId/questStatus').set(initialStatus);
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao salvar status inicial das missões: $e");
      }
    }
  }

  Future<void> _saveQuestStatus(String questId, bool isCompleted) async {
    if (currentUserId == null) return;
    try {
      await _dbRef
          .child('users/$currentUserId/questStatus')
          .update({questId: isCompleted});
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao salvar status da missão: $e");
      }
    }
  }

  Future<void> loadHeroes() async {
    if (currentUserId == null) return;

    final prefs = await SharedPreferences.getInstance();
    try {
      final heroesSub =
          _dbRef.child('users/$currentUserId/heroes').onValue.listen((event) {
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
            prefs.getString('last_selected_hero_$currentUserId');
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
      _subscriptions.add(heroesSub);
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao carregar heróis do Firebase: $e");
      }

      availableHeroes = List.from(defaultHeroes);
      notifyListeners();
    }
  }

  Future<void> _saveHeroesToFirebase() async {
    if (currentUserId == null) return;
    Map<String, dynamic> heroesMap = {
      for (var hero in availableHeroes) hero.name: hero.toJson()
    };
    try {
      await _dbRef.child('users/$currentUserId/heroes').set(heroesMap);
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao salvar heróis no Firebase: $e");
      }
    }
  }

  Future<void> _updateHeroInFirebase(HeroCharacter hero) async {
    if (currentUserId == null) return;
    try {
      await _dbRef
          .child('users/$currentUserId/heroes/${hero.name}')
          .update(hero.toJson());
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao atualizar herói no Firebase: $e");
      }
    }
  }

  Future<void> _addHeroToFirebase(HeroCharacter hero) async {
    if (currentUserId == null) return;
    try {
      await _dbRef
          .child('users/$currentUserId/heroes/${hero.name}')
          .set(hero.toJson());
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao adicionar herói no Firebase: $e");
      }
    }
  }

  Future<void> _savePlayerInventory() async {
    if (currentUserId == null) return;
    List<String> itemNames = playerInventory.map((item) => item.name).toList();
    try {
      await _dbRef.child('users/$currentUserId/playerInventory').set(itemNames);
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao salvar inventário no Firebase: $e");
      }
    }
  }

  Future<void> _savePlayerGold() async {
    if (currentUserId == null) return;
    try {
      await _dbRef.child('users/$currentUserId/playerGold').set(playerGold);
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao salvar ouro no Firebase: $e");
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
    if (currentUserId == null) return;

    selectedHero = hero;

    bool heroExists = availableHeroes.any((h) => h.name == hero.name);

    if (!heroExists) {
      availableHeroes.add(hero);
      await _addHeroToFirebase(hero);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_selected_hero_$currentUserId', hero.name);

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
