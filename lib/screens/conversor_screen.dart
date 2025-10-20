import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConversorApp extends StatefulWidget {
  const ConversorApp({super.key});

  @override
  State<ConversorApp> createState() => _ConversorAppState();
}

class _ConversorAppState extends State<ConversorApp> {
  final montoController = TextEditingController();
  final monedaController = TextEditingController();
  String resultado = '';
  bool cargando = false;

  Future<void> convertirMoneda(BuildContext context) async {
    final montoTxt = montoController.text.trim();
    final moneda = monedaController.text.trim().toUpperCase();

    if (montoTxt.isEmpty || moneda.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese el monto y el código de la moneda.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    double? monto = double.tryParse(montoTxt);
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese un monto válido mayor a 0.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      final url = Uri.parse('https://open.er-api.com/v6/latest/USD');
      final respuesta = await http.get(url);

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        final tasas = datos['rates'] as Map<String, dynamic>;

        if (tasas.containsKey(moneda)) {
          double tasa = tasas[moneda];
          double convertido = monto * tasa;

          setState(() {
            resultado =
                '\$${monto.toStringAsFixed(2)} USD = ${convertido.toStringAsFixed(2)} $moneda';
          });
        } else {
          setState(() {
            resultado = 'Moneda no encontrada: $moneda';
          });
        }
      } else {
        setState(() {
          resultado = 'Error al obtener las tasas de cambio.';
        });
      }
    } catch (e) {
      setState(() {
        resultado = 'Error de conexión o datos.';
      });
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Conversor de Monedas'),
            backgroundColor: const Color.fromARGB(255, 78, 115, 228),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Conversión desde Dólar (USD)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 32, 218, 22),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: montoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monto en dólares (USD)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: monedaController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText:
                        'Código de moneda destino ( EUR, MXN, JPY)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => convertirMoneda(context),
                  icon: const Icon(Icons.currency_exchange),
                  label: const Text('Convertir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 172, 176, 46),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(height: 30),
                cargando
                    ? const CircularProgressIndicator()
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.indigo.shade100),
                        ),
                        child: Text(
                          resultado.isEmpty
                              ? 'Ingrese datos y presione "Convertir".'
                              : resultado,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
