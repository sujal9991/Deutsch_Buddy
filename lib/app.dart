import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/learning_models.dart';

part 'src/parts/speech_service.dart';
part 'src/parts/lesson_content.dart';
part 'src/parts/progress_store.dart';
part 'src/parts/auth_feature.dart';
part 'src/parts/home_navigation.dart';
part 'src/parts/dashboard_tab.dart';
part 'src/parts/learn_tab.dart';
part 'src/parts/lesson_page.dart';
part 'src/parts/reading_dictionary.dart';
part 'src/parts/tools_tab.dart';
part 'src/parts/profile_tab.dart';

const brandBlue = Color(0xFF3157D5);
const pageBackground = Color(0xFFF5F7FC);
const darkText = Color(0xFF17233C);
const softBlue = Color(0xFFEDF1FF);
const softGreen = Color(0xFFEAF8EF);

class DeutschBuddyApp extends StatelessWidget {
  const DeutschBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeutschBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pageBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: brandBlue),
        appBarTheme: const AppBarTheme(
          backgroundColor: pageBackground,
          foregroundColor: darkText,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE7EAF2)),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}
