

class Datos  {

static final Datos _instancia = Datos._internal();

Datos._internal();

// Factory constructor para devolver la misma instancia
  factory Datos() {
    return _instancia;
  }
  String qr = "";

  int interpretQRCode(String data) {
    if (data.startsWith("BEGIN:VCARD")) {
      //"Es un contacto (vCard)";
      return 1;
    } else if (data.startsWith("http://") || data.startsWith("https://")) {
      //"Es una página web";
      return 2;
    } else if (data.startsWith("WIFI:")) {
      //"Es información de Wi-Fi";
      return 3;
    } else if (data.startsWith("geo:")) {
      //"Es una ubicación";
      return 4;
    } else if (data.contains("BEGIN:VEVENT")) {
      //"Es un evento del calendario";
      return 5;
    } else {
      //"Contenido desconocido o texto simple";
      return 6;
    }
  }

}