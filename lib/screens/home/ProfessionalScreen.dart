import 'package:flutter/material.dart';

class ProfessionalScreen extends StatelessWidget {
  final String userName;
  const ProfessionalScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Professional Dashboard - $userName'),
      ),
      body: Center(child: Text('Welcome, $userName!')),
    );
  }
}
