import 'package:flutter/material.dart';
import 'package:teste/providers/game_state.dart';
import 'package:teste/screens/characters_screen.dart' as characters;
import 'package:teste/screens/items_screen.dart' as items;
import 'package:teste/screens/quests_screen.dart' as quests;
import 'package:teste/screens/cities_screen.dart' as cities;
import 'package:provider/provider.dart';
import 'package:teste/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final gameState = Provider.of<GameState>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/background_home.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildNarrowLayout(context, gameState, authProvider);
          },
        ),
      ),
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    GameState? gameState,
    AuthProvider authProvider,
  ) {
    return Stack(
      children: [
        Positioned(
          left: 48.0,
          top: 48.0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
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
                        builder: (context) => const items.ItemsScreen()),
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
                  onPressed: () {
                    authProvider.logout();
                  },
                  isPrimary: false,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 48.0,
          top: 48.0,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _buildStatusCard(context, gameState),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    GameState? gameState,
    AuthProvider authProvider,
  ) {
    return Center(
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
                    builder: (context) => const items.ItemsScreen()),
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
              onPressed: () {
                authProvider.logout();
              },
              isPrimary: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, GameState? gameState) {
    if (gameState == null ||
        (gameState.currentUserId != null && gameState.quests.isEmpty)) {
      return Card(
        color: Colors.black.withOpacity(0.75),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (gameState.currentUserId == null) {
      return Card(
        color: Colors.black.withOpacity(0.75),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Aguardando login...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      );
    }

    final completedQuests = gameState.quests.where((q) => q.isCompleted).length;
    final totalQuests = gameState.quests.length;

    return Card(
      color: Colors.black.withOpacity(0.75),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Preparação para a Batalha:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(color: Colors.white30),
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber.shade300, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: Colors.white70)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        minimumSize: const Size(280, 0),
        backgroundColor: isPrimary
            ? Colors.red.shade800.withOpacity(0.9)
            : Colors.deepPurple.shade800.withOpacity(0.9),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color:
                  isPrimary ? Colors.red.shade400 : Colors.deepPurple.shade300,
              width: 1,
            )),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
