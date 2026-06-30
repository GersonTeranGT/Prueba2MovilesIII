import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TransferenciaScreen extends StatefulWidget {
  const TransferenciaScreen({super.key});

  @override
  State<TransferenciaScreen> createState() => TransferenciaScreenState();
}

class TransferenciaScreenState extends State<TransferenciaScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    const TransferenciasWidget(),
    const DepositosWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transacciones"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Cerrar sesión"),
                  content: const Text("¿Está seguro?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, "/");
                      },
                      child: const Text("Salir"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            label: "Transferencias",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: "Depósitos",
          ),
        ],
      ),
    );
  }
}

class TransferenciasWidget extends StatefulWidget {
  const TransferenciasWidget({super.key});

  @override
  State<TransferenciasWidget> createState() => TransferenciasWidgetState();
}

class TransferenciasWidgetState extends State<TransferenciasWidget> {
  TextEditingController idTransferencia = TextEditingController();
  TextEditingController destinatario = TextEditingController();
  TextEditingController monto = TextEditingController();
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  void guardarTransferencia() async {
    if (idTransferencia.text.isEmpty ||
        destinatario.text.isEmpty ||
        monto.text.isEmpty) {
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
      final ref = db.child("transferencias/${idTransferencia.text}");
      await ref.set({
        "id": idTransferencia.text,
        "destinatario": destinatario.text,
        "monto": double.parse(monto.text),
        "usuario": FirebaseAuth.instance.currentUser?.email ?? "anonimo",
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Éxito"),
          content: const Text("Transferencia guardada"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                idTransferencia.clear();
                destinatario.clear();
                monto.clear();
              },
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
          content: Text("Error al guardar: $e"),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Transferencias",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: idTransferencia,
            decoration: const InputDecoration(
              labelText: "ID de transferencia",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: destinatario,
            decoration: const InputDecoration(
              labelText: "Nombre del destinatario",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: monto,
            decoration: const InputDecoration(
              labelText: "Monto a transferir",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 30),
          FilledButton(
            onPressed: guardarTransferencia,
            child: const Text("Guardar Transferencia"),
          ),
        ],
      ),
    );
  }
}

class DepositosWidget extends StatefulWidget {
  const DepositosWidget({super.key});

  @override
  State<DepositosWidget> createState() => DepositosWidgetState();
}

class DepositosWidgetState extends State<DepositosWidget> {
  List<dynamic> depositos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDepositos();
  }

  Future<void> cargarDepositos() async {
    try {
      final response = await http.get(
        Uri.parse('https://jritsqmet.github.io/web-api/depositos.json'),
      );

      if (response.statusCode == 200) {
        setState(() {
          depositos = json.decode(response.body);
          cargando = false;
        });
      } else {
        setState(() {
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        cargando = false;
      });
    }
  }

  void verDetalles(BuildContext context, item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Detalles del Depósito"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ID: ${item['id']}"),
            const SizedBox(height: 5),
            Text("Banco: ${item['banco']}"),
            const SizedBox(height: 5),
            Text("Monto: \$ ${item['monto']}"),
            const SizedBox(height: 5),
            Text("Fecha: ${item['fecha']}"),
            const SizedBox(height: 5),
            Text("Origen: ${item['origen']['nombre']}"),
            const SizedBox(height: 5),
            Text("Cuenta: ${item['origen']['número_cuenta']}"),
            const SizedBox(height: 5),
            Text("Destino: ${item['destino']['nombre']}"),
            const SizedBox(height: 5),
            Text("Método: ${item['detalles']['método_pago']}"),
            const SizedBox(height: 5),
            Text("Estado: ${item['detalles']['estado']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Depósitos",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: cargando
                ? const Center(child: CircularProgressIndicator())
                : depositos.isEmpty
                ? const Center(child: Text("No hay depósitos"))
                : ListView.builder(
                    itemCount: depositos.length,
                    itemBuilder: (context, index) {
                      final item = depositos[index];
                      return Card(
                        child: ListTile(
                          leading: Image.network(
                            item['detalles']['imagen_comprobante'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.account_balance,
                                size: 40,
                              );
                            },
                          ),
                          title: Text("\$ ${item['monto']}"),
                          subtitle: Text(item['banco']),
                          onTap: () => verDetalles(context, item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
