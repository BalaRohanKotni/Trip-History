import 'package:flutter/material.dart';
import 'package:trip_history/views/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trip_history/views/signin_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 18),
        ),
      ),
      darkTheme: ThemeData(
        /* dark theme settings */
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: "Inter",
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 18),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const SigninScreen(),
    );
  }
}
