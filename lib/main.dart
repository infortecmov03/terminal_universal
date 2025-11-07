// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import 'core/device_manager/terminal_manager.dart';
import 'features/terminal/terminal_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(const MyApp());
}

void setupLocator() {
  GetIt.I.registerSingleton<TerminalManager>(TerminalManager());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TerminalManager>(
      create: (context) => GetIt.I<TerminalManager>(),
      child: MaterialApp(
        title: 'Terminal Universal',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const TerminalScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}