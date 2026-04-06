import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home_page.dart';
import 'pages/welcome_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'pages/loading_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite FFI for all platforms
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MatchUpUni',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A8AF4)),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const LoadingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
