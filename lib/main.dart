import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prueba2/screens/TransferenciaScreen.dart';
import 'screens/WelcomeScreen.dart';
import 'screens/LoginScreen.dart';
import 'screens/RegistroScreen.dart';
import 'screens/DepositosScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AppBanco());
}

class AppBanco extends StatelessWidget {
  const AppBanco({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/": (context) => const WelcomeScreen(),
        "/login": (context) => const LoginScreen(),
        "/registro": (context) => const RegistroScreen(),
        "/transferencias": (context) => const TransferenciaScreen(),
        "/depositos": (context) => const DepositosScreen(),
      },
    );
  }
}