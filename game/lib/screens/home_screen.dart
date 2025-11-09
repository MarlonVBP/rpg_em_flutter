import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:teste/providers/game_state.dart';
import 'package:teste/screens/characters_screen.dart' as characters;
import 'package:teste/screens/items_screen.dart' as items;
import 'package:teste/screens/quests_screen.dart' as quests;
import 'package:teste/screens/cities_screen.dart' as cities;
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Menu Principal RPG'),
            elevation: 4.0,
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("images/background_home.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  const Color.fromARGB(255, 255, 255, 255),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildStatusCard(context, gameState),
                    const SizedBox(height: 40),
                    _buildNavigationButton(
                      context: context,
                      icon: Icons.person_search,
                      label: 'Personagens',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => characters.CharactersScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildNavigationButton(
                      context: context,
                      icon: Icons.shield,
                      label: 'Itens',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => items.ItemsScreen()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildNavigationButton(
                      context: context,
                      icon: Icons.landscape,
                      label: 'Cenários',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const cities.CitiesScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildNavigationButton(
                      context: context,
                      icon: Icons.gavel,
                      label: 'Missões',
                      isPrimary: true,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => quests.QuestsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildNavigationButton(
                      context: context,
                      icon: Icons.exit_to_app,
                      label: 'Sair do Jogo',
                      onPressed: kIsWeb ? () {} : () => exit(0),
                      isPrimary: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(BuildContext context, GameState gameState) {
    final completedQuests = gameState.quests.where((q) => q.isCompleted).length;
    final totalQuests = gameState.quests.length;

    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preparação para a Batalha:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(color: Colors.grey),
            _statusTile(
              icon: Icons.person,
              label: 'Herói',
              value: gameState.selectedHero?.name ?? "Nenhum",
            ),
            _statusTile(
              icon: Icons.inventory_2,
              label: 'Itens no Inventário',
              value: gameState.playerInventory.length.toString(),
            ),
            _statusTile(
              icon: Icons.map,
              label: 'Cenário',
              value: gameState.selectedScenario
                      ?.split('/')
                      .last
                      .split('.')
                      .first
                      .replaceAll('_', ' ') ??
                  "Nenhum",
            ),
             _statusTile(
            icon: Icons.assignment_turned_in,
            label: 'Missões Concluídas',
            value: '$completedQuests / $totalQuests',
          ),
          ],
        ),
      ),
    );
  }

  Widget _statusTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber.shade200, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: Colors.white70)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor:
            isPrimary ? Colors.red.shade800 : Colors.deepPurple.shade800,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
    );
  }
}
