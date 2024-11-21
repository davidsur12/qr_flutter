import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:qr3/utils/cadenas.dart';

import 'package:qr_mobile_vision/qr_camera.dart';




class ScannerQr extends StatefulWidget {
  const ScannerQr({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<ScannerQr> {
  String? qr;
  bool camState = false;
  bool dirState = false;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

  double  ancho = MediaQuery.of(context).size.width; //ancho
  double alto = MediaQuery.of(context).size.height; //alto
    return Scaffold(
      appBar: AppBar(
        title:Text(Cadenas.get("app_name")),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.light), onPressed: _swapBackLightState),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Back"),
                Switch(value: dirState, onChanged: (val) => setState(() => dirState = val)),
                const Text("Front"),
              ],
            ),
            Expanded(
                child: camState
                    ? Center(
                  child: SizedBox(
                    width: ancho,
                    height: alto,
                    //la camar tiene varios parametros
                    child: QrCamera(
                      onError: (context, error) => Text(
                        error.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                      cameraDirection: dirState ? CameraDirection.FRONT : CameraDirection.BACK,
                      qrCodeCallback: (code) {
                        setState(() {
                          qr = code;
                        });
                      },
                      child:Center(child:  Container(child: Text("qr", style: TextStyle(color: Colors.red, fontSize: 50), ),)),
                    ),
                  ),
                )
                    : const Center(child: Text("Camera inactive"))),
            Text("QRCODE: $qr"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Text(
            "on/off",
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            setState(() {
              camState = !camState;
            });
          }),
    );
  }



  _swapBackLightState() async {
    QrCamera.toggleFlash();
  }
}