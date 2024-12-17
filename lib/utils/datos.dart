import 'dart:io';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Datos {
  static final Datos _instancia = Datos._internal();

  Datos._internal();

// Factory constructor para devolver la misma instancia
  factory Datos() {
    return _instancia;
  }

  String qr = "";

  String getFecha() {
    DateTime fecha = DateTime.now();
    String fechaFormateada = DateFormat('yyyy-MM-dd HH:mm:ss').format(fecha);

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
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Obtén el directorio donde guardar el archivo
      final directory = await getApplicationDocumentsDirectory();
      // final path = '${directory.path}/qr_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final path = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
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
      final fileName = name + "_${DateTime.now().millisecondsSinceEpoch}.png";
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
          .where((file) =>
              file is File &&
              file.path.endsWith(
                  '.png')) // Cambia a '.jpg' o cualquier extensión que uses
          .map((file) => File(file.path))
          .toList();

      return images;
    } catch (e) {
      print('Error al obtener las imágenes: $e');
      return [];
    }
  }

  Future<String> scanQrCode(File imageFile) async {
    try {
      final result = await MobileScannerController()
          .analyzeImage(imageFile.path); // Analizar la imagen

      if (result != null && result.barcodes.isNotEmpty) {
        return result.barcodes.first.rawValue ?? "QR no válido";
      } else {
        return "No se detectó un QR.";
      }
    } catch (e) {
      debugPrint("Error al leer el QR: $e");

      return "Error al leer el QR.";
    }
  }

  Map<String, String> parseVCard(String rawData) {
    final Map<String, String> data = {};

    // Divide por líneas y extrae las partes clave
    for (final line in rawData.split('\n')) {
      final parts = line.split(':');
      if (parts.length > 1) {
        final key = parts[0]
            .split(';')[0]
            .trim(); // Ignora los modificadores como CHARSET
        final value = parts.sublist(1).join(':').trim(); // Junta el resto

        // Si es el campo ADR, procesa los componentes
        if (key == 'ADR') {
          final components = value.split(';');
          // Combina los componentes relevantes
          data[key] = [
            if (components.length > 2) components[2], // Calle
            if (components.length > 3) components[3], // Ciudad
            if (components.length > 5) components[5], // Código postal
            if (components.length > 6) components[6], // País
          ].where((element) => element.isNotEmpty).join(', ');
        } else {
          data[key] = value;
        }
      }
    }

    return data;
  }

  Map<String, String> parseWifiQR(String result) {
    // Mapa para almacenar los datos extraídos
    final Map<String, String> wifiData = {};

    // Verificar si el texto comienza con el prefijo esperado
    if (result.startsWith('WIFI:')) {
      // Eliminar el prefijo 'WIFI:' y dividir los campos por ';'
      final fields = result.substring(5).split(';');

      // Iterar sobre cada campo para separar clave y valor
      for (var field in fields) {
        if (field.contains(':')) {
          final keyValue = field.split(':');

          // Asegurarse de que el campo tiene clave y valor
          if (keyValue.length == 2) {
            wifiData[keyValue[0]] = keyValue[1];
          }
        }
      }
    }

    return wifiData;
  }

  Map<String, String> parseGeoQR(String result) {
    final Map<String, String> locationData = {};

    if (result.startsWith('geo:')) {
      try {
        // Eliminar el prefijo 'geo:'
        String data = result.substring(4);

        // Separar las coordenadas y el posible parámetro de consulta
        final parts = data.split('?');
        final coordinates = parts[0].split(',');

        if (coordinates.length == 2) {
          locationData['latitude'] = coordinates[0];
          locationData['longitude'] = coordinates[1];
        }

        // Verificar si hay un parámetro de consulta
        if (parts.length > 1 && parts[1].startsWith('q=')) {
          locationData['query'] = parts[1].substring(2).replaceAll('+', ' ');
        }
      } catch (e) {
        print("Error al parsear el código QR de localización: $e");
      }
    }

    return locationData;
  }

  // Función para procesar la cadena del QR
  Map<String, String> parseEvent(String qrData) {
    final lines = qrData.split('\n');
    final eventData = <String, String>{};

    for (var line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length > 1) {
          eventData[parts[0]] = parts.sublist(1).join(':').trim();
        }
      }
    }
    return eventData;
  }


  String formatIsoDate2(String dateTime) {
    String cleanedDate = dateTime;
    try {
      // 1. Eliminar 'T' y 'Z' de la cadena
      String cleanedDate = dateTime.replaceAll('T', ' ').replaceAll('Z', '');

      // 2. Convertir la fecha limpia en un objeto DateTime
      // Asumimos que la cadena tiene el formato 'yyyyMMdd HHmmss'
      int year = int.parse(cleanedDate.substring(0, 4));
      int month = int.parse(cleanedDate.substring(4, 6));
      int day = int.parse(cleanedDate.substring(6, 8));
      int hour = int.parse(cleanedDate.substring(9, 11));
      int minute = int.parse(cleanedDate.substring(11, 13));
      int second = int.parse(cleanedDate.substring(13, 15));

      DateTime parsedDate = DateTime(year, month, day, hour, minute, second);

      // 3. Formatear la fecha en el formato 'yyyy-MM-dd hh:mm:ss'
      // Utilizamos el formato que queremos de manera manual
      String formattedDate = '${parsedDate.year.toString().padLeft(4, '0')}-'
          '${parsedDate.month.toString().padLeft(2, '0')}-'
          '${parsedDate.day.toString().padLeft(2, '0')} '
          '${parsedDate.hour.toString().padLeft(2, '0')}:'
          '${parsedDate.minute.toString().padLeft(2, '0')}:'
          '${parsedDate.second.toString().padLeft(2, '0')}';

      return formattedDate;
    } catch (e) {
      print('Error al formatear la fecha: $e');
      return "Formato de fecha inválido";
    }
  }

  String extractEventDates(String event) {
    // 1. Usamos expresiones regulares para extraer las fechas de DTSTART y DTEND
    final regexStart = RegExp(r"DTSTART:(\d{8}T\d{6}Z)");  // Busca la fecha de inicio
    final regexEnd = RegExp(r"DTEND:(\d{8}T\d{6}Z)");  // Busca la fecha de fin

    final startMatch = regexStart.firstMatch(event);
    final endMatch = regexEnd.firstMatch(event);

    if (startMatch != null && endMatch != null) {
      // Extraemos las fechas de inicio y fin
      String startDateTime = startMatch.group(1)!;
      String endDateTime = endMatch.group(1)!;

      // Formateamos las fechas
      String startFormatted = formatIsoDate2(startDateTime);
      String endFormatted = formatIsoDate2(endDateTime);

      // Retornamos el resultado en formato adecuado
      return "Inicio: $startFormatted\nFin: $endFormatted";
    }

    return "Fechas no encontradas";
  }

  String processEvent(String event) {
    // 1. Eliminar BEGIN:VEVENT y END:VEVENT
    event = event.replaceAll(RegExp(r"^BEGIN:VEVENT\s*|\s*END:VEVENT$"), "");

    // 2. Usamos expresiones regulares para extraer y reemplazar las fechas de DTSTART y DTEND
    final regexStart = RegExp(r"DTSTART:(\d{8}T\d{6}Z)");  // Busca la fecha de inicio
    final regexEnd = RegExp(r"DTEND:(\d{8}T\d{6}Z)");  // Busca la fecha de fin
    final regexSummary = RegExp(r"SUMMARY:(.*)"); // Extrae el valor de SUMMARY
    final regexDescription = RegExp(r"DESCRIPTION:(.*)"); // Extrae el valor de DESCRIPTION

    // Reemplazar las fechas formateadas en el evento
    event = event.replaceAllMapped(regexStart, (match) {
      String dateTime = match.group(1)!;
      String formattedDate = formatIsoDate2(dateTime);
      return "DTSTART:$formattedDate";  // Reemplazamos la fecha con la formateada
    });

    event = event.replaceAllMapped(regexEnd, (match) {
      String dateTime = match.group(1)!;
      String formattedDate = formatIsoDate2(dateTime);
      return "DTEND:$formattedDate";  // Reemplazamos la fecha con la formateada
    });

    // Reemplazar el SUMMARY y DESCRIPTION para que solo muestren el valor
    event = event.replaceAllMapped(regexSummary, (match) {
      return match.group(1)!;  // Solo devolver el valor de SUMMARY sin "SUMMARY:"
    });

    event = event.replaceAllMapped(regexDescription, (match) {
      return match.group(1)!;  // Solo devolver el valor de DESCRIPTION sin "DESCRIPTION:"
    });

    return event.trim();
  }

  Future<void> launchUrll(String url) async {
    final Uri _url = Uri.parse(url);
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
  // Función para agregar el evento al calendario
  // Cargar los calendarios disponibles en el dispositivo

  Future<void> openLocationInMaps(String latitude, String longitude, BuildContext context) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print("Mapa abierto exitosamente");
    } else {
      print("No se pudo abrir el mapa");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el mapa. Por favor verifica las coordenadas.')),
      );
    }
  }


}






