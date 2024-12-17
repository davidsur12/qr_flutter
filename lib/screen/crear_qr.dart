
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        title: Text('Lector QR', style: TextStyle(color: Colors.white),),
        actions: [IconButton(onPressed: (){
          Get.changeTheme(Get.isDarkMode?ThemeData.light(): ThemeData.dark());//cambio de thema

        }, icon: Icon(Icons.abc))],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [


       Center(child: SizedBox(
           width: 200,
           child: ElevatedButton(onPressed: (){}, child: Text(Cadenas.get("sitio_web")))),),
        ElevatedButton(onPressed: (){}, child: Text(Cadenas.get("contacto"))),
        ElevatedButton(onPressed: (){}, child: Text(Cadenas.get("red_wifi"))),
        ElevatedButton(onPressed: (){}, child: Text(Cadenas.get("ubicacion"))),
        ElevatedButton(onPressed: (){}, child: Text(Cadenas.get("evento"))),


      ],),
    );
  }
}


