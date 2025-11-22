import 'package:flutter/material.dart';
import 'package:teste/app/app_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:teste/firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  }

  runApp(const AppWidget());
}
