import 'package:flutter/material.dart';
import 'package:qr3/screen/qr_view_recuperado.dart';
import 'package:qr3/utils/datos.dart';


class QrSave extends StatefulWidget {
  const QrSave({super.key});

  @override
  State<QrSave> createState() => _QrSaveState();
}

class _QrSaveState extends State<QrSave> {
  String tituloAppbar = "Scaner QR";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tituloAppbar),
      ),
      body:FutureBuilder(future: Datos().getSavedImages(), builder: (context, snapshot) {

        if(snapshot.connectionState == ConnectionState.waiting){
          //mientras carga
          return Center(child: CircularProgressIndicator(),);
        }
        else if(snapshot.hasError){
          return Center(child: Text("Ocurrio un error"),);
        }
        else if(!snapshot.hasData || snapshot.data!.isEmpty){
         return Center(child: Text("No se encontraron Imagenes"),);
        }

        final images = snapshot.data!;

        return ListView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            final imageFile = images[index];
            return Card(

              child: ListTile(
                onTap:(){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QrViewRecuperado(imageFile:imageFile),
                    ),
                  );

                } ,
                leading: Image.file(imageFile, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(imageFile.path.split('/').last),
              ),
            );
          },
        );

      },) ,);
  }
}
