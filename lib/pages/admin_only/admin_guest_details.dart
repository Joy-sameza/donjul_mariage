import 'package:flutter/material.dart';

class GuestDetails extends StatelessWidget {
  const GuestDetails({super.key});

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
