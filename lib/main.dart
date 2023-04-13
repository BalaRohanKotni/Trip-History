import 'package:flutter/material.dart';
import 'package:trip_history/views/home_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Trip History",
      theme: ThemeData(
        /* light theme settings */
        fontFamily: "Inter",
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 18),
        ),
      ),
      darkTheme: ThemeData(
        /* light theme settings */
        brightness: Brightness.dark,
        fontFamily: "Inter",
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 18),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
