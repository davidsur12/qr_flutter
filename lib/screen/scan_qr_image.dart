import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr3/utils/datos.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as add2cal;


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
            :
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_qrCode != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: resultado(
                          Datos().interpretQRCode(_qrCode ?? "0"),
                          _qrCode ?? "0",
                        ),
                      ),
                    Center(
                      child: RepaintBoundary(
                        key: _qrKey,
                        child: QrImageView(
                          data: _qrCode ?? "0", // Usamos el código QR escaneado
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors
                              .white, // Fondo blanco para el QR
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Espaciado entre la imagen y el botón
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              _showAlertDialog(context);
                            },
                            icon: Icon(Icons.save),
                          ),
                          IconButton(
                            onPressed: () async {
                              try {
                                // Verificar que el archivo existe antes de compartir
                                final filePath = widget.image.path;
                                if (filePath == null || filePath.isEmpty) {
                                  print(
                                      'Error: No se proporcionó una ruta válida para el archivo.');
                                  return;
                                }

                                // Crear el objeto XFile y compartirlo
                                final xFile = XFile(filePath);
                                await Share.shareXFiles(
                                  [xFile],
                                  text: 'Compartiendo',
                                );

                                print('Imagen compartida exitosamente.');
                              } catch (e) {
                                print(
                                    'Error al intentar compartir la imagen: $e');
                              }
                            },
                            icon: Icon(Icons.share),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )

/*
    Column(children:[Expanded(child:  SingleChildScrollView(child: Column(
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
          Center(child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [IconButton(onPressed: (){  _showAlertDialog(context);}, icon: Icon(Icons.save)),
          IconButton(  onPressed: () async {
            try {
              // Verificar que el archivo existe antes de compartir
              final filePath = widget.image.path;
              if (filePath == null || filePath.isEmpty) {
                print('Error: No se proporcionó una ruta válida para el archivo.');
                return;
              }

              // Crear el objeto XFile y compartirlo
              final xFile = XFile(filePath);
              await Share.shareXFiles(
                  [xFile],
                  text: '¡Mira esta imagen que compartí desde mi app!'
              );

              print('Imagen compartida exitosamente.');
            } catch (e) {
              print('Error al intentar compartir la imagen: $e');
            }
          }, icon: Icon(Icons.share))],),),



          const Spacer(), // Empuja los elementos hacia abajo si es necesario
        ],
      )))]),

      */
    );
  }

  Widget resultado(int typo, String resultt) {
    Widget result = Text("data");
    switch (typo) {
    case 1:

    final Map<String, String> vcardData = Datos().parseVCard(resultt);


    result = Padding(
    padding: const EdgeInsets.all(16.0),
    child: SingleChildScrollView(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text('Nombre: ${vcardData['FN'] ?? ''}', style: TextStyle(fontSize: 18)),
    Text('Organización: ${vcardData['ORG'] ?? ''}', style: TextStyle(fontSize: 18)),
    Text('Título: ${vcardData['TITLE'] ?? ''}', style: TextStyle(fontSize: 18)),
    Text('Teléfono: ${vcardData['TEL'] ?? ''}', style: TextStyle(fontSize: 18)),
    GestureDetector(
    onTap: () {
    final email = vcardData['EMAIL'] ?? '';
    if (email.isNotEmpty) {
    launchUrl(Uri.parse('mailto:$email'));

    }
    },
    child: Text(
    'Correo: ${vcardData['EMAIL'] ?? ''}',
    style: TextStyle(fontSize: 18, color: Colors.blue),
    ),
    ),
    GestureDetector(
    onTap: () {
    final url = vcardData['URL'] ?? '';
    if (url.isNotEmpty) {
    //  launchUrl(Uri.parse(url));
    final url = vcardData['URL']!;
    if (Uri.parse(url).isAbsolute) {
    launchUrl(Uri.parse(url));
    } else {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('URL no válida: $url')),
    );
    }
    }
    },
    child: Text(
    'Página web: ${vcardData['URL'] ?? ''}',
    style: TextStyle(fontSize: 18, color: Colors.blue),
    ),
    ),
    Text('Dirección: ${vcardData['ADR'] ?? ''}', style: TextStyle(fontSize: 18)),

    if (vcardData['EMAIL'] != null && vcardData['EMAIL']!.isNotEmpty)


        ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50), // Ancho completo y altura personalizada
            ),
            onPressed: (){ onPressed:
    final email = vcardData['EMAIL']!;
    launchUrl(Uri.parse('mailto:$email'));

    },child:Text('Enviar correo')),
    SizedBox(height: 20,),


    if (vcardData['URL'] != null && vcardData['URL']!.isNotEmpty)
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50), // Ancho completo y altura personalizada
      ),
    onPressed: () {
    final url = vcardData['URL']!;
    if (Uri.parse(url).isAbsolute) {
    launchUrl(Uri.parse(url));
    } else {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('URL no válida: $url')),
    );
    }
    },
    child: Text('Visitar página web'),
    ),
      SizedBox(height: 20,),
    ],
    ),
    ),
    );

    break;
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
      case 3:
        final Map<String, String> wifiData = Datos().parseWifiQR(resultt);

        // Obtener los valores
        final ssid = wifiData['S'] ?? 'SSID no encontrado';
        final security = wifiData['T'] ?? 'Tipo de seguridad no encontrado';
        final password = wifiData['P'] ?? 'Contraseña no encontrada';
    result = Padding(
    padding: const EdgeInsets.all(16.0),
    child: SingleChildScrollView(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children:[

      Text("Nombre: $ssid", style: TextStyle(fontSize: 18),),
      Text("Seguridad: $security", style: TextStyle(fontSize: 18)),
      Text("Contraseña: $password", style: TextStyle(fontSize: 18)),
      ElevatedButton(onPressed: (){},child: Text("Conectar wifi"),)

    ])));


        break;

      case 4:
        final locationInfo = Datos().parseGeoQR(resultt);
        final latitude = locationInfo['latitude'] ?? 'Latitud no encontrada';
        final longitude = locationInfo['longitude'] ?? 'Longitud no encontrada';
        final query = locationInfo['query'] ?? 'Sin descripción';

        result = Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(resultt),

           SizedBox(
               width:double.infinity,
               child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   alignment: Alignment.centerLeft, // Alinea el contenido hacia la izquierda
                 ),
              onPressed: () {
                print('URL generada: https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

                if (latitude != 'Latitud no encontrada' && longitude != 'Longitud no encontrada') {
                  openLocationInMaps(latitude, longitude);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Coordenadas no válidas para abrir en el mapa')),
                  );
                }
              },
              child: Text("Abrir localización", textAlign: TextAlign.start, ),
            )),
          ],
        );

        break;
      case 5:

        final eventData = Datos().parseEvent(resultt);
