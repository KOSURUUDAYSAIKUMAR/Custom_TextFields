import 'package:example/form_example.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone Input Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),

      /// Please check the Github Repository under Form Example Class.
      home: const FormExample(),
    );
  }
}
