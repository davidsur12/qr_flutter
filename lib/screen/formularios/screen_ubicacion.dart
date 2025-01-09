
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Asegúrate de tener esta importación
import 'package:share_plus/share_plus.dart';


class ScreenUbicacion extends StatefulWidget {
  const ScreenUbicacion({super.key});

  @override
  State<ScreenUbicacion> createState() => _ScreenUbicacionState();
}

class _ScreenUbicacionState extends State<ScreenUbicacion> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _qrKey = GlobalKey();
  String? _generatedQr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar QR de Ubicación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
           Center(child:SizedBox(
               width: 250,
               child:    ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary, // Fondo del botón
                ),
                onPressed: _getLocationAndGenerateQR,
                child: Text('Generar QR de Ubicación',  style: TextStyle(color: Theme.of(context).colorScheme.surface)),
              ))),
              const SizedBox(height: 20),
              if (_generatedQr != null) ...[
                const Text(
                  'Código QR generado',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                RepaintBoundary(
                  key: _qrKey,
                  child: QrImageView(
                    data: _generatedQr!,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),
               SizedBox(height: 20,),
               SizedBox(
                   width: 250,
                   child:ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, // Fondo del botón
                  ),
                  onPressed: _shareQrCode,
                  child:  Text('Compartir QR',  style: TextStyle(color: Theme.of(context).colorScheme.surface)),
                )),
            Center(child:  SizedBox(
                 width: 250,
                 child:    ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, // Fondo del botón
                  ),
                  onPressed: _saveQrToFile,
                  child:  Text('Guardar QR',  style: TextStyle(color: Theme.of(context).colorScheme.surface)),
                ))),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Método para obtener la ubicación y generar el QR
  Future<void> _getLocationAndGenerateQR() async {
    try {
      Position position = await _getCurrentLocation();
      String locationUrl = 'https://www.google.com/maps?q=${position.latitude},${position.longitude}';
      setState(() {
        _generatedQr = locationUrl;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error al obtener la ubicación: $e');
    }
  }

  // Obtener la ubicación actual
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Los servicios de ubicación están deshabilitados');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permisos de ubicación denegados');
      }
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // Método para compartir el código QR generado
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
      final file = await File('${tempDir.path}/location_qr.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: '¡Mira este código QR de ubicación!');
    } catch (e) {
      print('Error al compartir el QR: $e');
    }
  }

  // Método para guardar el código QR en el dispositivo
  Future<void> _saveQrToFile() async {
    try {
      final RenderRepaintBoundary boundary =
      _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final DateTime now = DateTime.now();
      final String timestamp = now.toIso8601String().replaceAll(':', '-');
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/location_qr_$timestamp.png');
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
