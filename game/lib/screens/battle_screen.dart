import 'dart:math';
import 'package:flutter/material.dart';
import 'package:teste/models/character_model.dart' as character;
import 'package:teste/models/item_model.dart';
import 'package:teste/providers/game_state.dart';
import 'package:provider/provider.dart';
import 'package:teste/models/battle_card_model.dart'; // Importa o modelo de carta

// NOVO: Enum para os tipos de log
enum LogEntryType { damage, heal, system }

// NOVO: Classe para estruturar o log
class BattleLogEntry {
  final String message;
  final LogEntryType type;
  BattleLogEntry(this.message, this.type);
}

class BattleScreen extends StatefulWidget {
  final character.EnemyCharacter enemy;
  final VoidCallback onVictory;

  const BattleScreen({super.key, required this.enemy, required this.onVictory});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late GameState gameState;
  late character.HeroCharacter hero;
  late character.EnemyCharacter enemy;
  late String backgroundPath;
  bool isPlayerTurn = true;
  bool isProcessingTurn = false;

  // --- Variáveis do Card Game ---
  List<BattleCard> deck = [];
  List<BattleCard> hand = [];
  List<BattleCard> discardPile = [];
  final int maxHandSize = 5;
  final GlobalKey<AnimatedListState> _handListKey =
      GlobalKey<AnimatedListState>();

  // --- NOVOS ESTADOS ---
  List<BattleLogEntry> battleLog = []; // Agora usa a nova classe
  int rerollPoints = 5;
  int? _draggedCardIndex;

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
    backgroundPath =
        gameState.selectedScenario ?? 'assets/images/battle_city.png';

