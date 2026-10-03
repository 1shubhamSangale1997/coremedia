import 'package:flutter/material.dart';
import 'package:coremedia/screens/login_screen.dart';

class CoreMediaApp extends StatelessWidget {
  const CoreMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoreMedia Event',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCC0000),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}