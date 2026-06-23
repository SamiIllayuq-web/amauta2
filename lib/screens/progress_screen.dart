import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import '../widgets/bottom_nav.dart';

class ProgressScreen
    extends StatefulWidget {

  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() =>
      _ProgressScreenState();
}

class _ProgressScreenState
    extends State<ProgressScreen> {

  List<String> history = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

    final data =
        await PreferencesService
            .loadHistory();

    setState(() {
      history = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Progreso"),
      ),

      body: ListView.builder(

        itemCount: history.length,

        itemBuilder:
            (context, index) {

          return Card(

            child: ListTile(

              leading: const Icon(
                Icons.school,
              ),

              title: Text(
                history[index],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar:
          const BottomNav(
        currentIndex: 2,
      ),
    );
  }
}