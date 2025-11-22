import 'package:teste/data/local/all_game_bosses.dart';
import 'package:teste/data/models/quest_model.dart';

final allGameQuests = [
      Quest(
          id: 'boss1',
          title: 'A Ameaça Vermelha',
          description: 'Derrote o Círculo da Fúria que aterroriza a cidade.',
          boss: allGameBosses[0]),
      Quest(
        id: 'boss2',
        title: 'Escuridão Profunda',
        description: 'Enfrente o Círculo Sombrio que emerge das ruínas.',
        boss: allGameBosses[1],
      ),
    ];