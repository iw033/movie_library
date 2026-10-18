import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import 'app_style.dart';
import 'splash_page.dart';

void main() {
  runApp(const MovieLibraryApp());
}

class MovieLibraryApp extends StatelessWidget {
  const MovieLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Library',
      debugShowCheckedModeBanner: false,
      // lets the carousel be dragged with the mouse on the web
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        // The MovieCard reads its background color from here.
        cardColor: AppColors.card,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.glow,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
      ),
      home: const SplashPage(),
    );
  }
}
