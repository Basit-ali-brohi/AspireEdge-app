import 'package:flutter/material.dart';

class GraduateScreen extends StatelessWidget {
  final String userName;
  const GraduateScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Graduate Dashboard - $userName'),
      ),
      body: Center(child: Text('Welcome, $userName!')),
    );
  }
}
