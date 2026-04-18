import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        dialogTheme: const DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          elevation: 10,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          showDragHandle: true,
        ),
      ),
      builder: (context, child) {
        return Container(
          color: const Color(0xFFE2E8F0), // สีพื้นหลังขอบเวลาจอใหญ่
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 800,
              ), // ปรับให้เหมาะกับ Tablet
              child: child,
            ),
          ),
        );
      },
      home: const LoadingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
