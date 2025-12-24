import 'package:flutter/material.dart';

class AppPage extends StatelessWidget {
  final Widget child;

  const AppPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,   // AppBar bleibt oben normal
      bottom: true, // ✅ unten immer Platz
      child: child,
    );
  }
}
