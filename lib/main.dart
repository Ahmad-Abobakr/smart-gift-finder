import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const SmartGiftFinderApp());
}

class SmartGiftFinderApp extends StatelessWidget {
  const SmartGiftFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Gift Finder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const Scaffold(
        body: Center(
          child: Text('Smart Gift Finder'),
        ),
      ),
    );
  }
}
