import 'package:flutter/material.dart';
import 'package:qr3/utils/datos.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QrViewRecuperado extends StatefulWidget {
  final   imageFile;
  const QrViewRecuperado({super.key, this.imageFile});

  @override
  State<QrViewRecuperado> createState() => _QrViewRecuperadoState();
}

class _QrViewRecuperadoState extends State<QrViewRecuperado> {
  String tituloAppbar = "Scaner QR";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tituloAppbar),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinea todo el contenido de la columna a la izquierda
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0), // Margen alrededor del texto
            child: FutureBuilder(
              future: Datos().scanQrCode(widget.imageFile),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Ocurrió un error", textAlign: TextAlign.left);
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("No se pudo leer el código QR", textAlign: TextAlign.left);
                }

                final qr = snapshot.data!;
                return Text(qr ?? "qr", textAlign: TextAlign.left);
              },
            ),
          ),

            Center(
              child: Image.file(
                widget.imageFile,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),


           Center( child:ElevatedButton.icon(
              onPressed: () async {
                try {
                  // Verificar que el archivo existe antes de compartir
                  final filePath = widget.imageFile.path;
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
              }

              /*
              onPressed: () async {

              //  Share.share('check out my website https://example.com', subject: 'Look what I made!');
                final result = await Share.shareXFiles([XFile('${widget.imageFile.path}/image.jpg')], text: 'Great picture');

                if (result.status == ShareResultStatus.success) {
                  print('Thank you for sharing the picture!');
                }

                if (result.status == ShareResultStatus.dismissed) {
                  print('Did you not like the pictures?');
                }
                /*
                Share.shareXFiles(
                  [widget.imageFile.path], // Ruta del archivo a compartir
                  text: '¡Mira esta imagen que compartí desde mi app!',
                );

                */
              }

              */,
              icon: Icon(Icons.share),
              label: Text('Compartir Imagen'),
            )),

        ],
      ),
    );
  }


}
