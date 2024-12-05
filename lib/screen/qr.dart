import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr3/screen/qr_save.dart';
import 'package:qr3/screen/qr_scaneado.dart';
import 'package:qr3/screen/scan_qr_image.dart';
import 'package:qr3/utils/cadenas.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_mobile_vision/qr_camera.dart';




class ScannerQr extends StatefulWidget {
  const ScannerQr({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<ScannerQr> {
  String? qr;
  bool camState = true;
  bool dirState = false;

  @override
  initState() {
    super.initState();
    camState = true;
    showtoast("inistate");

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        print("AppLifecycleState: Inactiva");
        break;
      case AppLifecycleState.paused:
        print("AppLifecycleState: Pausada");
        break;
      case AppLifecycleState.resumed:
        print("AppLifecycleState: Resumida");
        break;
      case AppLifecycleState.detached:
        print("AppLifecycleState: Desconectada");
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
    }
  }



  @override
  Widget build(BuildContext context) {

   // camState = true;

  double  ancho = MediaQuery.of(context).size.width; //ancho
  double alto = MediaQuery.of(context).size.height; //alto

    return Scaffold(
      appBar: AppBar(
        title:Text(Cadenas.get("app_name")),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.light), onPressed:(){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QrSave()),
            );
          }),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

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
                        camState = false;

                        setState(() {
                          qr = code;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QrScaneado(qr: this.qr ?? "sin qr" ,)),
                        );
                      },
                      child:_opcionesScanerQr(),
                      //Center(child:  Container(child: Text("qr", style: TextStyle(color: Colors.red, fontSize: 50), ),)),
                    ),
                  ),
                )
                    : const Center(child: Text("Camera inactive"))),
            Text("QRCODE: $qr"),
          ],
        ),
      ),


    );
  }



Widget _opcionesScanerQr(){

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(children: [IconButton(onPressed: (){
          _swapBackLightState();
        }, icon: Icon(Icons.lightbulb), color: Colors.white, ),Text(Cadenas.get("luz",),style:TextStyle(color: Colors.white,))],),
        SizedBox(width: 20,),
        Column(children: [ IconButton(onPressed: (){ _pickImage(ImageSource.gallery);}, icon: Icon(Icons.qr_code), color: Colors.white), Text(Cadenas.get("scanear_imagen",),style:TextStyle(color: Colors.white,))],)
   ],);

}
  _swapBackLightState() async {
    //prende el flash
    QrCamera.toggleFlash();
  }

  @override
  void OnPause(){

    showtoast("On pause");

  }


  @override
  void OnRestar(){
    showtoast("On restar");

  }


  @override
  void OnDestroy(){

    showtoast("On destroy");

  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    showtoast(" didChangeDependencies");
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    showtoast("deactivate");
    camState = true;
    super.deactivate();


  }


  @override void dispose() {
    // TODO: implement dispose
    super.dispose();
    camState = true;
    showtoast("dispose");

  }




  void showtoast(String msg){
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT, // Duración: SHORT o LONG
      gravity: ToastGravity.BOTTOM, // Posición: TOP, CENTER, BOTTOM
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }


 late File _image;



  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        setState(() {
          _image = imageFile;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScanQrImage(image: _image,)),
          );
          showtoast("Código escaneado");
        });
      }
    } catch (e) {
      print("error picker $e");
      showtoast("$e");
    }
  }
}


