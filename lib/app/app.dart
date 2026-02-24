import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/app_theme_light.dart';
import '../core/theme/app_theme_dark.dart';
import '../core/localization/app_localizations.dart';
import 'routes.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  void setTheme(String theme) {
    state = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('pt', 'BR'));

  void setLocale(String languageCode) {
    if (languageCode == 'en_US') {
      state = const Locale('en', 'US');
    } else {
      state = const Locale('pt', 'BR');
    }
  }
}

class HRVMasterApp extends ConsumerStatefulWidget {
  final String initialTheme;
  final String initialLanguage;

  const HRVMasterApp({
    super.key,
    required this.initialTheme,
    required this.initialLanguage,
  });

  @override
  ConsumerState<HRVMasterApp> createState() => _HRVMasterAppState();
}

class _HRVMasterAppState extends ConsumerState<HRVMasterApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(themeProvider.notifier).setTheme(widget.initialTheme);
      ref.read(localeProvider.notifier).setLocale(widget.initialLanguage);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'HRV Master',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppThemeLight.theme,
      darkTheme: AppThemeDark.theme,
      locale: locale,
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
