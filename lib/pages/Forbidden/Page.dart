import 'package:flutter/material.dart';

class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('403'),
      ),
      body: const Center(
          child: const Text('BẠN KHÔNG CÓ QUYỀN TRUY CẬP.')),
    );
  }
}
