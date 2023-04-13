import 'package:flutter/material.dart';
import 'package:trip_history/Screens/signin_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Trip History",
      home: SigninScreen(),
    );
  }
}
