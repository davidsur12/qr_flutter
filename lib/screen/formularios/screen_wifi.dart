import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';


class ScreenWifi extends StatefulWidget {
  const ScreenWifi({super.key});

  @override
  State<ScreenWifi> createState() => _ScreenWifiState();
}

class _ScreenWifiState extends State<ScreenWifi> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _securityType = "WPA/WPA2"; // Valor predeterminado
  final GlobalKey _qrKey = GlobalKey();
  String? _generatedQr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar QR de WiFi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_ssidController, 'Nombre de la red (SSID)', true),
                    const SizedBox(height: 16),
                    _buildTextField(_passwordController, 'Contraseña', true),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _securityType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Seguridad',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "WPA/WPA2",
                          child: Text('WPA/WPA2'),
                        ),
                        DropdownMenuItem(
                          value: "WEP",
                          child: Text('WEP'),
                        ),
                        DropdownMenuItem(
                          value: "NONE",
                          child: Text('Sin seguridad'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _securityType = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, seleccione un tipo de seguridad.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                 SizedBox(
                     width: 250,
                     child:    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary, // Fondo del botón
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _generatedQr = _generateWifiQr();
                          });
                        }
                      },
                      child:  Text('Generar QR', style: TextStyle(color: Theme.of(context).colorScheme.surface)),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_generatedQr != null) ...[
                const Text(
                  'Código QR generado',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                RepaintBoundary(
                  key: _qrKey,
                  child: QrImageView(
                    data: _generatedQr!,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
             SizedBox(
                 width: 250,
                 child:   ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, // Fondo del botón
                  ),
                  onPressed: _shareQrCode,
                  child: Text('Compartir QR',style: TextStyle(color: Theme.of(context).colorScheme.surface)),
                )),
                SizedBox(
                    width: 250,
                    child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, // Fondo del botón
                  ),
                  onPressed: _saveQrToFile,
                  child:  Text('Guardar QR', style: TextStyle(color: Theme.of(context).colorScheme.surface)),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool isRequired) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Por favor, ingrese $label.';
        }
        return null;
      },
    );
  }

  String _generateWifiQr() {
    final String ssid = _ssidController.text;
    final String password = _passwordController.text;
    final String security = _securityType;

    return 'WIFI:T:$security;S:$ssid;P:$password;;';
  }

  Future<void> _shareQrCode() async {
    try {
      if (_generatedQr == null) return;

      final qrImage = await QrPainter(
        data: _generatedQr!,
        version: QrVersions.auto,
        gapless: false,
      ).toImage(200);
      final byteData = await qrImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/wifi_qr.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: '¡Conéctate a mi red WiFi!');
    } catch (e) {
      print('Error al compartir el QR: $e');
    }
  }

  Future<void> _saveQrToFile() async {
    try {
      final RenderRepaintBoundary boundary =
      _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final DateTime now = DateTime.now();
      final String timestamp = now.toIso8601String().replaceAll(':', '-');
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/wifi_qr_$timestamp.png');
      await file.writeAsBytes(pngBytes);

      Fluttertoast.showToast(
        msg: 'QR guardado en ${file.path}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print('Error al guardar el QR: $e');
    }
  }
}
