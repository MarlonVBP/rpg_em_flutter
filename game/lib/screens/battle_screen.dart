import 'dart:math';
import 'package:flutter/material.dart';
import 'package:teste/models/character_model.dart' as character;
import 'package:teste/models/item_model.dart';
import 'package:teste/providers/game_state.dart';
import 'package:provider/provider.dart';

class BattleScreen extends StatefulWidget {
  final character.EnemyCharacter enemy;
  final VoidCallback onVictory;

  const BattleScreen({super.key, required this.enemy, required this.onVictory});

  @override
  _BattleScreenState createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late GameState gameState;
  late character.HeroCharacter hero;
  late character.EnemyCharacter enemy;
  late List<GameItem> inventory;
  late String backgroundPath;
  List<String> battleLog = [];
  bool isPlayerTurn = true;

  @override
  void initState() {
    super.initState();
    gameState = Provider.of<GameState>(context, listen: false);

    hero = character.HeroCharacter.clone(
      gameState.selectedHero ??
          character.HeroCharacter(
            name: 'Aventureiro',
            texturePath: 'images/blue_texture.png',
            heroClass: 'Guerreiro',
          ),
    );
    enemy = character.EnemyCharacter.clone(widget.enemy);
    inventory = List.from(gameState.playerInventory);
    backgroundPath =
        gameState.selectedScenario ?? 'assets/images/battle_city.png';

    _applyItemBonuses();

    _logAction('A batalha contra ${enemy.name} começou!');
  }

  void _applyItemBonuses() {
    int attackBonus = 0;
    int defenseBonus = 0;
    for (var item in inventory) {
      attackBonus += item.attackBonus;
      defenseBonus += item.defenseBonus;
    }
    hero.attack += attackBonus;
    hero.defense += defenseBonus;
    if (attackBonus > 0 || defenseBonus > 0) {
      _logAction(
        '${hero.name} equipou seus itens. ATK+$attackBonus, DEF+$defenseBonus.',
      );
    }
  }

  void _logAction(String action) {
    setState(() {
      battleLog.insert(0, action);
    });
  }

  void _attack() {
    if (!isPlayerTurn) return;

    final random = Random();
    int baseDamage = hero.attack;
    int damage = max(0, baseDamage - enemy.defense);
    bool isCritical = random.nextDouble() < 0.20;

    if (isCritical) {
      damage *= 2;
      _logAction('ACERTO CRÍTICO! ${hero.name} causou $damage de dano!');
    } else {
      _logAction('${hero.name} atacou e causou $damage de dano!');
    }

    setState(() {
      enemy.currentHp -= damage;
      isPlayerTurn = false;
    });

    _endTurn();
  }

  void _castFireball() {
    if (!isPlayerTurn) return;

    int manaCost = 20;
    if (hero.currentMana >= manaCost) {
      int damage = hero.attack * 3;
      setState(() {
        hero.currentMana -= manaCost;
        enemy.currentHp -= damage;
        isPlayerTurn = false;
        _logAction('${hero.name} usou Bola de Fogo e causou $damage de dano!');
      });
      _endTurn();
    } else {
      _logAction('Mana insuficiente para lançar a magia!');
    }
  }

  void _useHealthPotion() {
    if (!isPlayerTurn) return;

    GameItem? potion;
    try {
      potion = inventory.firstWhere((item) => item.type == ItemType.potion);
    } catch (e) {
      potion = null;
    }

    if (potion != null) {
      setState(() {
        hero.currentHp = min(hero.maxHp, hero.currentHp + potion!.healAmount);
        inventory.remove(potion);
        isPlayerTurn = false;
        _logAction(
          '${hero.name} usou uma ${potion.name} e curou ${potion.healAmount} de HP!',
        );
      });
      _endTurn();
    } else {
      _logAction('Você não tem mais Poções de Cura!');
    }
  }

