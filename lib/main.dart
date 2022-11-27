import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './MainPage/front_screen.dart';

void main() {
  // To always keep the app in potrait mode.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            primarySwatch: Colors.lime,
            buttonTheme: ButtonTheme.of(context).copyWith(
                buttonColor: Colors.lime,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ))),
        debugShowCheckedModeBanner: false,
        home: FrontScreen());
  }
}
