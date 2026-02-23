import 'package:flutter/material.dart';

class DevHomePage extends StatelessWidget {
  const DevHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dev Home')),
      body: const Center(child: Text('Developer home ready')),
    );
  }
}
