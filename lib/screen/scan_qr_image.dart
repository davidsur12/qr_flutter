


import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr3/utils/datos.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanQrImage extends StatefulWidget {
  final File image;

  const ScanQrImage({super.key, required this.image});

  @override
  State<ScanQrImage> createState() => _ScanQrImageState();
}

class _ScanQrImageState extends State<ScanQrImage> {
  File? _croppedImage;
  String? _qrCode;
  String tituloAppbar = "Scaner QR";
  GlobalKey _qrKey = GlobalKey(); // Clave global para el RepaintBoundary
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cropImage();
    });
  }

  Future<void> _cropImage() async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar Imagen',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Recortar Imagen',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _croppedImage = File(croppedFile.path);
        });
        // Escanear el QR una vez recortada la imagen
        _scanQrCode(File(croppedFile.path));
      } else {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint("Error al recortar la imagen: $e");
    }
  }

  Future<void> _scanQrCode(File imageFile) async {
    try {
      final result = await MobileScannerController()
          .analyzeImage(imageFile.path); // Analizar la imagen

      if (result != null && result.barcodes.isNotEmpty) {
        setState(() {
          _qrCode = result.barcodes.first.rawValue ?? "QR no válido";
        });
      } else {
        setState(() {
          _qrCode = "No se detectó un QR.";
        });
      }
    } catch (e) {
      debugPrint("Error al leer el QR: $e");
      setState(() {
        _qrCode = "Error al leer el QR.";
      });
    }
  }

  // Función para capturar el QR como imagen y guardarlo en el almacenamiento local
  Future<void> _saveQrToFile(String qrData, String name) async {
    try {
      // Renderizar el QrImageView en un RepaintBoundary
      RenderRepaintBoundary boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      if (boundary != null) {
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          Uint8List pngBytes = byteData.buffer.asUint8List();
          await Datos().saveImageToLocal2(pngBytes, name);
        }
      }
    } catch (e) {
      print('Error al guardar el QR: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tituloAppbar),
      ),
      body: _croppedImage == null
          ? const Center(
        child: CircularProgressIndicator(),
      ) // Mientras carga muestra un loader
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_qrCode != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: resultado(
                  Datos().interpretQRCode(_qrCode ?? "0"), _qrCode ?? "0"),
            ),
          const Spacer(), // Empuja los elementos anteriores hacia arriba
          Center(
            child: RepaintBoundary(
              key: _qrKey,
              child: QrImageView(
                data: _qrCode ?? "0", // Usamos el código QR escaneado
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white, // Fondo blanco para el QR
              ),
            ),
          ),
          const SizedBox(height: 20), // Espaciado entre la imagen y el botón
          Center(
            child: ElevatedButton(
              onPressed: () {
                _showAlertDialog(context);
                //  _saveQrToFile(_qrCode ?? "0");
              },
              child: Text("Guardar QR como Imagen"),
            ),
          ),
          const Spacer(), // Empuja los elementos hacia abajo si es necesario
        ],
      ),
    );
  }

  Widget resultado(int typo, String resultt) {
    Widget result = Text("data");
    switch (typo) {
      case 2:
        result = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () => _launchUrl(resultt),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                resultt,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 18),
              ),
            ),
            const Text("QR Code"),
            const SizedBox(height: 8),
            Text(Datos().getFecha()),
            const SizedBox(height: 18),
          ],
        );
        break;
    }
    return result;
  }

  Future<void> _launchUrl(String url) async {
    final Uri _url = Uri.parse(url);
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  void _showAlertDialog(BuildContext context) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingrese un texto'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Escribe algo'),
          ),
          actions: [
            TextButton(
              onPressed: () {

                // Acción cuando se presiona el botón OK
                String inputText = controller.text;
                print('Texto ingresado: $inputText');
                Navigator.of(context).pop(); // Cierra el diálogo
                _saveQrToFile(_qrCode ?? "0", controller.text ?? "qr");
                showtoast(controller.text);

              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showtoast(String msg){
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT, // Duración: SHORT o LONG
      gravity: ToastGravity.BOTTOM, // Posición: TOP, CENTER, BOTTOM
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

