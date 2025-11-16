import 'package:flutter/foundation.dart';
import 'package:teste/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as fba; // Importa o Firebase Auth

class AuthProvider with ChangeNotifier {
  final fba.FirebaseAuth _auth =
      fba.FirebaseAuth.instance; // Instância real do Firebase Auth
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    // Ouve as mudanças de estado de autenticação do Firebase
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Este método é chamado automaticamente pelo Firebase quando o usuário
  // loga ou desloga
  void _onAuthStateChanged(fba.User? firebaseUser) {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      // Mapeia o usuário do Firebase para o seu modelo User
      _currentUser =
          User(uid: firebaseUser.uid, email: firebaseUser.email ?? "");
    }
    // Notifica todos os widgets (como o AuthWrapper) que o estado mudou
    notifyListeners();
  }

  // Implementação real do Login
  Future<bool> login(String email, String password) async {
    try {
      print('Tentando login com: $email');
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('Login bem-sucedido!');
      // _onAuthStateChanged será chamado automaticamente pelo listener
      return true;
    } on fba.FirebaseAuthException catch (e) {
      // Trata erros comuns de login
      print('Falha no login: ${e.message}');
      return false;
    } catch (e) {
      print('Erro desconhecido no login: $e');
      return false;
    }
  }

  // Implementação real do Signup
  Future<bool> signup(String email, String password) async {
    try {
      print('Simulando cadastro para: $email');
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      print('Cadastro bem-sucedido para: $email');
      // O usuário pode ser logado automaticamente ou não, dependendo da config.
      // Se não logar, ele será direcionado para a tela de login.
      return true;
    } on fba.FirebaseAuthException catch (e) {
      print('Falha no cadastro: ${e.message}');
      return false;
    } catch (e) {
      print('Erro desconhecido no cadastro: $e');
      return false;
    }
  }

  // Implementação real do Logout
  Future<void> logout() async {
    print('Fazendo logout...');
    await _auth.signOut();
    // _onAuthStateChanged será chamado automaticamente pelo listener
  }
}
