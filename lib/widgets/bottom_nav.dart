import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {

  final int currentIndex;

  const BottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {

    return BottomNavigationBar(

      currentIndex: currentIndex,

      type: BottomNavigationBarType.fixed,

      onTap: (index) {

        switch(index){

          case 0:
            Navigator.pushReplacementNamed(
              context,
              '/home',
            );
            break;

          case 1:
            Navigator.pushReplacementNamed(
              context,
              '/catalog',
            );
            break;

          case 2:
            Navigator.pushReplacementNamed(
              context,
              '/progress',
            );
            break;

          case 3:
            Navigator.pushReplacementNamed(
              context,
              '/profile',
            );
            break;

          
        }
      },

      items: const [

        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Inicio",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: "Catálogo",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: "Progreso",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Perfil",
        ),
      
      ],
    );
  
  }
  
}