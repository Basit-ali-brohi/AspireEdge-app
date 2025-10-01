import 'package:flutter/material.dart';

class StudentScreen extends StatelessWidget {
  final String userName;
  const StudentScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard - $userName'),
      ),
      body: Center(
        child: Text('Welcome, $userName!'),
      ),
    );
  }
}
