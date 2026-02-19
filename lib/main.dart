import 'package:flutter/material.dart';

void main() {
  runApp(const AppShell());
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThikrSpace',
      initialRoute: BootPage.routeName,
      routes: {
        BootPage.routeName: (_) => const BootPage(),
        DevHomePage.routeName: (_) => const DevHomePage(),
      },
    );
  }
}

class BootPage extends StatefulWidget {
  const BootPage({super.key});

  static const routeName = '/boot';

  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(DevHomePage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Booting...'),
      ),
    );
  }
}

class DevHomePage extends StatelessWidget {
  const DevHomePage({super.key});

  static const routeName = '/dev_home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dev Home')),
      body: const Center(
        child: Text('Developer home ready'),
      ),
    );
  }
}
