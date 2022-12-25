import 'package:flutter/material.dart';

import './front_screen.dart';
import '../SignPage/sign_up_form.dart';
import '../SignPage/sign_in_page.dart';
import '../Police Panel/security_key.dart';

// This is our welcome page! This includes features to navigate to Sign In page, Sign Up page, and Police Portal.
class WelcomePage extends StatelessWidget {
  const WelcomePage({Key key}) : super(key: key);

  // Method to navigate to Police Authentication Page.
  void takeToSecurityKey(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return const SecurityKey();
    }));
  }

  // Method to navigate back to App Manual.
  void takeBackToInfo(BuildContext ctx) {
    Navigator.of(ctx).pushReplacement(MaterialPageRoute(builder: (_) {
      return FrontScreen();
    }));
  }

  // Method to navigate to Sign In page.
  void takeToSignInPage(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return const SignInPage();
    }));
  }

  // Method to navigate to Sign Up page.
  void takeToSignUpFormPage(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
      return const SignUpForm();
    }));
  }

  @override
  // The main build function for the current StatelessWidget class.
  Widget build(BuildContext context) {
    // Accessing the usable screen size via MediaQuerry.
    final screenSize =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 11, 18, 26),
      body: SingleChildScrollView(
          child: Stack(children: <Widget>[
        SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              'assets/images/lost_child.jpg',
              fit: BoxFit.fill,
            )),
        Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
            Widget>[
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            TextButton(
                onPressed: () => takeBackToInfo(context),
                child: const Text(
                  'Manual',
                  style: TextStyle(color: Colors.white),
                )),
            Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
                child: IconButton(
                    onPressed: () => takeBackToInfo(context),
                    icon: const Icon(
                      Icons.info_outline,
                      size: 25,
                      color: Colors.white,
                    ))),
          ]),
          Column(
            children: <Widget>[
              SizedBox(
                height: screenSize * 0.036,
              ),
              Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Image.asset('assets/images/logo2.png')),
              SizedBox(
                height: screenSize * 0.32,
              ),
              ElevatedButton(
                onPressed: () => takeToSignInPage(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(screenSize * 0.04))),
                child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: screenSize * 0.016,
                        horizontal: MediaQuery.of(context).size.width * 0.12),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                          color: Colors.black, fontSize: screenSize * 0.025),
                    )),
              ),
              SizedBox(
                height: screenSize * 0.016,
              ),
              ElevatedButton(
                onPressed: () => takeToSignUpFormPage(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lime,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(screenSize * 0.04))),
                child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: screenSize * 0.016,
                        horizontal: MediaQuery.of(context).size.width * 0.12),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                          color: Colors.black, fontSize: screenSize * 0.025),
                    )),
              ),
              SizedBox(
                height: screenSize * 0.05,
              ),
              TextButton(
                  onPressed: () {
                    takeToSecurityKey(context);
                  },
                  child: Text(
                    'Register missing child',
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  ))
              // SizedBox(height: 200),
            ],
          ),
        ])
      ])),
    );
  }
}
