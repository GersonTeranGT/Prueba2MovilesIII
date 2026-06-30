import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(child: Container(width: 300, child: formulario(context))),
    );
  }
}

Widget formulario(context) {
  TextEditingController correo = TextEditingController();
  TextEditingController contrasenia = TextEditingController();

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextField(
        controller: correo,
        decoration: const InputDecoration(labelText: "Correo"),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: contrasenia,
        decoration: const InputDecoration(labelText: "Contraseña"),
        obscureText: true,
      ),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: () => login(context, correo, contrasenia),
        label: const Text("Login"),
        icon: const Icon(Icons.login),
      ),
    ],
  );
}

Future<void> login(context, correo, contrasenia) async {
  // Validar campos vacíos
  if (correo.text.isEmpty || contrasenia.text.isEmpty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: const Text("Complete todos los campos"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
    return;
  }

  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: correo.text,
      password: contrasenia.text
    );

    Navigator.pushNamed(context, "/transferencias");
  } on FirebaseAuthException catch (e) {
    String mensaje = "Error al iniciar sesión";
    
    if (e.code == 'user-not-found') {
      mensaje = "Usuario no encontrado";
    } else if (e.code == 'wrong-password') {
      mensaje = "Contraseña incorrecta";
    } else if (e.code == 'invalid-email') {
      mensaje = "Correo electrónico no válido";
    } else {
      mensaje = "Error: ${e.code}";
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text("Error inesperado: $e"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}