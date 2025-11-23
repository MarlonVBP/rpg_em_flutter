import 'dart:math';
import 'package:flutter/material.dart';
import 'package:teste/data/enums/card_action_type.dart';
import 'package:teste/data/enums/log_entry_type.dart';
import 'package:teste/data/models/enemy_character_model.dart';
import 'package:teste/data/models/game_character_model.dart';
import 'package:teste/data/models/hero_character_model.dart';
import 'package:teste/data/models/item_model.dart';
import 'package:teste/providers/game_state.dart';
import 'package:provider/provider.dart';
import 'package:teste/data/models/battle_card_model.dart';
import 'package:teste/services/audio_manager.dart';

class BattleLogEntry {
  final String message;
  final LogEntryType type;
  BattleLogEntry(this.message, this.type);
}

class BattleScreen extends StatefulWidget {
  final EnemyCharacter enemy;
  final VoidCallback onVictory;

  const BattleScreen({super.key, required this.enemy, required this.onVictory});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late GameState gameState;
  late HeroCharacter hero;
  late EnemyCharacter enemy;
  late String backgroundPath;
  bool isPlayerTurn = true;
  bool isProcessingTurn = false;

  List<BattleCard> deck = [];
  List<BattleCard> hand = [];
  List<BattleCard> discardPile = [];
  final int maxHandSize = 5;

  List<BattleLogEntry> battleLog = [];
  int rerollPoints = 5;
  int? _draggedCardIndex;

