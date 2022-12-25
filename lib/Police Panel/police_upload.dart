import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// This is the police interface from where a police officer can lodge the credentials of a missing child.
class PoliceUpload extends StatefulWidget {
  const PoliceUpload({Key key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PoliceUploadState createState() => _PoliceUploadState();
}

class _PoliceUploadState extends State<PoliceUpload> {
  // Properties related to submission of the form.
  var _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  var _parentEmail = '';
  var _policeEmail = '';
  var _parentPhone = '';
  var _childName = '';
  var _parentAddress = '';
  File _storedImage;

  // This method uploads the data of the missing child on the firestore database and firebase storage.
  void _finalValidDataOfLostChild(
    String name,
    String parentEmail,
    String policeEmail,
    String address,
    String phone,
    File image,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final ref = FirebaseStorage.instance
          .ref()
          .child('missing_child')
          .child('$parentEmail.jpg');
      await ref.putFile(_storedImage).onComplete;
      final url = await ref.getDownloadURL();
      await Firestore.instance
          .collection('MissingChild')
          .document(parentEmail)
          .setData({
        'Child Name': name,
        'Parent Phone': phone,
        'Parent Email': parentEmail,
        'Police Email': policeEmail,
        'Parent Address': address,
        'Image': url
      });
      setState(() {
        _isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green[200],
          content: const Text('Missing Child registered successfully!')));
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
      // ignore: avoid_print
      print(err);
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

  // This method validates the entries made and checks for any potential error.
  void _submitLostChildData() {
    final isValid = _formKey.currentState.validate();
    if (_storedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please upload the image of lost child'),
        backgroundColor: Colors.red[200],
      ));
      return;
    }
    if (isValid) {
      _formKey.currentState.save();
      _finalValidDataOfLostChild(_childName, _parentEmail, _policeEmail,
          _parentAddress, _parentPhone, _storedImage);
    }
  }

  // Method to open gallery of the phone to choose the image of the missing child. This is done through Image Picker package dependency.
  Future<void> _takePicture() async {
    final imageFile = await ImagePicker()
        .getImage(source: ImageSource.gallery, maxWidth: 600, maxHeight: 600);
    setState(() {
      _storedImage = File(imageFile.path);
    });
  }

  // The main build function of the current StatefulWidget class.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Child Reporting Panel'),
          leading: IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(children: [
              Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey)),
                        child: _storedImage != null
                            ? Image.file(_storedImage,
                                fit: BoxFit.cover, width: double.infinity)
                            : const Text(
                                'No Image Taken',
                                textAlign: TextAlign.center,
                              ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _takePicture,
                        label: const Text('Upload'),
                        icon: const Icon(Icons.camera),
                      )
                    ],
                  )),
              Form(
                  key: _formKey,
                  child: Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      onSaved: (val) {
                                        _childName = val;
                                      },
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please fill the name';
                                        }
                                        return null;
                                      },
                                      cursorColor: Colors.black,
                                      cursorWidth: 1.2,
                                      cursorHeight:
                                          MediaQuery.of(context).size.height *
                                              0.028,
                                      decoration: InputDecoration(
                                        label: Row(children: [
                                          const Icon(Icons.person_add),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Text(
                                            'Name of Child',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.016),
                                          )
                                        ]),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10),
                                      ),
                                    )),
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: TextFormField(
                                      onSaved: (val) {
                                        _parentPhone = val;
                                      },
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter parent\'s phone number';
                                        }
                                        return null;
                                      },
                                      cursorColor: Colors.black,
                                      cursorWidth: 1.2,
                                      cursorHeight:
                                          MediaQuery.of(context).size.height *
                                              0.028,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        label: Row(children: [
                                          const Icon(Icons.phone),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Text(
                                            'Parent\'s Phone',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.016),
                                          )
                                        ]),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10),
                                      ),
                                    )),
                              ])),
                      Padding(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.07),
                          child: TextFormField(
                            onSaved: (val) {
                              _parentEmail = val;
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
                                'Parent\'s Email ID',
                                style: TextStyle(color: Colors.black),
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                            ),
                          )),
                      Padding(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.07),
                          child: TextFormField(
                            onSaved: (val) {
                              _parentAddress = val;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please fill the address';
                              }
                              return null;
                            },
                            cursorColor: Colors.black,
                            cursorWidth: 1.2,
                            cursorHeight:
                                MediaQuery.of(context).size.height * 0.028,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.home),
                              label: Text(
                                'Parent\'s address',
                                style: TextStyle(color: Colors.black),
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                            ),
                          )),
                      Padding(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width * 0.07),
                          child: TextFormField(
                            onSaved: (val) {
                              _policeEmail = val;
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
                                'Police Email ID',
                                style: TextStyle(color: Colors.black),
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                            ),
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.1),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
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
                                      _isLoading ? () {} : _submitLostChildData,
                               
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.black,
                                        )
                                      : const Text('Submit'),
                                )
                              ])),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02)
                    ],
                  )))),
            ])));
  }
}
