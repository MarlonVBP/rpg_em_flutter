import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teste/providers/auth_provider.dart';
import 'package:teste/providers/game_state.dart';
import 'package:teste/screens/auth_wrapper.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),

        ChangeNotifierProxyProvider<AuthProvider, GameState>(
          create: (context) => GameState(null),

          update: (context, authProvider, previousGameState) {
            final currentUserId = authProvider.currentUser?.uid;
            final previousUserId = previousGameState?.currentUserId;

            if (currentUserId != previousUserId) {
              return GameState(authProvider.currentUser);
            }
            return previousGameState ?? GameState(null);
          },
        ),
      ],
      child: MaterialApp(
      title: 'RPG em Flutter',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    ),);
  }
}