  void _endTurn() {
    if (_checkBattleStatus()) return;

    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        _enemyTurn();
      }
    });
  }

  void _enemyTurn() {
    _logAction('Turno de ${enemy.name}.');

    int damage = max(0, enemy.attack - hero.defense);

    setState(() {
      hero.currentMana = min(hero.maxMana, hero.currentMana + 5);
      _logAction('${hero.name} regenerou 5 de mana.');

      hero.currentHp -= damage;
      _logAction('${enemy.name} atacou e causou $damage de dano!');

      isPlayerTurn = true;
    });

    _checkBattleStatus();
  }

  bool _checkBattleStatus() {
    bool isBattleOver = false;
    if (hero.currentHp <= 0) {
      hero.currentHp = 0;
      _logAction("Você morreu!");
      isBattleOver = true;
    } else if (enemy.currentHp <= 0) {
      enemy.currentHp = 0;
      _logAction("${enemy.name} foi derrotado!");
      isBattleOver = true;

      widget.onVictory();

      _logAction(
          "Você ganhou ${enemy.xpReward} de XP e ${enemy.goldReward} moedas!");
      gameState.addGold(enemy.goldReward);

      if (enemy.lootTable.isNotEmpty) {
        final random = Random();
        if (random.nextDouble() < 0.5) {
          final droppedItem =
              enemy.lootTable[random.nextInt(enemy.lootTable.length)];
          gameState.addItemToInventory(droppedItem);
          _logAction("Você encontrou um item: ${droppedItem.name}!");
        }
      }
      setState(() {
        hero.xp += enemy.xpReward;
        if (hero.xp >= hero.xpToNextLevel) {
          hero.levelUp();
          _logAction("Subiu de nível! Você agora é nível ${hero.level}!");
          _logAction(
              "Status melhorados! Próximo nível em ${hero.xpToNextLevel} XP.");
        } else {
          hero.restoreStats();
          _logAction("HP e Mana restaurados!");
        }
        gameState.updateHero(hero);
      });
    }
    if (isBattleOver) {
      setState(() {
        isPlayerTurn = false;
      });
    }
    return isBattleOver;
  }

  Color _getHpColor(int currentHp, int maxHp) {
    double percentage = max(0, currentHp / maxHp);
    if (percentage > 0.6) return Colors.green;
    if (percentage > 0.3) return Colors.yellow;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    bool isBattleOver = hero.currentHp <= 0 || enemy.currentHp <= 0;

    return Scaffold(
      appBar: AppBar(title: Text('Batalha RPG')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundPath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildCharacterDisplay(hero),
                  _buildCharacterDisplay(enemy),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.black.withOpacity(0.6),
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                padding: EdgeInsets.all(8),
                child: ListView.builder(
                  reverse: true,
                  itemCount: battleLog.length,
                  itemBuilder: (context, index) => Text(
                    battleLog[index],
                    style: TextStyle(
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 2)],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 24.0,
                left: 8.0,
                right: 8.0,
              ),
              child: isBattleOver
                  ? ElevatedButton.icon(
                      icon: Icon(Icons.arrow_back),
                      label: Text('Fim da Batalha. Voltar.'),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: isPlayerTurn ? _attack : null,
                          icon: Icon(Icons.gavel),
                          label: Text('Atacar'),
                        ),
                        ElevatedButton.icon(
                          onPressed: isPlayerTurn ? _castFireball : null,
                          icon: Icon(Icons.local_fire_department),
                          label: Text('Bola de Fogo'),
                        ),
                        ElevatedButton.icon(
                          onPressed: isPlayerTurn ? _useHealthPotion : null,
                          icon: Icon(Icons.healing),
                          label: Text('Usar Poção'),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterDisplay(character.GameCharacter gameCharacter) {
    bool isHero = gameCharacter is character.HeroCharacter;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          gameCharacter.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 4)],
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: isHero ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isHero ? BorderRadius.circular(8) : null,
            image: DecorationImage(
              image: AssetImage(gameCharacter.texturePath),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        _buildStatBar(
          gameCharacter.currentHp,
          gameCharacter.maxHp,
          _getHpColor(gameCharacter.currentHp, gameCharacter.maxHp),
          "HP",
        ),
        SizedBox(height: 5),
        if (isHero)
          _buildStatBar(
            gameCharacter.currentMana,
            gameCharacter.maxMana,
            Colors.blue,
            "MP",
          ),
      ],
    );
  }

  Widget _buildStatBar(
    int currentValue,
    int maxValue,
    Color color,
    String label,
  ) {
    return Column(
      children: [
        Text(
          '$label: $currentValue / $maxValue',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 2)],
          ),
        ),
        Container(
          width: 120,
          height: 15,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: max(0, currentValue / maxValue),
              backgroundColor: Colors.grey[800],
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
