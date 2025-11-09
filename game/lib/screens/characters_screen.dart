import 'package:flutter/material.dart';
import 'package:teste/models/character_model.dart';
import 'package:teste/providers/game_state.dart';
import 'package:provider/provider.dart';
import 'package:teste/screens/create_character_screen.dart';

class CharactersScreen extends StatelessWidget {
  CharactersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Escolha seu Herói')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateCharacterScreen()),
              );
            },
            label: const Text('Criar Novo Herói'),
            icon: const Icon(Icons.add),
            backgroundColor: Colors.white,
            foregroundColor: Colors.deepPurple,
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("images/background_LockerRoom.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  const Color.fromARGB(159, 0, 0, 0),
                  BlendMode.darken,
                ),
              ),
            ),
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.75,
              ),
              itemCount: gameState.availableHeroes.length,
              itemBuilder: (context, index) {
                final hero = gameState.availableHeroes[index];
                final bool isSelected =
                    gameState.selectedHero?.name == hero.name;

                return _buildHeroCard(context, gameState, hero, isSelected);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    GameState gameState,
    HeroCharacter hero,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        gameState.selectHero(hero);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: isSelected ? 8.0 : 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: isSelected ? Colors.deepPurple : Colors.transparent,
            width: 3.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.grey[800],
                child: Image.asset(hero.texturePath, fit: BoxFit.cover),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hero.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Classe: ${hero.heroClass}',
                      style: TextStyle(
                          fontSize: 14, color: Colors.deepPurple[700]),
                    ),
                    Text(
                      'Nível: ${hero.level}',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ATK: ${hero.attack} | DEF: ${hero.defense}',
                    ),
                  ],
                ),
              ),
            ),
            if (isSelected)
              Container(
                color: Colors.deepPurple,
                child: Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
