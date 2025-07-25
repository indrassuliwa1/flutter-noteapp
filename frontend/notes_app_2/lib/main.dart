import 'package:flutter/material.dart';
import 'package:notes_app_2/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 132, 226, 217),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
