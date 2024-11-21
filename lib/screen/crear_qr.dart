
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        title: Text('Lector QR', style: TextStyle(color: Colors.white),),
        actions: [IconButton(onPressed: (){
          Get.changeTheme(Get.isDarkMode?ThemeData.light(): ThemeData.dark());//cambio de thema

        }, icon: Icon(Icons.abc))],
      ),
      body: Center(child: Text("Crear Imagen"),),
    );
  }
}


/*
class CrearQr extends StatelessWidget {
  const CrearQr({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lector QR', style: TextStyle(color: Colors.white),),
        actions: [IconButton(onPressed: (){
          Get.changeTheme(Get.isDarkMode?ThemeData.light(): ThemeData.dark());//cambio de thema

        }, icon: Icon(Icons.abc))],
      ),
      body: Center(child: Text("Crear Imagen"),),
    );
  }
}

*/