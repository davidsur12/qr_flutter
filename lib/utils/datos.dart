

import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';


import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';




class Datos  {

static final Datos _instancia = Datos._internal();

Datos._internal();

// Factory constructor para devolver la misma instancia
  factory Datos() {
    return _instancia;
  }
  String qr = "";

String getFecha(){

  DateTime fecha = DateTime.now();
  String fechaFormateada= DateFormat('yyyy-MM-dd HH:mm:ss').format(fecha);

  return fechaFormateada;

}
int interpretQRCode(String data) {
    if (data.startsWith("BEGIN:VCARD")) {
      //"Es un contacto (vCard)";
      return 1;
    } else if (data.startsWith("http://") || data.startsWith("https://")) {
      //"Es una página web";

      return 2;
    } else if (data.startsWith("WIFI:")) {
      //"Es información de Wi-Fi";
      return 3;
    } else if (data.startsWith("geo:")) {
      //"Es una ubicación";
      return 4;
    } else if (data.contains("BEGIN:VEVENT")) {
      //"Es un evento del calendario";
      return 5;
    } else {
      //"Contenido desconocido o texto simple";
      return 6;
    }
  }
  Future<void> saveImageToLocal(File imageFile) async {
    try {
      // Obtén el directorio donde guardar los archivos (ej., documentos o caché)
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;

      // Crea un nuevo archivo en ese directorio
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('$path/$fileName');

      // Copia la imagen al nuevo archivo
      await imageFile.copy(file.path);

      print('Imagen guardada en: ${file.path}');
    } catch (e) {
      print('Error al guardar la imagen: $e');
    }
  }



  Future<void> saveQrToFile(String data) async {
    GlobalKey _qrKey = GlobalKey();
    String? _filePath;


    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;

    // Crea un nuevo archivo en ese directorio
    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('$path/$fileName');

    try {
      // Renderiza el widget como una imagen
      RenderRepaintBoundary boundary =
      _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Obtén el directorio donde guardar el archivo
      final directory = await getApplicationDocumentsDirectory();
     // final path = '${directory.path}/qr_image_${DateTime.now().millisecondsSinceEpoch}.png';
     final path ='image_${DateTime.now().millisecondsSinceEpoch}.png';
      // Guarda los bytes como un archivo en el almacenamiento local
      File file = File(path);
      await file.writeAsBytes(pngBytes);



      debugPrint('QR guardado en: $path');
    } catch (e) {
      debugPrint('Error al guardar el QR: $e');
    }
  }

  // Función para guardar la imagen en el almacenamiento local
  Future<void> saveImageToLocal2(Uint8List imageBytes, String name) async {
    try {
      // Obtén el directorio donde guardar los archivos (ej., documentos o caché)
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;

      // Crea un nuevo archivo en ese directorio
      final fileName = name+"_${DateTime.now().millisecondsSinceEpoch}.png";
      final file = File('$path/$fileName');

      // Guarda la imagen como un archivo PNG
      await file.writeAsBytes(imageBytes);

      print('Imagen guardada en: ${file.path}');
    } catch (e) {
      print('Error al guardar la imagen: $e');
    }
  }
  Future<List<File>> getSavedImages() async {
    try {
      // Obtén el directorio donde guardaste las imágenes
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;

      // Lista los archivos del directorio
      final dir = Directory(path);
      final List<FileSystemEntity> files = dir.listSync();

      // Filtra solo los archivos de imagen
      final List<File> images = files
          .where((file) => file is File && file.path.endsWith('.png')) // Cambia a '.jpg' o cualquier extensión que uses
          .map((file) => File(file.path))
          .toList();

      return images;
    } catch (e) {
      print('Error al obtener las imágenes: $e');
      return [];
    }
  }



}