import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trip_history/constants.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  TextEditingController emailController = TextEditingController(),
      passwordController = TextEditingController();
  Future signIn() async {
    bool networkStatus = await hasNetwork();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      String error = "";
      switch (e.code) {
        case "invalid-email":
          error = "Email address is not valid";
          break;
        case "user-disabled":
          error = "Account is disabled";
          break;
        case "user-not-found":
          error =
              "Account not found, check email address or create a new account";
          break;
        case "wrong-password":
          error = "Incorrect password";
          break;
        default:
          if (!networkStatus) {
            error = "No internet connection";
          } else {
            error = "An unknown error has occurred";
          }
        // error = e.code;
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign in"),
        centerTitle: true,
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
                Expanded(
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(hintText: "Email"),
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
                Expanded(
                  child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      style: const TextStyle(fontSize: 16),
                      onSubmitted: (_) => signIn(),
                      decoration: const InputDecoration(hintText: "Password")),
                ),
              ],
            ),
            const SizedBox(
              height: 32,
            ),
            SizedBox(
              height: 50,
              child: TextButton(
                onPressed: signIn,
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
