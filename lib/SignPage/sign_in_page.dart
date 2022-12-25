import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../Widgets/auth/auth_form.dart';
import '../LoggedInPage/user_page.dart';

// This is the Sign In page.
class SignInPage extends StatefulWidget {
  const SignInPage({Key key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  var _isLoading = false;
  final _auth = FirebaseAuth.instance;

  // Method to Authenticate the user
  void _submitAuthForm(
    String email,
    String password,
    BuildContext ctx,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // ignore: use_build_context_synchronously
      Navigator.of(ctx).pushReplacement(MaterialPageRoute(builder: (_) {
        return UserPage(email);
      }));
      setState(() {
        _isLoading = false;
      });
    } on PlatformException catch (err) {
      setState(() {
        _isLoading = false;
      });
      var message = 'Please check your credentials and try again!';
      if (err.message != null) {
        message = err.message;
      }
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
      ));
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: const Text('Unsuccessful! Please try again...'),
        backgroundColor: Colors.red[400],
      ));
    }
  }

  // The main build function of our StatefulWidget class
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.24),
            child: const Text(
              'Sign In',
              textAlign: TextAlign.center,
            )),
        backgroundColor: Colors.lime[100],
        elevation: 0,
      ),
      backgroundColor: Colors.lime[100],
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}
