// ignore: depend_on_referenced_packages
import 'package:intro_slider/intro_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './welcome_page.dart';

// This is the code for the app manual.
// ignore: must_be_immutable
class FrontScreen extends StatelessWidget {
  // The content for the app manual; each slide indicates a page on the app manual.
  List<Slide> slides = [
    Slide(
        description:
            "Our team has created a mobile app which helps to locate a missing child by the means of a face recognition API and send this location to the police department and the child’s parents via email along with the information of the user who found the lost child. The app contains a user interface and a police interface.",
        pathImage: "assets/images/manual1.png",
        styleDescription: TextStyle(
          color: Colors.lime[100],
          fontSize: 18,
        ),
        backgroundColor: Colors.black),
    Slide(
      title: "User Interface",
      description:
          "Sign in as a user to scan the face of a potentially missing child and help him reach home.\n\n An email notification is directly sent to the parents and the police department in case a match is found!",
      pathImage: "assets/images/face.png",
      backgroundColor: Colors.black,
      styleTitle: TextStyle(
          color: Colors.lime[100], fontSize: 28, fontWeight: FontWeight.bold),
      styleDescription: TextStyle(
        fontSize: 18,
        color: Colors.lime[100],
      ),
    ),
    Slide(
      title: "Police Interface",
      description:
          "The police department holds the authority to upload the image and details of a missing child to the data server. Whenever a user scans a face, the face is compared with every image in the data set, handled by the police department, to check for a match.",
      styleTitle: TextStyle(
          color: Colors.lime[100], fontSize: 28, fontWeight: FontWeight.bold),
      styleDescription: TextStyle(
        fontSize: 18,
        color: Colors.lime[100],
      ),
      backgroundColor: Colors.black,
      pathImage: "assets/images/police.png",
    )
  ];

  FrontScreen({Key key}) : super(key: key);

  // Method to navigate to the welcome page of the app.
  void homeWidget(BuildContext ctx) {
    Navigator.of(ctx).pushReplacement(MaterialPageRoute(builder: (_) {
      return const WelcomePage();
    }));
  }

  // The main build function for the current StatelessWidget class.
  @override
  Widget build(BuildContext context) {
    // To keep the app in full screen mode.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      // IntroSlider is provided by the intro_slider package dependency.
      body: IntroSlider(
        slides: slides,
        onDonePress: () => homeWidget(context),
        onSkipPress: () => homeWidget(context),
        autoScroll: false,
      ),
    );
  }
}
