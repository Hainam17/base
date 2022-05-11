import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      child: const Center(
        child: const CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