  @override
  void initState() {
    super.initState();
    gameState = Provider.of<GameState>(context, listen: false);

    hero = HeroCharacter.clone(
      gameState.selectedHero ??
          HeroCharacter(
            name: 'Aventureiro',
            texturePath: 'images/blue_texture.png',
            heroClass: 'Guerreiro',
          ),
    );
    enemy = EnemyCharacter.clone(widget.enemy);
    backgroundPath = gameState.selectedScenario ?? 'images/battle_city.png';

    _applyItemBonuses();
    _buildInitialDeck();
    _logAction('A batalha contra ${enemy.name} começou!', LogEntryType.system);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPlayerTurn();
    });

    AudioManager.instance.playMusic('battle_theme.mp3');
  }

  @override
  void dispose() {
    AudioManager.instance.playMusic('background_music.mp3');

    super.dispose();
  }

  void _applyItemBonuses() {
    int attackBonus = 0;
    int defenseBonus = 0;

    // 1. Definir Afinidades
    // Multiplicador 1.0 = Normal, 1.5 = Bônus de Classe, 0.5 = Penalidade
    double getMultiplier(ItemType type) {
      final String heroClass = hero.heroClass;

      switch (heroClass) {
        case 'Guerreiro':
          if ([ItemType.sword, ItemType.axe, ItemType.shield, ItemType.armor]
              .contains(type)) return 1.2;
          if ([ItemType.staff, ItemType.dagger].contains(type)) return 0.5;
          break;

        case 'Paladino':
          if ([ItemType.sword, ItemType.shield, ItemType.ring].contains(type))
            return 1.3;
          if ([ItemType.axe, ItemType.bow].contains(type)) return 0.5;
          break;

        case 'Mago':
          if ([ItemType.staff, ItemType.ring, ItemType.potion].contains(type))
            return 1.5;
          if ([ItemType.sword, ItemType.axe, ItemType.shield, ItemType.armor]
              .contains(type)) return 0.2; // Mago ruim com armadura pesada
          break;

        case 'Ladino':
          if ([ItemType.dagger, ItemType.bow].contains(type)) return 1.5;
          if ([ItemType.shield, ItemType.axe].contains(type)) return 0.5;
          break;

        case 'Caçador':
          if ([ItemType.bow, ItemType.dagger, ItemType.potion].contains(type))
            return 1.3;
          if ([ItemType.armor, ItemType.shield].contains(type)) return 0.7;
          break;
      }
      return 1.0; // Padrão
    }

    // 2. Calcular Bônus
    List<String> affinityLogs = [];

    for (var item in gameState.playerInventory) {
      double mult = getMultiplier(item.type);

      int effectiveAtk = (item.attackBonus * mult).floor();
      int effectiveDef = (item.defenseBonus * mult).floor();

      attackBonus += effectiveAtk;
      defenseBonus += effectiveDef;

      if (mult > 1.0) affinityLogs.add("${item.name} (Afinidade!)");
      if (mult < 1.0) affinityLogs.add("${item.name} (Ineficaz)");
    }

    // 3. Aplicar ao Herói
    hero.attack += attackBonus;
    hero.defense += defenseBonus;

    if (attackBonus > 0 || defenseBonus > 0) {
      _logAction(
        'Equipamentos: +$attackBonus ATK, +$defenseBonus DEF.',
        LogEntryType.system,
      );
      if (affinityLogs.isNotEmpty) {
        // Log opcional para mostrar afinidades
        _logAction('Obs: ${affinityLogs.join(", ")}', LogEntryType.system);
      }
    }
  }

  void _buildInitialDeck() {
    deck = [];
    discardPile = [];
    hand = [];

    deck.addAll(List.generate(
      5,
      (index) => BattleCard(
        id: 'attack',
        name: 'Atacar',
        description: 'Causa ${hero.attack} de dano físico.',
        imagePath: 'images/attack.png',
        type: CardActionType.attack,
      ),
    ));

    deck.addAll(List.generate(
      2,
      (index) => BattleCard(
        id: 'fireball',
        name: 'Bola de Fogo',
        description: 'Causa ${hero.attack * 3} de dano mágico.',
        imagePath: 'images/fireboll.png',
        type: CardActionType.magic,
        manaCost: 20,
      ),
    ));

    for (var item in gameState.playerInventory) {
      if (item.type == ItemType.potion) {
        deck.add(BattleCard(
          id: 'health_potion',
          name: item.name,
          description: item.description,
          imagePath: item.imagePath,
          type: CardActionType.item,
          sourceItem: item,
        ));
      }
    }
    deck.shuffle(Random());
  }

  void _logAction(String action, LogEntryType type) {
    setState(() {
      battleLog.insert(0, BattleLogEntry(action, type));
      if (battleLog.length > 30) {
        battleLog.removeLast();
      }
    });
  }

  void _startPlayerTurn() {
    setState(() {
      isPlayerTurn = true;
      isProcessingTurn = false;
      hero.currentMana = min(hero.maxMana, hero.currentMana + 10);
      _logAction('Mana regenerada (+10).', LogEntryType.system);
    });
    _drawHand();
  }

  Future<void> _drawHand() async {
    int cardsToDraw = maxHandSize - hand.length;
    if (cardsToDraw <= 0) return;

    if (deck.length < cardsToDraw) {
      if (discardPile.isNotEmpty) {
        _logAction('Reembaralhando descarte...', LogEntryType.system);
        await Future.delayed(const Duration(milliseconds: 700));

        deck.addAll(discardPile);
        deck.shuffle(Random());
        discardPile.clear();
      }
    }

    for (int i = 0; i < cardsToDraw; i++) {
      if (deck.isEmpty) break;

      await Future.delayed(const Duration(milliseconds: 150));
      setState(() {
        final card = deck.removeLast();
        hand.add(card);
      });
    }
  }

  Future<void> _useReroll() async {
    if (rerollPoints <= 0 || !isPlayerTurn || isProcessingTurn) {
      return;
    }

    setState(() {
      isProcessingTurn = true;
      rerollPoints--;
      _logAction('Você reembaralhou a mão!', LogEntryType.system);
    });

    await _discardHand();
    await Future.delayed(const Duration(milliseconds: 300));
    await _drawHand();

    setState(() {
      isProcessingTurn = false;
    });
  }

  void _onCardPlayed(int indexInHand, BattleCard card) {
    setState(() {
      isProcessingTurn = true;
      _draggedCardIndex = null;
    });

    if (card.manaCost > 0) {
      setState(() {
        hero.currentMana -= card.manaCost;
      });
    }
    _playCardEffect(card);

    setState(() {
      final removedCard = hand.removeAt(indexInHand);
      if (removedCard.type != CardActionType.item) {
        discardPile.add(removedCard);
      }
    });

    _endTurn();
  }

  void _playCardEffect(BattleCard card) {
    switch (card.id) {
      case 'attack':
        final random = Random();
        int baseDamage = hero.attack;
        int damage = max(0, baseDamage - enemy.defense);
        bool isCritical = random.nextDouble() < 0.20;

        if (isCritical) {
          damage *= 2;
          _logAction('CRÍTICO! $damage de dano!', LogEntryType.damage);
        } else {
          _logAction('Ataque: $damage de dano.', LogEntryType.damage);
        }
        setState(() {
          enemy.currentHp -= damage;
        });
        break;

      case 'fireball':
        int damage = hero.attack * 3;
        setState(() {
          enemy.currentHp -= damage;
        });
        _logAction('Bola de Fogo: $damage de dano!', LogEntryType.damage);
        break;

      case 'health_potion':
        final item = card.sourceItem;
        if (item != null) {
          setState(() {
            hero.currentHp = min(hero.maxHp, hero.currentHp + item.healAmount);
          });
          _logAction('Curou ${item.healAmount} HP.', LogEntryType.heal);
          gameState.removeItemFromInventory(item);
        }
        break;
    }
  }

  void _endTurn() {
    if (_checkBattleStatus()) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          isPlayerTurn = false;
        });
        _enemyTurn();
      }
    });
  }

  Future<void> _discardHand() async {
    while (hand.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        discardPile.add(hand.removeLast());
      });
    }
  }

  void _enemyTurn() {
    while (hand.isNotEmpty) {
      discardPile.add(hand.removeLast());
    }
    setState(() {});

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      int damage = max(0, enemy.attack - hero.defense);

      setState(() {
        hero.currentHp -= damage;
      });
      _logAction('${enemy.name} causou $damage de dano!', LogEntryType.damage);

      if (_checkBattleStatus()) return;

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _startPlayerTurn();
        }
      });
    });
  }

  bool _checkBattleStatus() {
    bool isBattleOver = false;
    if (hero.currentHp <= 0) {
      hero.currentHp = 0;
      _logAction("Você foi derrotado!", LogEntryType.system);
      isBattleOver = true;
    } else if (enemy.currentHp <= 0) {
      enemy.currentHp = 0;
      _logAction("Vitória! Inimigo derrotado.", LogEntryType.system);
      isBattleOver = true;

      widget.onVictory();

      _logAction(
        "Ganhou ${enemy.xpReward} XP e ${enemy.goldReward} Ouro!",
        LogEntryType.system,
      );
      gameState.addGold(enemy.goldReward);

      if (enemy.lootTable.isNotEmpty) {
        final random = Random();
        if (random.nextDouble() < 0.5) {
          final droppedItem =
              enemy.lootTable[random.nextInt(enemy.lootTable.length)];
          gameState.addItemToInventory(droppedItem);
          _logAction("Item obtido: ${droppedItem.name}!", LogEntryType.system);
        }
      }
      setState(() {
        hero.xp += enemy.xpReward;
        if (hero.xp >= hero.xpToNextLevel) {
          hero.levelUp();
          _logAction("Subiu de Nível! Agora é Nível ${hero.level}!",
              LogEntryType.system);
        } else {
          hero.restoreStats();
        }
        gameState.updateHero(hero);
      });
    }
    if (isBattleOver) {
      setState(() {
        isPlayerTurn = false;
        isProcessingTurn = true;
      });
    }
    return isBattleOver;
  }

  Color _getHpColor(int currentHp, int maxHp) {
    double percentage = max(0, currentHp / maxHp);
    if (percentage > 0.6) return Colors.greenAccent;
    if (percentage > 0.3) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    bool isBattleOver = hero.currentHp <= 0 || enemy.currentHp <= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batalha',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              backgroundPath,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.grey[900]),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  child: Stack(
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            DragTarget<BattleCard>(
                              builder: (context, candidateData, rejectedData) {
                                final hovering = candidateData.isNotEmpty;
                                return _buildCharacterDisplay(hero,
                                    isHovering: hovering);
                              },
                              onWillAcceptWithDetails: (details) =>
                                  isPlayerTurn &&
                                  !isProcessingTurn &&
                                  details.data.type == CardActionType.item,
                              onAcceptWithDetails: (details) {
                                if (_draggedCardIndex != null)
                                  _onCardPlayed(
                                      _draggedCardIndex!, details.data);
                              },
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "VS",
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.red.withOpacity(0.3),
                                        offset: const Offset(2, 2),
                                        blurRadius: 4,
                                      ),
                                      Shadow(
                                        color: Colors.orangeAccent
                                            .withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            DragTarget<BattleCard>(
                              builder: (context, candidateData, rejectedData) {
                                final hovering = candidateData.isNotEmpty;
                                return _buildCharacterDisplay(enemy,
                                    isHovering: hovering);
                              },
                              onWillAcceptWithDetails: (details) =>
                                  isPlayerTurn &&
                                  !isProcessingTurn &&
                                  details.data.type != CardActionType.item &&
                                  hero.currentMana >= details.data.manaCost,
                              onAcceptWithDetails: (details) {
                                if (_draggedCardIndex != null)
                                  _onCardPlayed(
                                      _draggedCardIndex!, details.data);
                              },
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(
                                maxWidth: 400, maxHeight: 120),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ListView.builder(
                              reverse: true,
                              itemCount: battleLog.length,
                              itemBuilder: (context, index) =>
                                  _buildLogEntryWidget(battleLog[index]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isBattleOver)
                      _buildEndBattleButton()
                    else ...[
                      _buildRerollButton(),
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 650),
                          height: 150,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(maxHandSize, (index) {
                              return Expanded(child: _buildSlot(index));
                            }),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlot(int index) {
    final bool hasCard = index < hand.length;
    final BattleCard? card = hasCard ? hand[index] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(animation);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: hasCard
            ? KeyedSubtree(
                key: ValueKey(card!.id + index.toString()),
                child: _buildCardWidget(card, index))
            : _buildEmptyBase(),
      ),
    );
  }

  Widget _buildEmptyBase() {
    return AspectRatio(
      aspectRatio: 0.7,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child:
              Icon(Icons.add, color: Colors.white.withOpacity(0.1), size: 20),
        ),
      ),
    );
  }

  Widget _buildLogEntryWidget(BattleLogEntry entry) {
    IconData iconData;
    Color color;
    switch (entry.type) {
      case LogEntryType.damage:
        iconData = Icons.flash_on;
        color = Colors.redAccent;
        break;
      case LogEntryType.heal:
        iconData = Icons.favorite;
        color = Colors.greenAccent;
        break;
      case LogEntryType.system:
        iconData = Icons.info;
        color = Colors.blueAccent;
        break;
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: color, size: 14),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              entry.message,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  shadows: [Shadow(blurRadius: 1)]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndBattleButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.arrow_back),
      label: const Text('Voltar ao Mapa'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildRerollButton() {
    bool canReroll = rerollPoints > 0 && isPlayerTurn && !isProcessingTurn;
    return Transform.scale(
      scale: 0.9,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.refresh, size: 16),
        label: Text('Trocar Mão ($rerollPoints)'),
        onPressed: canReroll ? _useReroll : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white10,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildCardWidget(BattleCard card, int indexInHand) {
    bool canPlay = isPlayerTurn &&
        !isProcessingTurn &&
        (hero.currentMana >= card.manaCost);

    Widget cardContent = AspectRatio(
      aspectRatio: 0.7,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: canPlay
                ? (card.type == CardActionType.item
                    ? Colors.green
                    : Colors.amber)
                : Colors.grey.shade700,
            width: canPlay ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(2, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (card.manaCost > 0)
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                ),
                child: Text("${card.manaCost}",
                    style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 10)),
              )
            else
              const SizedBox(height: 5),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(card.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.broken_image, color: Colors.white24)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(card.name,
                        maxLines: 1,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 2),
                  LayoutBuilder(builder: (context, constraints) {
                    if (constraints.maxHeight < 20) {
                      return const SizedBox.shrink();
                    }
                    return Text(card.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey, fontSize: 8),
                        textAlign: TextAlign.center);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (!canPlay) {
      return Opacity(opacity: 0.5, child: cardContent);
    }

    return Draggable<BattleCard>(
      data: card,
      feedback: Transform.scale(
          scale: 1.1,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              height: 150,
              child: cardContent,
            ),
          )),
      childWhenDragging: Opacity(opacity: 0.0, child: cardContent),
      onDragStarted: () => setState(() => _draggedCardIndex = indexInHand),
      onDraggableCanceled: (_, __) => setState(() => _draggedCardIndex = null),
      onDragCompleted: () => setState(() => _draggedCardIndex = null),
      child: cardContent,
    );
  }

  Widget _buildCharacterDisplay(GameCharacter char, {bool isHovering = false}) {
    bool isHero = char is HeroCharacter;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: isHero ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isHero ? BorderRadius.circular(12) : null,
            image: DecorationImage(
                image: AssetImage(char.texturePath), fit: BoxFit.cover),
            border: Border.all(
                color: isHovering ? Colors.white : Colors.transparent,
                width: 3),
            boxShadow: [
              if (isHovering)
                BoxShadow(
                    color: isHero ? Colors.green : Colors.red, blurRadius: 20),
              const BoxShadow(
                  color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(char.name,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
        const SizedBox(height: 4),
        _buildStatBar(char.currentHp, char.maxHp,
            _getHpColor(char.currentHp, char.maxHp)),
        if (isHero) ...[
          const SizedBox(height: 2),
          _buildStatBar(char.currentMana, char.maxMana, Colors.blueAccent),
        ]
      ],
    );
  }

  Widget _buildStatBar(int current, int maxVal, Color color) {
    return Container(
      width: 80,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: max(0, min(1, current / maxVal)),
          child: Container(
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ),
    );
  }
}
