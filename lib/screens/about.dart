import 'package:flutter/material.dart';

class aboutScreen extends StatefulWidget {
  const aboutScreen({super.key});

  @override
  State<aboutScreen> createState() => _aboutScreenState();
}

class _aboutScreenState extends State<aboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: const Color.fromARGB(255, 3, 62, 91),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: const Text('Abouts Screen'),
    );
  }
}