print("resultado $resultt");
       // result= Column(children: [ Text(Datos().processEvent(resultt))], );
        add2cal.Event parseEvent(String data) {
          final lines = data.split('\n').map((line) => line.trim()).toList();

          // Valores predeterminados en caso de no encontrarlos.
          String title = 'Sin título';
          String description = 'Sin descripción';
          String location = 'Sin ubicación';
          DateTime startDate = DateTime.now();
          DateTime endDate = startDate.add(Duration(hours: 1));

          for (final line in lines) {
            if (line.startsWith('SUMMARY:')) {
              title = line.replaceFirst('SUMMARY:', '').trim();
            } else if (line.startsWith('DESCRIPTION:')) {
              description = line.replaceFirst('DESCRIPTION:', '').trim();
            } else if (line.startsWith('DTSTART:')) {
              startDate = DateTime.parse(line.replaceFirst('DTSTART:', '').trim());
            } else if (line.startsWith('DTEND:')) {
              endDate = DateTime.parse(line.replaceFirst('DTEND:', '').trim());
            }
          }

          // Crear el objeto `Event` de `add_2_calendar`.
          return add2cal.Event(
            title: title,
            description: description,
            location: location,
            startDate: startDate,
            endDate: endDate,
          );
        }

        // Procesar la cadena del evento.
        final event = parseEvent(resultt);

        result= Column(
          children: [
            //Text(Datos().processEvent(resultt)),
            Text('Evento: ${event.title}\nDescripción: ${event.description}\nInicio: ${event.startDate}\nFin: ${event.endDate}'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                add2cal.Add2Calendar.addEvent2Cal(event);
              },
              child: Text('Agregar al Calendario'),
            ),
          ],
        );

        break;
      case 6:
        result= Text(resultt);
        break;

    }
print("resultado: $resultt");
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
                  _saveQrToFile(_qrCode ?? "0", controller.text ?? "qr");
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

  Future<void> openLocationInMaps(String latitude, String longitude) async {
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

