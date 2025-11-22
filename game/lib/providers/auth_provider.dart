import 'package:flutter/foundation.dart';
import 'package:teste/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;

class AuthProvider with ChangeNotifier {
  final fba.FirebaseAuth _auth = fba.FirebaseAuth.instance;
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(fba.User? firebaseUser) {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      _currentUser =
          User(uid: firebaseUser.uid, email: firebaseUser.email ?? "");
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      print('Tentando login com: $email');
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('Login bem-sucedido!');

      return true;
    } on fba.FirebaseAuthException catch (e) {
      print('Falha no login: ${e.message}');

      return false;
    } catch (e) {
      print('Erro desconhecido no login: $e');

      return false;
    }
  }

  Future<bool> signup(String email, String password) async {
    try {
      print('Tentando cadastro real para: $email');

      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      print('Cadastro real bem-sucedido para: $email');
      return true;
    } on fba.FirebaseAuthException catch (e) {
      print('Falha no cadastro: ${e.message}');
      print(e.message);
    } catch (e) {
      print('Erro desconhecido no cadastro: $e');
      e.toString();
      return false;
    }
    return false;
  }

  Future<void> logout() async {
    print('Fazendo logout...');
    await _auth.signOut();
  }
}
