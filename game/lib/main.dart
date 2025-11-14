import 'package:flutter/material.dart';
import 'package:teste/providers/auth_provider.dart'; // Importe o AuthProvider
import 'package:teste/providers/game_state.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:teste/firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:teste/screens/auth_wrapper.dart'; // Importe o Wrapper

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  }

  runApp(
    // Use MultiProvider para registar ambos os providers
    MultiProvider(
      providers: [
        // 1. O Provider de Autenticação (independente)
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),

        // 2. O GameState agora depende do AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, GameState>(
          // O 'create' inicializa o GameState (sem usuário)
          create: (context) => GameState(null),

          // O 'update' é chamado sempre que o AuthProvider muda (ex: login/logout)
          // Ele reconstrói o GameState com o novo usuário (ou null)
          update: (context, authProvider, previousGameState) {
            // Se o usuário mudou (login/logout), criamos um novo GameState
            // Se o usuário for o mesmo, reutilizamos o estado anterior
            final currentUserId = authProvider.currentUser?.uid;
            final previousUserId = previousGameState?.currentUserId;

            if (currentUserId != previousUserId) {
              return GameState(authProvider.currentUser);
            }
            return previousGameState ?? GameState(null);
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App Flutter',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // A casa do app agora é o AuthWrapper
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
