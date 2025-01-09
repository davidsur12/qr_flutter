import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ScreenEvento extends StatefulWidget {
  const ScreenEvento({super.key});

  @override
  State<ScreenEvento> createState() => _ScreenEventoState();
}

class _ScreenEventoState extends State<ScreenEvento> {


  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final GlobalKey _qrKey = GlobalKey();
  String? _generatedQr;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar QR de Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_titleController, 'Título del Evento', true),
                    const SizedBox(height: 16),
                    _buildTextField(_locationController, 'Ubicación', true),
                    const SizedBox(height: 16),
                    _buildTextField(_descriptionController, 'Descripción', false),
                    const SizedBox(height: 16),
                    _buildDateTimePicker('Fecha y hora de inicio', (date) {
                      setState(() {
                        _startDate = date;
                      });
                    }),
                    const SizedBox(height: 16),
                    _buildDateTimePicker('Fecha y hora de fin', (date) {
                      setState(() {
                        _endDate = date;
                      });
                    }),
                    const SizedBox(height: 20),
                  SizedBox(

                      width:250,
                      child:  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary, // Fondo del botón
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _generatedQr = _generateEventQr();
                          });
                        }
                      },
                      child:  Text('Generar QR', style: TextStyle(color: Theme.of(context).colorScheme.surface)),
                    )),
                  ],
                ),
              ),
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
                const SizedBox(height: 10),
             SizedBox(
                 width: 250,
                 child:   ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, // Fondo del botón
                  ),
                  onPressed: _shareQrCode,
                  child:  Text('Compartir QR', style: TextStyle(color: Theme.of(context).colorScheme.surface)),
                )),
               SizedBox(
                   width: 250,
                   child:  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, // Fondo del botón
                  ),
                  onPressed: _saveQrToFile,
                  child:  Text('Guardar QR', style: TextStyle(color: Theme.of(context).colorScheme.surface)),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool isRequired) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Por favor, ingrese $label.';
        }
        return null;
      },
    );
  }

  Widget _buildDateTimePicker(String label, Function(DateTime) onSelected) {
    return GestureDetector(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (selectedDate != null) {
          final selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (selectedTime != null) {
            final selectedDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            onSelected(selectedDateTime);
          }
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          _formatDateTime(label == 'Fecha y hora de inicio' ? _startDate : _endDate),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Seleccionar fecha y hora';
    return '${dateTime.toLocal()}'.split('.')[0];
  }

  String _generateEventQr() {
    final String title = _titleController.text;
    final String location = _locationController.text;
    final String description = _descriptionController.text;
    final String start = _startDate?.toUtc().toIso8601String() ?? '';
    final String end = _endDate?.toUtc().toIso8601String() ?? '';

    return 'BEGIN:VEVENT\n'
        'SUMMARY:$title\n'
        'LOCATION:$location\n'
        'DESCRIPTION:$description\n'
        'DTSTART:$start\n'
        'DTEND:$end\n'
        'END:VEVENT';
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
      final file = await File('${tempDir.path}/event_qr.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: '¡Únete a mi evento!');
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

      final DateTime now = DateTime.now();
      final String timestamp = now.toIso8601String().replaceAll(':', '-');
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/event_qr_$timestamp.png');
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
