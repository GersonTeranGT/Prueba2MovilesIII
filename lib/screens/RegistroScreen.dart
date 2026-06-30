import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistroScreen extends StatelessWidget {
  const RegistroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro"),
      ),
      body: Center(child: Container(width: 300, child: formulario(context))),
    );
  }
}

Widget formulario(context) {
  TextEditingController correo = TextEditingController();
  TextEditingController contrasenia = TextEditingController();
  TextEditingController nombre = TextEditingController();
  TextEditingController telefono = TextEditingController();

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextField(controller: nombre, decoration: const InputDecoration(labelText: "Nombre")),
      const SizedBox(height: 10),
      TextField(controller: telefono, decoration: const InputDecoration(labelText: "Teléfono")),
      const SizedBox(height: 10),
      TextField(controller: correo, decoration: const InputDecoration(labelText: "Correo")),
      const SizedBox(height: 10),
      TextField(controller: contrasenia, decoration: const InputDecoration(labelText: "Contraseña"), obscureText: true),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: () => registro(context, correo, contrasenia),
        label: const Text("Registro"),
      ),
    ],
  );
}

Future<void> registro(context, correo, contrasenia) async {
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
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: correo.text,
          password: contrasenia.text,
        );

    Navigator.pushNamed(context, "/login");
  } on FirebaseAuthException catch (e) {
    String mensaje = "Error en el registro";
    
    if (e.code == 'weak-password') {
      mensaje = "La contraseña es muy débil";
    } else if (e.code == 'email-already-in-use') {
      mensaje = "El correo ya existe";
    } else if (e.code == 'invalid-email') {
      mensaje = "Correo electrónico no válido";
    } else if (e.code == 'operation-not-allowed') {
      mensaje = "Registro no habilitado";
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