import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class DepositosScreen extends StatefulWidget {
  const DepositosScreen({super.key});

  @override
  State<DepositosScreen> createState() => DepositosScreenState();
}

class DepositosScreenState extends State<DepositosScreen> {
  int selectedIndex = 1;

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

class TransferenciasWidget extends StatelessWidget {
  const TransferenciasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Transferencias"));
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
  String error = '';

  @override
  void initState() {
    super.initState();
    cargarDepositos();
  }

  Future<void> cargarDepositos() async {
    try {
      print('Cargando depositos...');
      final response = await http.get(
        Uri.parse('https://jritsqmet.github.io/web-api/depositos.json'),
      );

      print('Status code: ${response.statusCode}');
      print('Respuesta: ${response.body.substring(0, 100)}...');

      if (response.statusCode == 200) {
        setState(() {
          depositos = json.decode(response.body);
          cargando = false;
          print('Depositos cargados: ${depositos.length}');
        });
      } else {
        setState(() {
          cargando = false;
          error = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        cargando = false;
        error = 'Error: $e';
      });
      print('Error: $e');
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
            Text("Monto: S/. ${item['monto']}"),
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
                : error.isNotEmpty
                ? Center(child: Text(error))
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
                          title: Text("S/. ${item['monto']}"),
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
