
import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui2;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr3/screen/qr.dart';
import 'package:qr3/utils/datos.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as add2cal;
import 'package:device_calendar/device_calendar.dart' as devicecal;
import 'dart:typed_data';


class QrScaneado extends StatefulWidget {
  final String qr;
  const QrScaneado({super.key, required this.qr});

  @override
  State<QrScaneado> createState() => _QrScaneadoState();
}

class _QrScaneadoState extends State<QrScaneado> {
  GlobalKey _qrKey = GlobalKey();
  TextEditingController controller = TextEditingController();
  String currentQr = ''; // Variable para almacenar el QR actual




  // Este método se llama cada vez que el código QR se escanea
  void _onQrScanned(String newQr) {
    setState(() {
      currentQr = newQr; // Actualizamos el QR escaneado
    });
  }
  /// Captura la imagen del QR y la guarda como archivo
  Future<File?> _captureQrImage() async {
    try {
      if (_qrKey.currentContext != null) {
        // Obtener el RenderRepaintBoundary
        RenderRepaintBoundary boundary =
        _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

        var image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);

        if (byteData != null) {
          final buffer = byteData.buffer;

          // Guardar la imagen en un archivo temporal
          Directory tempDir = await getTemporaryDirectory();
          String filePath = '${tempDir.path}/scanned_qr.png';
          File file = File(filePath);
          await file.writeAsBytes(
              buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
          return file;
        } else {
          print('Error: ByteData es nulo.');
        }
      } else {
        print('Error: _qrKey.currentContext es nulo.');
      }
    } catch (e) {
      print('Error al capturar la imagen del QR: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
// Redirigir a una pantalla específica cuando se presione el botón "Atrás"
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ScannerQr()),
              (route) => false,
        );
        return false; // Previene el cierre de la pantalla actual
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Segunda Pantalla")),
        body:

      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [  Expanded(
        child: SingleChildScrollView(
          child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
           Padding(
               padding: const EdgeInsets.all(16.0),
               child:  qrScaneado(widget.qr)),


                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: RepaintBoundary(
                      key: _qrKey, // Asocia la clave global al RepaintBoundary
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: PrettyQrView.data(
                          data: widget.qr,
                        ),
                      ),
                    ),
                  ),
                ),
Center(child: Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    IconButton( onPressed: () async {
File? qrFile = await _captureQrImage(); // Capturar la imagen

if (qrFile != null && await qrFile.exists()) {
// Si el archivo fue generado y existe
final xFile = XFile(qrFile.path);
print('Compartiendo archivo: ${qrFile.path}');
await Share.shareXFiles([xFile], text: 'Este es mi QR escaneado!');
} else {
// Si no se pudo generar el archivo, muestra un mensaje al usuario
print('Error: el archivo no existe o no se pudo capturar.');
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('No se pudo compartir la imagen del QR.')),
);
}
}, icon: Icon(Icons.share)),
  IconButton(onPressed: (){ _showAlertDialog(context);}, icon: Icon(Icons.save))
  ],),),





              ]),

        ))])


      ),
    );
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
                  _saveQrToFile(widget.qr ?? "0", controller.text); // Llama a la función para guardar
                  showtoast(controller.text); // Muestra un toast con el nombre ingresado
                } else {
                  showtoast("Por favor ingresa un Nombre");
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveQrToFile(String qrData, String name) async {
    try {
      // Renderizar el QrImageView en un RepaintBoundary
      RenderRepaintBoundary boundary = _qrKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;
      if (boundary != null) {
        ui2.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(
            format: ui2.ImageByteFormat.png);
        if (byteData != null) {
          Uint8List pngBytes = byteData.buffer.asUint8List();
          await Datos().saveImageToLocal2(pngBytes, name); // Guarda la imagen con el nombre
        }
      }
    } catch (e) {
      print('Error al guardar el QR: $e');
    }
  }

  Widget qrScaneado(String qr){
    //return qrTextoPlano(qr);


late Widget result;


    switch(Datos().interpretQRCode(qr)){
      case 1:

        final Map<String, String> vcardData = Datos().parseVCard(qr);


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
              onPressed: () => Datos().launchUrll(qr),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                qr,
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

        final Map<String, String> wifiData = Datos().parseWifiQR(qr);

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
        final locationInfo = Datos().parseGeoQR(qr);
        final latitude = locationInfo['latitude'] ?? 'Latitud no encontrada';
        final longitude = locationInfo['longitude'] ?? 'Longitud no encontrada';
        final query = locationInfo['query'] ?? 'Sin descripción';

        result = Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(qr),

            SizedBox(
                width:double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    alignment: Alignment.centerLeft, // Alinea el contenido hacia la izquierda
                  ),
                  onPressed: () {
                    print('URL generada: https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');

                    if (latitude != 'Latitud no encontrada' && longitude != 'Longitud no encontrada') {

                      Datos().openLocationInMaps(latitude, longitude, context);
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

        final eventData = Datos().parseEvent(qr);
        print("resultado $qr");
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
        final event = parseEvent(qr);

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
        result =  qrTextoPlano(qr);
        break;
      default:
        result =  qrTextoPlano(qr);

    }

    return result;




  }

  Widget qrTextoPlano(String qr){
    DateTime fecha = DateTime.now();
    String fechaFormateada= DateFormat('yyyy-MM-dd HH:mm:ss').format(fecha);


    return Column(children: [
      Center(child: Text(qr),),
      Center(child:  Text(fechaFormateada),),

      //motrase el codigo

    ],
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





}


