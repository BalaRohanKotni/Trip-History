import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign in"),
      ),
      body: SafeArea(
          child: Container(
        margin: const EdgeInsets.only(left: 36, right: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  "assets/icons/mail.svg",
                  semanticsLabel: "Password",
                  width: 36,
                ),
                const SizedBox(
                  width: 16,
                ),
                const Expanded(
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(hintText: "Email"),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 32,
            ),
            Row(
              children: [
                SvgPicture.asset(
                  "assets/icons/closed-lock.svg",
                  semanticsLabel: "Password",
                  width: 36,
                ),
                const SizedBox(
                  width: 16,
                ),
                const Expanded(
                  child: TextField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(hintText: "Password")),
                ),
              ],
            ),
            const SizedBox(
              height: 32,
            ),
            SizedBox(
              height: 50,
              child: TextButton(
                onPressed: () {
                  // TODO
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26)))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Sign in",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              "or",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 16,
            ),
            TextButton(
                onPressed: () {
                  // TODO
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sign in with",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    SvgPicture.asset(
                      "assets/icons/google.svg",
                      width: 32,
                    )
                  ],
                )),
            const SizedBox(
              height: 32,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "New?",
                  style: TextStyle(fontSize: 16),
                ),
                MaterialButton(
                  padding: const EdgeInsets.only(left: 8),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  enableFeedback: false,
                  onPressed: () {
                    // TODO
                  },
                  child: const Text(
                    "Create an account",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                )
              ],
            )
          ],
        ),
      )),
    );
  }
}