import 'package:flutter/material.dart';
import 'package:healthsync/features/notes/pages/notes_page.dart';

void main() {
  runApp(const HealthSyncApp());
}

class HealthSyncApp extends StatelessWidget {
  const HealthSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthSync',
      home: const NotesPage(),
    );
  }
}
