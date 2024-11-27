
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ScanQrImage extends StatefulWidget {
  final File image;

  const ScanQrImage({super.key, required this.image});

  @override
  State<ScanQrImage> createState() => _ScanQrImageState();
}

class _ScanQrImageState extends State<ScanQrImage> {
  File? _croppedImage;

  @override
  void initState() {
    super.initState();
    // Llamar al recorte automáticamente al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cropImage();
    });
  }

  Future<void> _cropImage() async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.image.path,

        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
     /*   aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],*/
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
          _croppedImage = File(croppedFile.path); // Guarda la imagen recortada
        });
      } else {
        // Si el usuario cancela, vuelve a la pantalla anterior
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint("Error al recortar la imagen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recortar Imagen'),
      ),
      body: Center(
        child: _croppedImage == null
            ? const CircularProgressIndicator() // Muestra un indicador mientras se recorta
            : Image.file(_croppedImage!, fit: BoxFit.contain),
      ),
    );
  }
}


/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ScanQrImage extends StatefulWidget {
  final File image;

  const ScanQrImage({super.key, required this.image});

  @override
  State<ScanQrImage> createState() => _ScanQrImageState();
}

class _ScanQrImageState extends State<ScanQrImage> {
  File? _croppedImage;

  Future<void> _cropImage() async {
    // Llama a ImageCropper para recortar la imagen
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: widget.image.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Relación de aspecto fija
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar Imagen',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false, // Permite cambiar libremente la relación de aspecto
          backgroundColor: Colors.black,
        ),
        IOSUiSettings(
          title: 'Recortar Imagen',
          aspectRatioLockEnabled: false, // Permite cambiar libremente la relación de aspecto
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _croppedImage = File(croppedFile.path); // Actualiza la imagen recortada
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recortar Imagen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _croppedImage == null
                ? Image.file(widget.image, fit: BoxFit.contain)
                : Image.file(_croppedImage!, fit: BoxFit.contain),
          ),
          if (_croppedImage == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: _cropImage,
                icon: const Icon(Icons.crop),
                label: const Text('Recortar Imagen'),
              ),
            ),
        ],
      ),
    );
  }
}


*/
