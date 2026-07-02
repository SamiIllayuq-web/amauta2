import 'package:flutter/material.dart';

import '../services/preferences_service.dart';
import '../widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int total = 0;
  String lastExam = "Sin simulacros";

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final exams = await PreferencesService.totalExams();
    final last = await PreferencesService.lastExam();

    setState(() {
      total = exams;
      lastExam = last;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Bienvenido",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Row(
              children: [

                Expanded(
                  child: Card(
                    elevation: 4,

                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        children: [

                          const Text(
                            "Simulacros",
                            style: TextStyle(fontSize: 16),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "$total",
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Card(
                    elevation: 4,

                    child: const Padding(
                      padding: EdgeInsets.all(16),

                      child: Column(
                        children: [

                          Text(
                            "Estado",
                            style: TextStyle(fontSize: 16),
                          ),

                          SizedBox(height: 10),

                          Text(
                            "Activo",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 25),

            Card(
              elevation: 4,

              child: ListTile(
                leading: const Icon(Icons.school),

                title: const Text(
                  "Último simulacro",
                ),

                subtitle: Text(lastExam),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(

                onPressed: () {

                  Navigator.pushNamed(
                    context,
                    '/catalog',
                  );

                },

                icon: const Icon(Icons.menu_book),

                label: const Text(
                  "Ver Simulacros",
                ),
              ),
            ),

          ],
        ),
      ),

      bottomNavigationBar: const BottomNav(
        currentIndex: 0,
      ),
    );
  }
}