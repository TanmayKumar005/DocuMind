import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const DocuMindApp());
}

class DocuMindApp extends StatelessWidget {
  const DocuMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DocuMind',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6C63FF),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF8B80FF),
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
