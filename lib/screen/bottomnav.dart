
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:qr3/screen/configuraciones.dart';
import 'package:qr3/screen/qr.dart';
import 'package:qr3/screen/crear_qr.dart';

class BottomNav extends StatelessWidget {
   BottomNav({super.key});


  List<Widget> _buildScreens() {
    return [
      ScannerQr(),
      CrearQr(),
      ScreenSettings(),
    ];
  }
  late BuildContext contexto;

  List<PersistentBottomNavBarItem> _navBarsItems() {
    //lista de items  con los parametros para navegar en el botton nav
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.scanner, color: Theme.of(contexto).colorScheme.surface,),
        title: ("Sacnner"),
        activeColorPrimary:Theme.of(contexto).colorScheme.surface,
        inactiveColorPrimary: Colors.yellowAccent,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.create, color: Theme.of(contexto).colorScheme.surface,),
        title: ("Crear"),
        textStyle: TextStyle(color: Colors.green),
        activeColorPrimary:Theme.of(contexto).colorScheme.surface,
        inactiveColorPrimary: Theme.of(contexto).colorScheme.onSurface,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.settings, color: Theme.of(contexto).colorScheme.surface,),
        title: ("Settings"),
        textStyle: TextStyle(color: Colors.green),
        activeColorPrimary:Theme.of(contexto).colorScheme.surface,
        inactiveColorPrimary: Theme.of(contexto).colorScheme.onSurface,
      ),


    ];
  }


  @override
  Widget build(BuildContext context) {
    contexto = context;
    PersistentTabController _controller =  PersistentTabController(initialIndex: 0);
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      //confineInSafeArea: true,

      backgroundColor: Theme.of(context).colorScheme.onSurface, // color del background.
      handleAndroidBackButtonPress: true, // habilitar retroceder.
      resizeToAvoidBottomInset: true, // redimencionar
      stateManagement: true, //
      //  hideNavigationBarWhenKeyboardShows: true, //
      decoration: NavBarDecoration(
        useBackdropFilter: true,
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.green,//Theme.of(context).colorScheme.surface,
      ),

      navBarStyle: NavBarStyle.style1, // estilo
    );
  }
}
