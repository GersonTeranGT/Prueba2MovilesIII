import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Banco App",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text("Tu banco de confianza"),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, "/login"),
                child: const Text("Login"),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, "/registro"),
                child: const Text("Registro"),
              ),
              const SizedBox(height: 40),
              const Column(
                children: [
                  Text(
                    "Desarrollado por:",
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    "Gerson Teran",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("GersonTeranGT"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}