import 'package:flutter/material.dart';

import '../../SignPage/sign_up_form.dart';

// This is the authorization widget; it checks if the sign in details entered in the sign in page are valid or not. This widget also contains the widgets which were displayed on the Sign In screen.
class AuthForm extends StatefulWidget {
  final void Function(
    String email,
    String password,
    BuildContext ctx,
  ) submitFunction;
  final bool loadingStatus;
  const AuthForm(this.submitFunction, this.loadingStatus, {Key key})
      : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _userEnteredEmail = '';
  String _userEnteredPassword = '';

  // This method navigates the user to sign up page from the sign in page.
  void createAccount(ctx) {
    Navigator.of(ctx).pushReplacement(MaterialPageRoute(builder: (_) {
      return const SignUpForm();
    }));
  }

  // This method checks if entered credentials are valid or not and submits the data to firestore database.
  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState.save();
      widget.submitFunction(_userEnteredEmail, _userEnteredPassword, context);
    }
  }

  // This is the main build function for our StatefulWidget class.
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
            margin: const EdgeInsets.all(20),
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              onSaved: (val) {
                                _userEnteredEmail = val;
                              },
                              validator: (value) {
                                if (value.isEmpty ||
                                    !value.contains('@') ||
                                    !value.contains('.com')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  labelText: 'Email address',
                                  icon: Icon(Icons.email)),
                            ),
                            TextFormField(
                              onSaved: (val) {
                                _userEnteredPassword = val;
                              },
                              validator: (value) {
                                if (value.isEmpty || value.length < 7) {
                                  return 'Password must be at least 7 characters long';
                                }
                                return null;
                              },
                              obscureText: true,
                              decoration: const InputDecoration(
                                  labelText: 'Password',
                                  icon: Icon(Icons.password)),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02,
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.1),
                                elevation: 5,
                              ),
                              onPressed:
                                  widget.loadingStatus ? () {} : _trySubmit,
                              child: widget.loadingStatus
                                  ? const CircularProgressIndicator(
                                      color: Colors.black,
                                    )
                                  : const Text('Login'),
                            ),
                            TextButton(
                                onPressed: () => createAccount(context),
                                child: const Text('Create new account'))
                          ],
                        ))))));
  }
}
