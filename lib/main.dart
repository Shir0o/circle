import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/clock.dart';
import 'providers/people_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CircleApp());
}

class CircleApp extends StatelessWidget {
  final Clock? clock;
  final SharedPreferences? prefs;

  const CircleApp({super.key, this.clock, this.prefs});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PeopleProvider>(
      create: (_) => PeopleProvider(clock: clock, prefs: prefs),
      child: Consumer<PeopleProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Circle · Organization Member Tracking',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: provider.themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
