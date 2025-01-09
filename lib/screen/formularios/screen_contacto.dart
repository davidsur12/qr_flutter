import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';


class ScreeenContacto extends StatefulWidget {
  const ScreeenContacto({super.key});

  @override
  State<ScreeenContacto> createState() => _ScreeenContactoState();
}

class _ScreeenContactoState extends State<ScreeenContacto> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  String? _generatedQr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generar QR de Contacto'),
      ),
      body:
      Expanded(child: SingleChildScrollView(child:Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_firstNameController, 'Primer Nombre', true),
                    SizedBox(height: 16),
                    _buildTextField(_lastNameController, 'Segundo Nombre', false),
                    SizedBox(height: 16),
                    _buildTextField(_companyController, 'Compañía', false),
                    SizedBox(height: 16),
                    _buildTextField(_jobController, 'Trabajo', false),
                    SizedBox(height: 16),
                    _buildTextField(_phoneController, 'Teléfono', true, TextInputType.phone),
                    SizedBox(height: 16),
                    _buildTextField(_emailController, 'Correo Electrónico', true, TextInputType.emailAddress),
                    SizedBox(height: 16),
                    _buildTextField(_websiteController, 'Página Web', false),
                    SizedBox(height: 16),
                    _buildTextField(_addressController, 'Dirección', false),
                    SizedBox(height: 16),
                    _buildTextField(_cityController, 'Ciudad', false),
                    SizedBox(height: 16),
                    _buildTextField(_regionController, 'Región', false),
                    SizedBox(height: 20),
                   SizedBox(
                       width: 250,
                       child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary, // Fondo del botón
                        ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _generatedQr = _generateVCard();
                          });
                        }
                      },
                      child: Text('Generar QR',  style: TextStyle(color: Theme.of(context).colorScheme.surface)),
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
                SizedBox(height: 20),
                Center(
                  child: RepaintBoundary(
                    key: _qrKey,
                    child: QrImageView(
                      data: _generatedQr!,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
             Center(child:    SizedBox(
                    width: 250,
                    child:ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, // Fondo del botón
                  ),
                  onPressed: () async {
                    await _shareQrCode();
                  },
                  child: Text('Compartir QR',  style: TextStyle(color: Theme.of(context).colorScheme.surface)),
                ))),
            Center( child:   SizedBox(
                   width: 250,
                   child:  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, // Fondo del botón
                  ),
                  onPressed: () {
                _saveQrToFile();

                  },
                  child: Text('Guardar QR',  style: TextStyle(color: Theme.of(context).colorScheme.surface)),
                ))),
              ],
            ],
          ),
        ),
      ))),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool isRequired,
      [TextInputType inputType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: inputType,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Por favor, ingrese $label.';
        }
        return null;
      },
    );
  }

  String _generateVCard() {
    return '''
BEGIN:VCARD
VERSION:3.0
FN:${_firstNameController.text} ${_lastNameController.text}
ORG:${_companyController.text}
TITLE:${_jobController.text}
TEL:${_phoneController.text}
EMAIL:${_emailController.text}
URL:${_websiteController.text}
ADR:${_addressController.text}, ${_cityController.text}, ${_regionController.text}
END:VCARD
''';
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
      final file = await File('${tempDir.path}/qr_code.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: '¡Mira mi código QR de contacto!');
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

      // Generar un nombre de archivo único utilizando la fecha y hora actual
      final DateTime now = DateTime.now();
      final String timestamp = now.toIso8601String().replaceAll(':', '-');
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/qr_contact_$timestamp.png');
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
