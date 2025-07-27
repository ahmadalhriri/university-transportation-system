import 'package:flutter/material.dart';

class Showtable extends StatefulWidget {
  const Showtable({super.key});

  @override
  State<Showtable> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Showtable> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('data'));
  }
}