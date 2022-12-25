import 'package:flutter/material.dart';

import './police_upload.dart';

// This is the police authentication page.
class SecurityKey extends StatefulWidget {
  const SecurityKey({Key key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SecurityKeyState createState() => _SecurityKeyState();
}

class _SecurityKeyState extends State<SecurityKey> {
  // Properties related to key entry.
  final _enteredKey = TextEditingController();
  var _showObs = true;

  // Method to enable or disable the obscureness in the password key.
  void _showKey() {
    setState(() {
      _showObs = !_showObs;
    });
  }

  // The main build function for the current StatefulWidget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Police Authentication'),
        backgroundColor: Colors.lime[100],
        elevation: 0,
      ),
      backgroundColor: Colors.lime[100],
      body: Center(
          child: Card(
              margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.07),
              child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                          child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _enteredKey,
                            decoration: InputDecoration(
                                label: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: const [
                                  Text('Please enter the security key')
                                ])),
                            obscureText: _showObs,
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();

                                    // The password verification which has been hardcoded for this protoype.
                                    if (_enteredKey.text == 'theKey') {
                                      // Navigation to the police interface after authentication.
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(builder: (_) {
                                        return const PoliceUpload();
                                      }));
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content:
                                            const Text('Wrong key entered!'),
                                        backgroundColor: Colors.red[200],
                                      ));
                                    }
                                  },
                                  child: const Text('Submit'),
                                ),
                                TextButton(
                                    onPressed: _showKey,
                                    child: Row(children: [
                                      Icon(
                                        Icons.check_box,
                                        color: _showObs
                                            ? Colors.grey
                                            : Colors.lime,
                                      ),
                                      const SizedBox(width: 5),
                                      const Text('Show key')
                                    ]))
                              ])
                        ],
                      )))))),
    );
  }
}
