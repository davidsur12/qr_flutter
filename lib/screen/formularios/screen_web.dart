
import 'dart:io';
import 'dart:typed_data';

//import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr3/utils/cadenas.dart';

import 'package:qr3/utils/datos.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';







class ScreenWeb extends StatefulWidget {
  const ScreenWeb({super.key});

  @override
  State<ScreenWeb> createState() => _ScreenWebState();
}

class _ScreenWebState extends State<ScreenWeb> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _urlController = TextEditingController();
  GlobalKey _qrKey = GlobalKey(); // Clave global para el RepaintBoundary
  String? _generatedQr;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generar Código QR'),
      ),
      body: Expanded(child: SingleChildScrollView(child:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: 'Sitio web',
                      hintText: 'https://www.ejemplo.com',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese una URL.';
                      }
                      if (!Uri.tryParse(value)!.isAbsolute ?? false  ) {
                        return 'Por favor, ingrese una URL válida.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
              SizedBox( width: 250,
                  child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _generatedQr = _urlController.text;
                        });
                      }
                    },
                    child: Text('Generar QR', style: TextStyle(color: Theme.of(context).colorScheme.surface),),
                  )),
                ],
              ),
            ),
            SizedBox(height: 20),
            if (_generatedQr != null) ...[
            Center(child:  Text(
                'Código QR generado',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )),
              SizedBox(height: 10),

              Center(
                child:
                RepaintBoundary(
                  key: _qrKey,
                  child: QrImageView(
                    data: _generatedQr ?? "0", // Usamos el código QR escaneado
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors
                        .white, // Fondo blanco para el QR
                  ),
                )

              ),

            SizedBox(height: 20,),

           Center(child:SizedBox(
               width: 250,
               child:   ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary ),
                onPressed: () async {
                  await _shareQrCode();
                },
                child: Text('Compartir QR', style: TextStyle(color: Theme.of(context).colorScheme.surface),),
              ))),
             Center(child:SizedBox(
                 width: 250,
                 child:  ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary ),
                  onPressed: (){
                _showAlertDialog(context);
              }, child: Text("Guardar", style: TextStyle(color: Theme.of(context).colorScheme.surface)))))
            ],
          ],
        ),
      ))),
    );
  }

  Future<void> _shareQrCode() async {
    try {
      if (_generatedQr == null) return;

      // Genera la imagen del QR en un archivo temporal
      final qrImage = await QrPainter(
        data: _generatedQr!,
        version: QrVersions.auto,
        gapless: false,
      ).toImage(200); // Tamaño de la imagen
      final byteData = await qrImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List() as Uint8List;

      // Guarda la imagen en un archivo temporal
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_code.png').create();
      await file.writeAsBytes(pngBytes as List<int>);

      // Usa share_plus para compartir el archivo
      await Share.shareXFiles([XFile(file.path)], text: '¡Mira mi código QR!');
    } catch (e) {
      print('Error al compartir el QR: $e');
    }
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingrese el Nombre'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Nombre'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  // Acción cuando se presiona el botón OK
                  String inputText = controller.text;
                  print('Texto ingresado: $inputText');
                  Navigator.of(context).pop(); // Cierra el diálogo
                  _saveQrToFile(controller.text ?? "0", controller.text ?? "qr");
                  showtoast(controller.text);
                }
                if (controller.text.isEmpty) {
                  showtoast("Porfavor ingresa un Nombre");
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Función para capturar el QR como imagen y guardarlo en el almacenamiento local
  Future<void> _saveQrToFile(String qrData, String name) async {
    try {
      // Renderizar el QrImageView en un RepaintBoundary
      RenderRepaintBoundary boundary = _qrKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;
      if (boundary != null) {
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(
            format: ui.ImageByteFormat.png);
        if (byteData != null) {
          Uint8List pngBytes = byteData.buffer.asUint8List();
          await Datos().saveImageToLocal2(pngBytes, name);
        }
      }
    } catch (e) {
      print('Error al guardar el QR: $e');
    }
  }


  void showtoast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      // Duración: SHORT o LONG
      gravity: ToastGravity.BOTTOM,
      // Posición: TOP, CENTER, BOTTOM
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
