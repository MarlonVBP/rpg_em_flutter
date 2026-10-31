import 'package:teste/data/local/all_game_bosses.dart';
import 'package:teste/data/models/quest_model.dart';

final allGameQuests = [
  Quest(
      id: 'boss2',
      title: 'Pilantras Traiçoeiros!',
      description: 'Extermine os goblins arruaceiros que roubam a vila.',
      boss: allGameBosses[1]),
  Quest(
      id: 'boss5',
      title: 'De uma vez por todas.',
      description:
          'Desafie o Líder Orc para um combate, acabando com seu guerreiro mais forte.',
      boss: allGameBosses[2]),
  Quest(
      id: 'boss1',
      title: 'O Fogo da Destruição.',
      description: 'Derrote o Dragão que assola o vale.',
      boss: allGameBosses[0]),
  Quest(
      id: 'boss9',
      title: 'Perna de Urubu, Pena de Galinha...',
      description: 'Acabe com os planos maléficos da bruxa.',
      boss: allGameBosses[3]),
  Quest(
      id: 'boss4',
      title: 'De volta ao túmulo.',
      description:
          'Proteja o vilarejo do ataque daqueles que voltaram dos mortos.',
      boss: allGameBosses[4]),
];
