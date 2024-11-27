import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr3/screen/qr.dart';
import 'package:qr3/utils/datos.dart';
import 'package:intl_utils/intl_utils.dart';
import 'package:intl/intl.dart';

class QrScaneado extends StatefulWidget {
  final String qr;
  const QrScaneado({super.key, required this.qr});

  @override
  State<QrScaneado> createState() => _QrScaneadoState();
}

class _QrScaneadoState extends State<QrScaneado> {
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
// Redirigir a una pantalla específica cuando se presione el botón "Atrás"
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ScannerQr()),
              (route) => false,
        );
        return false; // Previene el cierre de la pantalla actual
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Segunda Pantalla")),
        body: Center(
          child: qrScaneado(widget.qr),
        ),
      ),
    );
  }




  Widget qrScaneado(String qr){
    return qrTextoPlano(qr);





    switch(Datos().interpretQRCode(qr)){



      case 6:
        return qrTextoPlano(qr);
        break;

    }


  }

  Widget qrTextoPlano(String qr){
    DateTime fecha = DateTime.now();
    String fechaFormateada= DateFormat('yyyy-MM-dd HH:mm:ss').format(fecha);


    return Column(children: [
      Center(child: Text(qr),),
      Center(child:  Text(fechaFormateada),),
      Center(child: PrettyQrView.data(
        data: 'lorem ipsum dolor sit amet',

      ),)
      //motrase el codigo

    ],
    );


  }


}


