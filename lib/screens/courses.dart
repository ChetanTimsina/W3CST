import 'package:flutter/material.dart';

class courseScreen extends StatefulWidget {
  const courseScreen({super.key});

  @override
  State<courseScreen> createState() => _courseScreenState();
}

class _courseScreenState extends State<courseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course'),
        backgroundColor: const Color.fromARGB(255, 3, 62, 91),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: const Text('Courses Screen'),
    );
  }
}
