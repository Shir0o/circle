import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/people_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CircleApp());
}

class CircleApp extends StatelessWidget {
  const CircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PeopleProvider>(
      create: (_) => PeopleProvider(),
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
