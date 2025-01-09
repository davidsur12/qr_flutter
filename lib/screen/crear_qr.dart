import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr3/screen/formularios/screeen_texto.dart';
import 'package:qr3/screen/formularios/screen_contacto.dart';
import 'package:qr3/screen/formularios/screen_evento.dart';
import 'package:qr3/screen/formularios/screen_ubicacion.dart';
import 'package:qr3/screen/formularios/screen_web.dart';
import 'package:qr3/screen/formularios/screen_wifi.dart';
import 'package:qr3/utils/cadenas.dart';

class CrearQr extends StatefulWidget {
  const CrearQr({super.key});

  @override
  State<CrearQr> createState() => _CrearQrState();
}

class _CrearQrState extends State<CrearQr> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
    Cadenas.get("app_name"),
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        actions: [

        ],
      ),
      body:
      Expanded(child: SingleChildScrollView(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
Image.asset("assets/images/qr.png",width: 150,),
          SizedBox(height: 20,),
          Center(
            child: SizedBox(
                width: 400,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.web),
                  onPressed: () {
                    navigatorFormulario(ScreenWeb());
                  },

                  label: Text(Cadenas.get("sitio_web"), style: TextStyle(color: Theme.of(context).colorScheme.surface),), // Texto
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, // Fondo del botón
                  ),
                )),
          ),
          btn("contacto", ScreeenContacto()),
          btn("red_wifi", ScreenWifi()),
          btn("texto", ScreenTexto()),
          btn("evento", ScreenEvento()),
          btn("ubicacion", ScreenUbicacion()),


        ],
      ))),
    );
  }

  void navigatorFormulario(Widget pantalla) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => pantalla),
    );
  }

  Widget btn(String nombre, Widget pantalla ){

    return   Center(
      child: SizedBox(
          width: 400,
          child: ElevatedButton.icon(
            icon: Icon(Icons.web),
            onPressed: () {
              navigatorFormulario(pantalla);
            },

            label: Text(Cadenas.get(nombre), style: TextStyle(color: Theme.of(context).colorScheme.surface),), // Texto
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary, // Fondo del botón
            ),
          )),
    );
  }
}
