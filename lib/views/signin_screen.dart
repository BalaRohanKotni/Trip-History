import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trip_history/constants.dart';
import 'package:trip_history/views/signup_screen.dart';

import 'forgotpassword_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  TextEditingController emailController = TextEditingController(),
      passwordController = TextEditingController();
  final _scrollController = ScrollController();
  Future signIn() async {
    bool networkStatus = await hasNetwork();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());
// ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Signed in!")));
    } on FirebaseAuthException catch (e) {
      String error = firebaseExceptionHandler(e, networkStatus);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(children: [
            SizedBox(
              height: (MediaQuery.sizeOf(context).height >=
                      MediaQuery.sizeOf(context).width)
                  ? MediaQuery.sizeOf(context).height / 4
                  : MediaQuery.sizeOf(context).width / 4,
              child: Container(
                color: kPurpleLightShade,
                width: double.maxFinite,
                alignment: Alignment.bottomLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 18),
                  child: Text(
                    "Sign in to your Account",
                    style: semiBold18()
                        .copyWith(fontSize: 38, color: kPurpleDarkShade),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: (MediaQuery.sizeOf(context).height >=
                      MediaQuery.sizeOf(context).width)
                  ? MediaQuery.sizeOf(context).height * 3 / 4
                  : MediaQuery.sizeOf(context).width * 3 / 4,
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
                          onSubmitted: (_) => signIn(),
                          decoration: const InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder())),
                      // const SizedBox(
                      //   height: 32,
                      // ),
                      SizedBox(
                        height: 50,
                        child: TextButton(
                          onPressed: signIn,
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(kPurpleDarkShade),
                              foregroundColor:
                                  WidgetStateProperty.all(Colors.white),
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)))),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  "Sign in",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Wrap(
                        alignment: WrapAlignment.end,
                        children: [
                          Container(),
                          MaterialButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ForgotPassword(
                                          email: emailController.text)));
                            },
                            child: Text(
                              "Forgot password?",
                              style: semiBold18().copyWith(
                                color: kPurpleDarkShade,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        "or",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        width: double.maxFinite,
                        child: Wrap(
                          spacing: 4,
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignupScreen()));
                              },
                              child: const Text(
                                "Create an account",
                                style: TextStyle(
                                    color: kPurpleDarkShade, fontSize: 16),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
