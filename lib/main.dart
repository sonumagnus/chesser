import 'package:flutter/material.dart';
import 'package:chesser/screen/chess_trainer_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chess Trainer',
      theme: ThemeData.dark(),
      home: const ChessTrainerScreen(),
    );
  }
}
