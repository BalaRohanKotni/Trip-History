// ignore_for_file: use_build_context_synchronously
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trip_history/views/verifyemail_screen.dart';

import '../constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController(),
      passwordController = TextEditingController();
  Future signUp() async {
    bool networkStatus = await hasNetwork();
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      String error = firebaseExceptionHandler(e, networkStatus);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
    if (!FirebaseAuth.instance.currentUser!.emailVerified) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => VerifyEmailScreen(
                    email: emailController.text.trim(),
                  )));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
          flex: 1,
          child: Container(
            color: kPurpleLightShade,
            width: double.maxFinite,
            alignment: Alignment.bottomLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 18),
              child: Text(
                "Create a new Account",
                style: semiBold18().copyWith(
                  fontSize: 38,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.only(left: 18, right: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    validator: (email) =>
                        email != "" && !EmailValidator.validate(email!)
                            ? 'Enter a valid email'
                            : null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: emailController,
                  ),
                  // const SizedBox(
                  //   height: 32,
                  // ),
                  TextField(
                      controller: passwordController,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      style: const TextStyle(fontSize: 16),
                      onSubmitted: (_) => signUp(),
                      decoration: const InputDecoration(
                          labelText: "Password", border: OutlineInputBorder())),
                  // const SizedBox(
                  //   height: 32,
                  // ),
                  SizedBox(
                    height: 50,
                    child: TextButton(
                      onPressed: signUp,
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(kPurpleDarkShade),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Sign up",
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Text(
                    "or",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(fontSize: 16),
                      ),
                      MaterialButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        enableFeedback: false,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Sign in",
                          style:
                              TextStyle(color: kPurpleDarkShade, fontSize: 16),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
