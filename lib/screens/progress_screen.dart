import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import '../services/storage_service.dart';

class ProgressScreen extends StatelessWidget {

  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      bottomNavigationBar:
    const BottomNav(
      currentIndex: 2,
),

      appBar: AppBar(
        title: const Text("Progreso"),
      ),

      body: ListView.builder(

  itemCount:
      StorageService.history.length,

  itemBuilder: (context, index) {

    final item =
        StorageService.history[index];

    return Card(

      margin:
          const EdgeInsets.all(10),

      child: ListTile(

        leading: const Icon(
          Icons.school,
        ),

        title:
            Text("Puntaje: ${item.score}"),

        subtitle:
            Text(item.date.toString()),
      ),
    );
  },
),

    );
  }
}