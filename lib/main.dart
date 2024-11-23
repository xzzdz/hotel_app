import 'package:flutter/material.dart';

import 'screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The kannas repair App',
      theme: ThemeData(
          primarySwatch: Colors.grey,
          scrollbarTheme: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(Colors.grey[200]))),
      home: const Login(),
    );
  }
}
