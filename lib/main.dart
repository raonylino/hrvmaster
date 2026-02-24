import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('theme') ?? 'light';
  final savedLanguage = prefs.getString('language') ?? 'pt_BR';

  runApp(
    ProviderScope(
      child: HRVMasterApp(
        initialTheme: savedTheme,
        initialLanguage: savedLanguage,
      ),
    ),
  );
}
