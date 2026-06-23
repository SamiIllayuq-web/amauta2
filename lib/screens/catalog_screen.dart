import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      bottomNavigationBar:
    const BottomNav(
      currentIndex: 1,
),
  
      appBar: AppBar(
        title: const Text("Catálogo"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          Card(
            elevation: 4,

            child: ListTile(
              leading: const Icon(Icons.school),

              title: const Text(
                "Simulacro UNH 2025",
              ),

              subtitle: const Text(
                "Área Ingeniería",
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),

              onTap: () {

                Navigator.pushNamed(
                  context,
                  '/exam',
                );

              },
            ),
          ),

          const SizedBox(height: 10),

          Card(
            elevation: 4,

            child: ListTile(
              leading: const Icon(Icons.school),

              title: const Text(
                "Simulacro UNCP 2025",
              ),

              subtitle: const Text(
                "Área Ciencias",
              ),

              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),

              onTap: () {

                Navigator.pushNamed(
                  context,
                  '/exam',
                );

              },
            ),
          ),
        ],
      ),
    );
  }
}