    _applyItemBonuses();
    _buildInitialDeck();
    _logAction('A batalha contra ${enemy.name} começou!', LogEntryType.system);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPlayerTurn();
    });
  }

  void _applyItemBonuses() {
    int attackBonus = 0;
    int defenseBonus = 0;
    for (var item in gameState.playerInventory) {
      attackBonus += item.attackBonus;
      defenseBonus += item.defenseBonus;
    }
    hero.attack += attackBonus;
    hero.defense += defenseBonus;
    if (attackBonus > 0 || defenseBonus > 0) {
      _logAction(
        '${hero.name} equipou seus itens. ATK+$attackBonus, DEF+$defenseBonus.',
        LogEntryType.system,
      );
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
        imagePath: 'images/small_sword.png', // Imagem atualizada
        type: CardActionType.attack,
      ),
    ));

    deck.addAll(List.generate(
      2,
      (index) => BattleCard(
        id: 'fireball',
        name: 'Bola de Fogo',
        description: 'Causa ${hero.attack * 3} de dano mágico.',
        imagePath: 'images/placeholder.png', // TODO: Usar imagem de fogo
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

  // ATUALIZADO: _logAction agora aceita um tipo
  void _logAction(String action, LogEntryType type) {
    setState(() {
      battleLog.insert(0, BattleLogEntry(action, type));
    });
  }

  // --- LÓGICA PRINCIPAL DO JOGO DE CARTAS ---

  void _startPlayerTurn() {
    setState(() {
      isPlayerTurn = true;
      isProcessingTurn = false;
      hero.currentMana = min(hero.maxMana, hero.currentMana + 10);
      _logAction('${hero.name} regenerou 10 de mana.', LogEntryType.system);
    });
    _drawHand();
  }

  Future<void> _drawHand() async {
    int cardsToDraw = maxHandSize - hand.length;
    if (cardsToDraw <= 0) return;

    if (deck.length < cardsToDraw) {
      if (discardPile.isNotEmpty) {
        _logAction('Embaralhando o descarte...', LogEntryType.system);
        await Future.delayed(const Duration(milliseconds: 700));

        deck.addAll(discardPile);
        deck.shuffle(Random());
        discardPile.clear();
      } else {
        _logAction('Não há mais cartas para puxar!', LogEntryType.system);
      }
    }

    for (int i = 0; i < cardsToDraw; i++) {
      if (deck.isEmpty) break;

      final card = deck.removeLast();
      hand.add(card);
      _handListKey.currentState?.insertItem(
        hand.length - 1,
        duration: const Duration(milliseconds: 300),
      );
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _useReroll() async {
    if (rerollPoints <= 0 || !isPlayerTurn || isProcessingTurn) {
      return;
    }

    setState(() {
      isProcessingTurn = true;
      rerollPoints--;
      _logAction(
        'Você gasta 1 ponto para reembaralhar sua mão!',
        LogEntryType.system,
      );
    });

    _discardHand();
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

    final removedCard = hand.removeAt(indexInHand);
    _handListKey.currentState?.removeItem(
      indexInHand,
      (context, animation) => _buildAnimatedCard(removedCard, animation),
      duration: const Duration(milliseconds: 300),
    );

    if (removedCard.type != CardActionType.item) {
      discardPile.add(removedCard);
    }

    _endTurn();
  }

  // ATUALIZADO: Chamadas de _logAction com tipo
  void _playCardEffect(BattleCard card) {
    switch (card.id) {
      case 'attack':
        final random = Random();
        int baseDamage = hero.attack;
        int damage = max(0, baseDamage - enemy.defense);
        bool isCritical = random.nextDouble() < 0.20;

        if (isCritical) {
          damage *= 2;
          _logAction(
            'ACERTO CRÍTICO! ${hero.name} causou $damage de dano!',
            LogEntryType.damage,
          );
        } else {
          _logAction(
            '${hero.name} atacou e causou $damage de dano!',
            LogEntryType.damage,
          );
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
        _logAction(
          '${hero.name} usou ${card.name} e causou $damage de dano!',
          LogEntryType.damage,
        );
        break;

      case 'health_potion':
        final item = card.sourceItem;
        if (item != null) {
          setState(() {
            hero.currentHp = min(hero.maxHp, hero.currentHp + item.healAmount);
          });
          _logAction(
            '${hero.name} usou ${item.name} e curou ${item.healAmount} de HP!',
            LogEntryType.heal,
          );
          gameState.removeItemFromInventory(item);
        }
        break;
    }
  }

  // --- LÓGICA DE TURNOS (Inimigo) ---

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

  void _discardHand() {
    for (int i = hand.length - 1; i >= 0; i--) {
      final card = hand.removeAt(i);
      _handListKey.currentState?.removeItem(
        i,
        (context, animation) =>
            _buildAnimatedCard(card, animation, isDiscarding: true),
        duration: const Duration(milliseconds: 200),
      );
      discardPile.add(card);
    }
  }

  // ATUALIZADO: Chamadas de _logAction com tipo
  void _enemyTurn() {
    _discardHand();

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      _logAction('Turno de ${enemy.name}.', LogEntryType.system);
      int damage = max(0, enemy.attack - hero.defense);

      setState(() {
        hero.currentHp -= damage;
      });
      _logAction(
        '${enemy.name} atacou e causou $damage de dano!',
        LogEntryType.damage,
      );

      if (_checkBattleStatus()) return;

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _startPlayerTurn();
        }
      });
    });
  }

  // ATUALIZADO: Chamadas de _logAction com tipo
  bool _checkBattleStatus() {
    bool isBattleOver = false;
    if (hero.currentHp <= 0) {
      hero.currentHp = 0;
      _logAction("Você morreu!", LogEntryType.system);
      isBattleOver = true;
    } else if (enemy.currentHp <= 0) {
      enemy.currentHp = 0;
      _logAction("${enemy.name} foi derrotado!", LogEntryType.system);
      isBattleOver = true;

      widget.onVictory();

      _logAction(
        "Você ganhou ${enemy.xpReward} de XP e ${enemy.goldReward} moedas!",
        LogEntryType.system,
      );
      gameState.addGold(enemy.goldReward);

      if (enemy.lootTable.isNotEmpty) {
        final random = Random();
        if (random.nextDouble() < 0.5) {
          final droppedItem =
              enemy.lootTable[random.nextInt(enemy.lootTable.length)];
          gameState.addItemToInventory(droppedItem);
          _logAction(
            "Você encontrou um item: ${droppedItem.name}!",
            LogEntryType.system,
          );
        }
      }
      setState(() {
        hero.xp += enemy.xpReward;
        if (hero.xp >= hero.xpToNextLevel) {
          hero.levelUp();
          _logAction(
            "Subiu de nível! Você agora é nível ${hero.level}!",
            LogEntryType.system,
          );
          _logAction(
            "Status melhorados! Próximo nível em ${hero.xpToNextLevel} XP.",
            LogEntryType.system,
          );
        } else {
          hero.restoreStats();
          _logAction("HP e Mana restaurados!", LogEntryType.system);
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
    if (percentage > 0.6) return Colors.green;
    if (percentage > 0.3) return Colors.yellow;
    return Colors.red;
  }

  // --- ÁREA DE CONSTRUÇÃO DE UI (Build) ---

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
            // 1. Display do Herói e Inimigo (com DragTargets)
            Expanded(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // --- DragTarget em volta do HERÓI (para poções) ---
                  DragTarget<BattleCard>(
                    builder: (context, candidateData, rejectedData) {
                      final hoveringCard =
                          candidateData.isNotEmpty ? candidateData.first : null;
                      bool canAccept = hoveringCard != null &&
                          hoveringCard.type == CardActionType.item;

                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: canAccept &&
                                  isPlayerTurn &&
                                  !isProcessingTurn
                              ? [
                                  BoxShadow(
                                    color: Colors.green.shade700,
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  )
                                ]
                              : [],
                        ),
                        child: _buildCharacterDisplay(hero),
                      );
                    },
                    // Aceita apenas cartas de ITEM
                    onWillAcceptWithDetails: (details) {
                      final card = details.data;
                      return isPlayerTurn &&
                          !isProcessingTurn &&
                          card.type == CardActionType.item;
                    },
                    onAcceptWithDetails: (details) {
                      if (_draggedCardIndex != null) {
                        _onCardPlayed(_draggedCardIndex!, details.data);
                      }
                    },
                  ),

                  // --- DragTarget em volta do INIMIGO (para ataques) ---
                  DragTarget<BattleCard>(
                    builder: (context, candidateData, rejectedData) {
                      final hoveringCard =
                          candidateData.isNotEmpty ? candidateData.first : null;
                      bool canAccept = hoveringCard != null &&
                          hoveringCard.type != CardActionType.item &&
                          (hero.currentMana >= hoveringCard.manaCost);

                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: canAccept &&
                                  isPlayerTurn &&
                                  !isProcessingTurn
                              ? [
                                  BoxShadow(
                                    color: Colors.red.shade700,
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  )
                                ]
                              : [],
                        ),
                        child: _buildCharacterDisplay(enemy),
                      );
                    },
                    // Aceita cartas que NÃO SÃO de item
                    onWillAcceptWithDetails: (details) {
                      final card = details.data;
                      return isPlayerTurn &&
                          !isProcessingTurn &&
                          (hero.currentMana >= card.manaCost) &&
                          card.type != CardActionType.item;
                    },
                    onAcceptWithDetails: (details) {
                      if (_draggedCardIndex != null) {
                        _onCardPlayed(_draggedCardIndex!, details.data);
                      }
                    },
                  ),
                ],
              ),
            ),
            // 2. Log de Batalha (ATUALIZADO)
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.black.withOpacity(0.6),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                padding: const EdgeInsets.all(8),
                child: ListView.builder(
                  reverse: true,
                  itemCount: battleLog.length,
                  itemBuilder: (context, index) {
                    // Agora constrói o widget de log customizado
                    return _buildLogEntryWidget(battleLog[index]);
                  },
                ),
              ),
            ),
            // 3. Área de Ação
            if (isBattleOver)
              _buildEndBattleButton()
            else
              _buildPlayerActionArea(),
          ],
        ),
      ),
    );
  }

  // --- NOVOS WIDGETS DE UI ---

  // NOVO: Widget para o Log de Batalha
  Widget _buildLogEntryWidget(BattleLogEntry entry) {
    IconData iconData;
    Color iconColor;

    switch (entry.type) {
      case LogEntryType.damage:
        iconData = Icons.gavel; // Pode ser 'whatshot' para magia
        iconColor = Colors.red.shade300;
        break;
      case LogEntryType.heal:
        iconData = Icons.healing;
        iconColor = Colors.green.shade300;
        break;
      case LogEntryType.system:
        iconData = Icons.info_outline;
        iconColor = Colors.blue.shade300;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(iconData, color: iconColor, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.message,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 2)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndBattleButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.arrow_back),
        label: const Text('Fim da Batalha. Voltar.'),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildPlayerActionArea() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Column(
        children: [
          _buildRerollButton(),
          const SizedBox(height: 10),
          Container(
            height: 190, // Altura da "mão"
            child: Center(
              child: AnimatedList(
                key: _handListKey,
                scrollDirection: Axis.horizontal,
                initialItemCount: hand.length,
                shrinkWrap: true,
                itemBuilder: (context, index, animation) {
                  if (index < hand.length) {
                    final card = hand[index];
                    return _buildAnimatedCard(card, animation, index: index);
                  }
                  return Container();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRerollButton() {
    bool canReroll = rerollPoints > 0 && isPlayerTurn && !isProcessingTurn;
    return ElevatedButton.icon(
      icon: const Icon(Icons.shuffle, size: 18),
      label: Text('Reembaralhar (${rerollPoints}x)'),
      onPressed: canReroll ? _useReroll : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade800.withOpacity(0.9),
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade800.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.blue.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  Widget _buildAnimatedCard(BattleCard card, Animation<double> animation,
      {int? index, bool isDiscarding = false}) {
    Widget cardWidget = _buildCardWidget(card, index);

    if (isDiscarding) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, 2),
        ).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: cardWidget,
        ),
      );
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: cardWidget,
      ),
    );
  }

  // ATUALIZADO: Conteúdo da carta agora centralizado
  Widget _buildCardWidget(BattleCard card, int? indexInHand) {
    bool canPlay = isPlayerTurn &&
        !isProcessingTurn &&
        (hero.currentMana >= card.manaCost);
    
    final cardVisual = Container(
      width: 120,
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canPlay ? Colors.yellow.shade600 : Colors.grey.shade800,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 6,
            offset: const Offset(2, 2),
          )
        ],
      ),
      child: Opacity(
        opacity: canPlay ? 1.0 : 0.6,
        // *** INÍCIO DA CORREÇÃO DE CENTRALIZAÇÃO ***
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
          children: [
            // 1. Custo de Mana
            if (card.manaCost > 0)
              Container(
                padding: const EdgeInsets.all(4),
                // O container de mana fica fora da centralização principal
                // para ficar no topo, mas podemos envolvê-lo
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flash_on, color: Colors.white, size: 16),
                    Text(
                      '${card.manaCost} Mana',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            // Espaçador para empurrar o custo de mana para cima
            const Spacer(), 
            
            // 2. Título da Carta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                card.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            // 3. Imagem da Carta
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  card.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, e, s) => const Icon(
                      Icons.image_not_supported,
                      color: Colors.white60),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 4. Descrição
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                card.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                maxLines: 2, // Limita a 2 linhas
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(), // Espaçador para centralizar o bloco
          ],
        ),
        // *** FIM DA CORREÇÃO DE CENTRALIZAÇÃO ***
      ),
    );

    if (indexInHand == null) {
      return cardVisual;
    }

    return Draggable<BattleCard>(
      data: card,
      feedback: Material(
        color: Colors.transparent,
        child: cardVisual,
      ),
      childWhenDragging: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.grey.shade800,
              width: 2,
              style: BorderStyle.solid),
        ),
      ),
      onDragStarted: () {
        if (!canPlay) return;
        setState(() {
          _draggedCardIndex = indexInHand;
        });
      },
      onDraggableCanceled: (_, __) {
        setState(() {
          _draggedCardIndex = null;
        });
      },
      maxSimultaneousDrags: canPlay ? 1 : 0,
      child: cardVisual,
    );
  }

  // (Widget _buildCharacterDisplay permanece igual)
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

  // (Widget _buildStatBar permanece igual)
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