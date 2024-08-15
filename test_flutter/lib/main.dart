import 'package:flutter/material.dart';
import 'package:test_flutter/menu.dart';
import 'compare.dart'; // Import the new file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compare Items',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MenuGridPage(), // Use the CompareItemsPage widget
    );
  }
}
