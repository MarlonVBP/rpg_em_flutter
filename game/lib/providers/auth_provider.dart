import 'package:flutter/foundation.dart';
import 'package:teste/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  // Dados Mockados -> TODO: Integrar com Firebase Auth

  Future<bool> login(String email, String password) async {
    const String mockEmail = 'jogador@rpg.com';
    const String mockPassword = '123456';

    print('Tentando login com: $email');
    await Future.delayed(const Duration(seconds: 1));

    if (email == mockEmail && password == mockPassword) {
      print('Login mockado bem-sucedido!');
      _currentUser = User(uid: 'mock-uid-12345', email: email);
      notifyListeners();
      return true; // Sucesso
    } else {
      print('Credenciais mockadas incorretas!');
      return false; // Falha
    }
  }

  Future<bool> signup(String email, String password) async {
    // Simulação de cadastro
    print('Simulando cadastro para: $email');
    await Future.delayed(const Duration(seconds: 1));

    // ---- ALTERAÇÃO AQUI ----
    // No futuro, aqui você chamaria Firebase Auth (createUserWithEmailAndPassword)

    print('Cadastro mockado bem-sucedido para: $email');
    return true;
  }

  Future<void> logout() async {
    print('Simulando logout');
    _currentUser = null;
    notifyListeners();
  }
}
