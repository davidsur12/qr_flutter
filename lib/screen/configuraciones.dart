import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScreenSettings extends StatefulWidget {
  const ScreenSettings({super.key});

  @override
  State<ScreenSettings> createState() => _ScreenPruebaState();
}

class _ScreenPruebaState extends State<ScreenSettings> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Lector QR', style: TextStyle(color: Colors.white),),
        actions: [IconButton(onPressed: (){
          Get.changeTheme(Get.isDarkMode?ThemeData.light(): ThemeData.dark());//cambio de thema

        }, icon: Icon(Icons.abc))],
      ),

      body:

      Center(child: ElevatedButton(onPressed: (){}, child: Text("Cambiar de thema")),),
    );
  }
}