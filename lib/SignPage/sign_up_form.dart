import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../LoggedInPage/user_page.dart';

// This is our Sign Up page
class SignUpForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignUpFormState();
  }
}

class SignUpFormState extends State<SignUpForm> {
  var _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String _signUpName = '';
  String _signUpPhone = '';
  String _signUpEmailID = '';
  String _signUpPassword = '';
  final _auth = FirebaseAuth.instance;

  // Method to submit the data.
  void _submitSignUpData() {
    final _isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (_isValid) {
      _formKey.currentState.save();
      _submitAuthForm(
          _signUpName, _signUpPhone, _signUpEmailID.trim(), _signUpPassword);
    }
  }

  // This method is called by _submitSignUpData to submit the data entered by the user.
  void _submitAuthForm(
    String name,
    String phone,
    String email,
    String password,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      AuthResult account;
      account = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await Firestore.instance.collection('Users').document(email).setData({
        'Name': name,
        'Phone': phone,
        'email': email,
      });
      AuthResult signInStatus;
      signInStatus = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
        return UserPage(email);
      }));
    } on PlatformException catch (err) {
      setState(() {
        _isLoading = false;
      });
      var message = 'An error occured; please try again.';
      if (err.message != null) {
        message = err.message;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
      ));
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      var message = 'An error occured; please try again...';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
      ));
    }
  }

  // This is the main build function of our StatefulWidget class.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lime[100],
      appBar: AppBar(
        title: Row(children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.16,
          ),
          const Text(
            'Sign Up Form',
            textAlign: TextAlign.center,
          )
        ]),
        backgroundColor: Colors.lime[100],
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.1),
                      child: TextFormField(
                        onSaved: (val) {
                          _signUpName = val;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please fill your name';
                          }
                          return null;
                        },
                        cursorColor: Colors.black,
                        cursorWidth: 1.2,
                        cursorHeight:
                            MediaQuery.of(context).size.height * 0.028,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person_add),
                          label: Text(
                            'Name',
                            style: TextStyle(color: Colors.black),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      )),
                  Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.1),
                      child: TextFormField(
                        onSaved: (val) {
                          _signUpPhone = val;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                        cursorColor: Colors.black,
                        cursorWidth: 1.2,
                        cursorHeight:
                            MediaQuery.of(context).size.height * 0.028,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.phone),
                          label: Text(
                            'Phone Number',
                            style: TextStyle(color: Colors.black),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      )),
                  Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.1),
                      child: TextFormField(
                        onSaved: (val) {
                          _signUpEmailID = val;
                        },
                        validator: (value) {
                          if (value.isEmpty ||
                              !value.contains('@') ||
                              !value.contains('.com')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        cursorColor: Colors.black,
                        cursorWidth: 1.2,
                        cursorHeight:
                            MediaQuery.of(context).size.height * 0.028,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email),
                          label: Text(
                            'Email ID',
                            style: TextStyle(color: Colors.black),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      )),
                  Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.1),
                      child: TextFormField(
                        onSaved: (val) {
                          _signUpPassword = val;
                        },
                        validator: (value) {
                          if (value.isEmpty || value.length < 7) {
                            return 'Password must be at least 7 characters long';
                          }
                          return null;
                        },
                        obscureText: true,
                        cursorColor: Colors.black,
                        cursorWidth: 1.2,
                        cursorHeight:
                            MediaQuery.of(context).size.height * 0.028,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.password),
                          label: Text(
                            'Password',
                            style: TextStyle(color: Colors.black),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      )),
                  Padding(
                      padding: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.1),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.height * 0.02,
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.1),
                                      elevation: 5,
                                      ),
                              
                              onPressed: _isLoading ? () {} : _submitSignUpData,
                              
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.black,
                                    )
                                  : const Text('Submit'),
                            )
                          ]))
                ],
              ))),
    );
  }
}
