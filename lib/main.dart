import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:trip_history/constants.dart';
import 'package:trip_history/views/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trip_history/views/signin_screen.dart';
import 'firebase_options.dart';

void main() async {
  // TODO: Uncomment the following during release to hide red screen of errors
  // RenderErrorBox.backgroundColor = Colors.transparent;
  // RenderErrorBox.textStyle = ui.TextStyle(color: Colors.transparent);
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
    return StreamBuilder<bool>(
        initialData: true,
        stream: isLightThemeModeStreamController.stream,
        builder: (context, snapshot) {
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
            themeMode: (snapshot.data!) ? ThemeMode.light : ThemeMode.dark,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return const HomeScreen();
                } else {
                  return const SigninScreen();
                }
              },
            ),
          );
        });
  }
}
