import 'package:flutter/material.dart';
import 'package:teste/models/character_model.dart';
import 'package:teste/screens/battle_screen.dart' as battle;
import 'package:provider/provider.dart';
import 'package:teste/providers/game_state.dart';
import 'package:teste/models/item_model.dart';
import 'package:teste/models/quest_model.dart';

class QuestsScreen extends StatelessWidget {
  QuestsScreen({super.key});

  final List<EnemyCharacter> bosses = [
    EnemyCharacter(
        name: 'Círculo Vermelho da Fúria',
        texturePath: 'images/red_circle_texture.png',
        hp: 300,
        attack: 20,
        xpReward: 100,
        goldReward: 50,
        lootTable: [
          const GameItem(
              name: 'Poção de Cura',
              description: 'Restaura 50 HP',
              type: ItemType.potion,
              imagePath: 'images/health_potion.png',
              healAmount: 50,
              price: 10),
        ]),
    EnemyCharacter(
        name: 'Círculo Sombrio do Abismo',
        texturePath: 'images/dark_circle_texture.png',
        hp: 500,
        attack: 12,
        defense: 8,
        xpReward: 250,
        goldReward: 120,
        lootTable: [
          const GameItem(
              name: 'Espada Curta',
              description: '+5 de Ataque',
              type: ItemType.sword,
              imagePath: 'images/small_sword.png',
              attackBonus: 5,
              price: 50),
        ]),
  ];
  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Selecione a Missão',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.grey[900],
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/background_quests.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: gameState.quests.length,
              itemBuilder: (context, index) {
                final quest = gameState.quests[index];
                return _buildQuestCard(context, quest, gameState);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestCard(
    BuildContext context,
    Quest quest,
    GameState gameState,
  ) {
    final boss = quest.boss;
    final bool isCompleted = quest.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: isCompleted
          ? Colors.green.withOpacity(0.5)
          : const Color.fromARGB(163, 0, 0, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage(boss.texturePath),
              backgroundColor: Colors.grey[800],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chefe: ${boss.name}',
                    style: TextStyle(color: Colors.red.shade200, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: isCompleted
                  ? null
                  : () {
                      if (gameState.selectedHero != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => battle.BattleScreen(
                              enemy: boss,
                              onVictory: () =>
                                  gameState.completeQuest(quest.id),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Por favor, escolha um herói antes de iniciar uma missão!',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCompleted ? Colors.grey : Colors.red.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(isCompleted ? 'Concluído' : 'Lutar!'),
            ),
          ],
        ),
      ),
    );
  }
}
