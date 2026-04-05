import 'package:flutter/material.dart';
import 'screen/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chess App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1E3A5F),
      ),
      home: const HomePage(),
    );
  }
}
