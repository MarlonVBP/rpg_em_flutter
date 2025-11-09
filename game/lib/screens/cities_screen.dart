import 'package:flutter/material.dart';
import 'package:teste/providers/game_state.dart';
import 'package:provider/provider.dart';

class CitiesScreen extends StatelessWidget {
  const CitiesScreen({super.key});

  final Map<String, String> availableScenarios = const {
    'Floresta Sombria': 'images/battle_forest.png',
    'Picos Congelados': 'images/battle_snow.png',
    'Ruínas Antigas': 'images/battle_ruins.png',
    'Cidade Mercante': 'images/battle_city.png',
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Escolha o Cenário')),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("images/background_scenes.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 4 / 3,
              ),
              itemCount: availableScenarios.length,
              itemBuilder: (context, index) {
                final scenarioName = availableScenarios.keys.elementAt(index);
                final scenarioPath = availableScenarios.values.elementAt(index);
                final isSelected = gameState.selectedScenario == scenarioPath;

                return _buildScenarioCard(
                  context,
                  gameState,
                  scenarioName,
                  scenarioPath,
                  isSelected,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildScenarioCard(
    BuildContext context,
    GameState gameState,
    String name,
    String imagePath,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        gameState.selectScenario(imagePath);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: isSelected ? 8.0 : 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: isSelected ? Colors.teal : Colors.transparent,
            width: 3.0,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 2.0)],
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.check, color: Colors.white, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
