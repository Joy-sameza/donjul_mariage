import 'package:flutter/material.dart';

class GuestList extends StatelessWidget {
  const GuestList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest List'),
      ),
      body: const Center(
        child: Text('Guest List')
      ),
    );
  }
}
