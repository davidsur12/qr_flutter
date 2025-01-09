import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr3/utils/cadenas.dart';

class ScreenSettings extends StatefulWidget {
  const ScreenSettings({super.key});

  @override
  State<ScreenSettings> createState() => _ScreenPruebaState();
}

class _ScreenPruebaState extends State<ScreenSettings> {
  // Mapa para almacenar el estado de los checkboxes
  final Map<String, bool> _checkboxStates = {
    'Claro': false,
    'Oscuro': false,

  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Cadenas.get("app_name"),
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccióna un tema',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: _checkboxStates.keys.map((String key) {
                  return CheckboxListTile(
                    title: Text(key),
                    value: _checkboxStates[key],
                    onChanged: (bool? value) {
                      if (value == true) {
                        _selectOnly(key);
                        _handleCheckboxAction(key);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para deseleccionar todos y seleccionar solo uno
  void _selectOnly(String selectedKey) {
    setState(() {
      _checkboxStates.forEach((key, _) {
        _checkboxStates[key] = key == selectedKey;
      });
    });
  }

  // Método que maneja las acciones individuales para cada checkbox
  void _handleCheckboxAction(String key) {
    // Lógica personalizada para cada checkbox
    if (key == 'Claro') {
      Get.changeTheme( ThemeData.light()); //cambio de thema


    } else if (key == 'Oscuro') {
      Get.changeTheme(ThemeData.dark()); //cambio de thema

    }
  }
}
