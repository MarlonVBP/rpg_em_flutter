import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teste/data/models/quest_model.dart';
import 'package:teste/providers/game_state.dart';
import 'package:teste/screens/battle_screen.dart' as battle;

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  int? _selectedStageIndex;

  // Coordenadas exatas das 5 arenas sobre a imagem circuit_map.webp
  static const List<FractionalOffset> _stageOffsets = [
    FractionalOffset(0.13, 0.20), // Fase 1 - Floresta
    FractionalOffset(0.30, 0.49), // Fase 2 - Caverna / Deserto
    FractionalOffset(0.54, 0.72), // Fase 3 - Lava / Vulcão
    FractionalOffset(0.56, 0.19), // Fase 4 - Cemitério Sombrio
    FractionalOffset(0.84, 0.30), // Fase 5 - Castelo (Último Desafio)
  ];

  // Posição do herói ao lado de cada arena no circuito
  static const List<FractionalOffset> _heroOffsets = [
    FractionalOffset(0.05, 0.25),
    FractionalOffset(0.21, 0.53),
    FractionalOffset(0.44, 0.75),
    FractionalOffset(0.47, 0.23),
    FractionalOffset(0.75, 0.35),
  ];

  bool _isStageUnlocked(List<Quest> quests, int index) {
    if (index == 0) return true;
    if (index < 0 || index >= quests.length) return false;
    return quests[index].isCompleted || quests[index - 1].isCompleted;
  }

  int _getCurrentFrontierIndex(List<Quest> quests) {
    for (int i = 0; i < quests.length; i++) {
      if (!quests[i].isCompleted) {
        return i;
      }
    }
    return quests.isEmpty ? 0 : quests.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        final quests = gameState.quests;
        if (quests.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Circuito de Batalha')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final frontierIndex = _getCurrentFrontierIndex(quests);
        final activeIndex = (_selectedStageIndex != null &&
                _selectedStageIndex! < quests.length &&
                _isStageUnlocked(quests, _selectedStageIndex!))
            ? _selectedStageIndex!
            : frontierIndex;

        final selectedQuest = quests[activeIndex];

        return Scaffold(
          backgroundColor: const Color(0xFF12131A),
          appBar: AppBar(
            title: const Text(
              'Circuito de Batalhas',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.grey[900],
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Column(
            children: [
              Expanded(
                child: Center(
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 2.5,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double nodeSize =
                              (constraints.maxWidth * 0.085).clamp(44.0, 76.0);
                          final double heroSize =
                              (constraints.maxWidth * 0.07).clamp(38.0, 62.0);

                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'images/circuit_map.webp',
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Image.asset(
                                    'images/background_quests.webp',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              CustomPaint(
                                painter: _CircuitPathOverlayPainter(
                                  offsets: _stageOffsets,
                                  quests: quests,
                                  activeIndex: activeIndex,
                                ),
                              ),
                              for (int i = 0;
                                  i < quests.length && i < _stageOffsets.length;
                                  i++)
                                Align(
                                  alignment: _stageOffsets[i],
                                  child: _buildCircuitNode(
                                    context: context,
                                    quest: quests[i],
                                    index: i,
                                    size: nodeSize,
                                    isUnlocked: _isStageUnlocked(quests, i),
                                    isSelected: i == activeIndex,
                                    isFrontier: i == frontierIndex,
                                  ),
                                ),
                              if (gameState.selectedHero != null &&
                                  activeIndex < _heroOffsets.length)
                                AnimatedAlign(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutCubic,
                                  alignment: _heroOffsets[activeIndex],
                                  child: _buildHeroToken(
                                    gameState.selectedHero!.texturePath,
                                    gameState.selectedHero!.name,
                                    heroSize,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              _buildSelectedStagePanel(
                  context, gameState, selectedQuest, activeIndex),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircuitNode({
    required BuildContext context,
    required Quest quest,
    required int index,
    required double size,
    required bool isUnlocked,
    required bool isSelected,
    required bool isFrontier,
  }) {
    final bool isCompleted = quest.isCompleted;
    Color borderColor;
    if (!isUnlocked) {
      borderColor = Colors.grey.shade600;
    } else if (isSelected) {
      borderColor = Colors.amberAccent;
    } else if (isCompleted) {
      borderColor = Colors.greenAccent;
    } else {
      borderColor = Colors.redAccent;
    }

    return GestureDetector(
      onTap: () {
        if (!isUnlocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Derrote o chefe da Fase $index primeiro para avançar no circuito!'),
              backgroundColor: Colors.orange.shade900,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        setState(() {
          _selectedStageIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isSelected ? size * 1.12 : size,
            height: isSelected ? size * 1.12 : size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black87,
              border: Border.all(
                color: borderColor,
                width: isSelected ? 3.5 : 2.5,
              ),
              boxShadow: [
                if (isSelected || isFrontier)
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.7),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                const BoxShadow(
                  color: Colors.black87,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipOval(
                  child: ColorFiltered(
                    colorFilter: isUnlocked
                        ? const ColorFilter.mode(
                            Colors.transparent, BlendMode.multiply)
                        : const ColorFilter.mode(
                            Colors.black87, BlendMode.saturation),
                    child: Opacity(
                      opacity: isUnlocked ? 1.0 : 0.45,
                      child: Image.asset(
                        quest.boss.texturePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                if (!isUnlocked)
                  const Center(
                    child: Icon(Icons.lock, color: Colors.white70, size: 24),
                  )
                else if (isCompleted)
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Text(
              index == 4 ? 'Desafio Final' : 'Fase ${index + 1}',
              style: TextStyle(
                color: isUnlocked ? Colors.white : Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroToken(String texturePath, String heroName, double size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.deepPurple.shade900,
            border: Border.all(color: Colors.cyanAccent, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withValues(alpha: 0.6),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              texturePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.cyan.shade900.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'VOCÊ',
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedStagePanel(
    BuildContext context,
    GameState gameState,
    Quest quest,
    int stageIndex,
  ) {
    final boss = quest.boss;
    final isCompleted = quest.isCompleted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D29),
        border: Border(
          top: BorderSide(color: Colors.amber.withValues(alpha: 0.4), width: 2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage(boss.texturePath),
              backgroundColor: Colors.grey[850],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.shade800
                              : Colors.amber.shade800,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          stageIndex == 4
                              ? 'ÚLTIMO DESAFIO'
                              : 'FASE ${stageIndex + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          quest.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${boss.name} • HP: ${boss.maxHp} | ATK: ${boss.attack} | DEF: ${boss.defense}',
                    style: TextStyle(color: Colors.red.shade200, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Recompensa: +${boss.xpReward} XP  •  +${boss.goldReward} Ouro',
                    style:
                        TextStyle(color: Colors.amber.shade300, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              icon: Icon(isCompleted ? Icons.replay : Icons.sports_kabaddi),
              label: Text(isCompleted ? 'Rejogar' : 'Avançar!'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCompleted ? Colors.teal.shade700 : Colors.red.shade700,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (gameState.selectedHero != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => battle.BattleScreen(
                        enemy: boss,
                        stageIndex: stageIndex,
                        onVictory: () => gameState.completeQuest(quest.id),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por favor, escolha um herói antes de entrar no circuito!',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CircuitPathOverlayPainter extends CustomPainter {
  final List<FractionalOffset> offsets;
  final List<Quest> quests;
  final int activeIndex;

  _CircuitPathOverlayPainter({
    required this.offsets,
    required this.quests,
    required this.activeIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int count =
        quests.length < offsets.length ? quests.length : offsets.length;
    if (count < 2) return;

    for (int i = 0; i < count - 1; i++) {
      final p1 = Offset(offsets[i].dx * size.width, offsets[i].dy * size.height);
      final p2 = Offset(
          offsets[i + 1].dx * size.width, offsets[i + 1].dy * size.height);

      final bool segmentCompleted = quests[i].isCompleted;
      final Paint linePaint = Paint()
        ..color = segmentCompleted
            ? Colors.greenAccent.withValues(alpha: 0.75)
            : Colors.white.withValues(alpha: 0.30)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      _drawDashedLine(canvas, p1, p2, linePaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 8.0;
    const double dashSpace = 6.0;
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double distance = Offset(dx, dy).distance;
    if (distance == 0) return;

    final double ux = dx / distance;
    final double uy = dy / distance;

    double start = 0;
    while (start < distance) {
      final double end =
          (start + dashWidth < distance) ? start + dashWidth : distance;
      canvas.drawLine(
        Offset(p1.dx + ux * start, p1.dy + uy * start),
        Offset(p1.dx + ux * end, p1.dy + uy * end),
        paint,
      );
      start += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _CircuitPathOverlayPainter oldDelegate) {
    return oldDelegate.activeIndex != activeIndex ||
        oldDelegate.quests != quests;
  }
}
