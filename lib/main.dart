import 'package:flutter/material.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Opisms',
      routerConfig: appRouter,
      theme: ThemeData(
        primaryColor: Colours.secondaryText,
        scaffoldBackgroundColor: Colours.background,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colours.background),
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
    );
  }
}