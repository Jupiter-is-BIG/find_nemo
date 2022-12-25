import 'dart:io';
import 'dart:io' as io;
import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
// ignore: library_prefixes
import 'package:flutter_face_api/face_api.dart' as Regula;
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';

// This is the code for the screen the user encounters after singing in his/her account.
class UserPage extends StatefulWidget {
  final String id;
  // ignore: invalid_required_positional_param
  const UserPage(@required this.id, {Key key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // Some static const properties to avoid typos in the code.
  static const phone = 'Phone';
  static const name = 'Name';
  static const email = 'email';

  // Accessing the firestore database of missing children.
  final dataBase = Firestore.instance.collection('MissingChild');

  // Properties related to accessing user's location.
  Position _currentPosition;
  double lati;
  double longi;

  // Properties relating to image upload and face recognition execution.
  File _storedImage;
  bool _status;
  var _isLoading = false;
  String urlOfChildScannedFace;

  // Properties to display the credentials of the missing child in case a match is found.
  DocumentSnapshot foundChildDatabaseAfterScan;

  // Method to fetch user's current location
  void _getUserLocation() async {
    await Geolocator.requestPermission();
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      _currentPosition = position;
      lati = _currentPosition.latitude;
      longi = _currentPosition.longitude;
    }).catchError((e) {
      // ignore: avoid_print
      print(e);
    });
  }

  // Opens camera on the device through our Image Picker package
  Future<void> _takePicture() async {
    final imageFile = await ImagePicker()
        .getImage(source: ImageSource.camera, maxWidth: 600, maxHeight: 600);
    setState(() {
      _storedImage = File(imageFile.path);
    });
  }

  // Method to convert File type image to a form that our face recognition API understands
  Regula.MatchFacesImage conv(File image) {
    var imag = Regula.MatchFacesImage();
    imag.bitmap = base64Encode(io.File(image.path).readAsBytesSync());
    imag.imageType = Regula.ImageType.PRINTED;
    return imag;
  }

  // Runs the serach of matching the face scanned by the user with the database, uploaded by the police department, of the missing children.
  Future<void> runSearch() async {
    setState(() {
      _isLoading = true;
    });
    final docs = await dataBase.getDocuments();

    final processor = docs.documents;

    final takenImage = conv(_storedImage);
    final imageRef = FirebaseStorage.instance
        .ref()
        .child('user_try_image_stock')
        .child('${widget.id}${DateTime.now()}.jpg');
    await imageRef.putFile(_storedImage).onComplete;

    urlOfChildScannedFace = await imageRef.getDownloadURL();

    // Comparing the images is initiated here.
    var i = 0;
    while (i < processor.length) {
      if (_status == true) {
        break;
      }
      var imag2 = Regula.MatchFacesImage();
      http.Response response = await http.get(processor[i]['Image']);
      imag2.bitmap = base64Encode(response.bodyBytes);
      imag2.imageType = Regula.ImageType.PRINTED;

      var requestSender = Regula.MatchFacesRequest();
      requestSender.images = [takenImage, imag2];
      await Regula.FaceSDK.matchFaces(jsonEncode(requestSender))
          .then((value) async {
        var response = Regula.MatchFacesResponse.fromJson(json.decode(value));
        await Regula.FaceSDK.matchFacesSimilarityThresholdSplit(
                jsonEncode(response.results), 0.75)
            .then((str) async {
          var split = Regula.MatchFacesSimilarityThresholdSplit.fromJson(
              json.decode(str));

          if ((split.matchedFaces.isNotEmpty ? true : false) == true) {
            setState(() {
              _status = true;
              _isLoading = false;

              foundChildDatabaseAfterScan = processor[i];
            });

            // An email is sent to the parents and police when a match is made and we exit the while loop.
            await sendingEmailToParents(
                nameOfChildFoundAfterScan:
                    foundChildDatabaseAfterScan['Child Name'],
                nameOfPersonWhoFoundChild: await userDataScanner(name),
                emailOfPersonWhoFoundChild: await userDataScanner(email),
                phoneNoOfPersonWhoFoundChild: await userDataScanner(phone),
                imageOfChildFoundAfterScan: urlOfChildScannedFace,
                latitudeOfChildFoundAfterScan: lati.toString(),
                longitudeOfChildFoundAfterScan: longi.toString(),
                emailIdOfParents: foundChildDatabaseAfterScan['Parent Email'],
                emailOfPolice: foundChildDatabaseAfterScan['Police Email'],
                phoneOfParent: foundChildDatabaseAfterScan['Parent Phone'],
                addressOfParent: foundChildDatabaseAfterScan['Parent Address']);
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.green[200],
                content:
                    const Text('Email sent to the parents and the police!')));
            return;
          }
          i++;
        });
      });
    }

    // If no match is found, we set the property _status to false.
    if (_status == null) {
      setState(() {
        _status = false;
        _isLoading = false;
      });
    }
  }

  // Implimentation of EmailJS REST APIs to send the email to the parents and the police department in case a match is found.
  Future sendingEmailToParents({
    @required String nameOfChildFoundAfterScan,
    @required String nameOfPersonWhoFoundChild,
    @required String emailOfPersonWhoFoundChild,
    @required String phoneNoOfPersonWhoFoundChild,
    @required String imageOfChildFoundAfterScan,
    @required String latitudeOfChildFoundAfterScan,
    @required String longitudeOfChildFoundAfterScan,
    @required String emailIdOfParents,
    @required String emailOfPolice,
    @required String phoneOfParent,
    @required String addressOfParent,
  }) async {
    const serviceId = 'service_rvmrr4t';
    const templateId = 'template_md24rwc';
    const userId = 'CJIIIS2QfQbggLeyY';
    final urlEmail = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    await http.post(urlEmail,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'template_params': {
            'nameOfChildFoundAfterScan': nameOfChildFoundAfterScan,
            'nameOfPersonWhoFoundChild': nameOfPersonWhoFoundChild,
            'emailOfPersonWhoFoundChild': emailOfPersonWhoFoundChild,
            'phoneNoOfPersonWhoFoundChild': phoneNoOfPersonWhoFoundChild,
            'imageOfChildFoundAfterScan': imageOfChildFoundAfterScan,
            'latitudeOfChildFoundAfterScan': latitudeOfChildFoundAfterScan,
            'longitudeOfChildFoundAfterScan': longitudeOfChildFoundAfterScan,
            'emailIdOfParents': emailIdOfParents,
            'emailOfPolice': emailOfPolice,
            'phoneOfParent': phoneOfParent,
            'addressOfParent': addressOfParent,
          },
          'accessToken': 'S8l-ZkhzOuYQEa6qwkhe1',
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId
        }));
  }

  // Method to fetch user data.
  Future<String> userDataScanner(String querry) async {
    final dataBaseOfUser =
        Firestore.instance.collection('Users').document(widget.id);
    final docsOfUser = await dataBaseOfUser.get();
    return docsOfUser[querry];
  }

  // Alternate method to fetch user data through streambuilder.
  Widget extracter(String querry) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('Users')
            .document(widget.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          var userDocument = snapshot.data;
          return Text(userDocument[querry]);
        });
  }

  // Our main build function for our current StatefulWidget class.
  @override
  Widget build(BuildContext context) {
    _getUserLocation();
    return Scaffold(
      backgroundColor: Colors.lime[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
            FirebaseAuth.instance.signOut();
          },
        ),
        title: Row(children: [
          const Text('Welcome'),
          const SizedBox(width: 5),
          extracter(name),
        ]),
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: MediaQuery.of(context).size.width,
          color: Colors.lime[50],
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.01),
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.25,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: MediaQuery.of(context).size.height * 0.002,
                          color: Colors.grey)),
                  alignment: Alignment.center,
                  child: _storedImage != null
                      ? Image.file(_storedImage,
                          fit: BoxFit.cover, width: double.infinity)
                      : const Text(
                          'No Image Taken',
                          textAlign: TextAlign.center,
                        ),
                ),
                _storedImage != null
                    ? const SizedBox()
                    : (_status != null
                        ? const SizedBox()
                        : (_isLoading
                            ? const SizedBox()
                            : ElevatedButton.icon(
                                onPressed: _takePicture,
                                label: const Text('Take Picture'),
                                icon: const Icon(Icons.camera),
                              )))
              ],
            ),
            _status == null
                ? const SizedBox()
                : (_status
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(20),
                              right: Radius.circular(20)),
                          color: const Color.fromARGB(255, 194, 242, 196),
                        ),
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.025),
                        child: const Text('Match Found',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 20)))
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(20),
                              right: Radius.circular(20)),
                          color: const Color.fromARGB(255, 242, 196, 194),
                        ),
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.025),
                        child: const Text(
                          'Match Not Found',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 20),
                        ))),
            FittedBox(
              child: Card(
                  elevation: _status == null ? 0 : 5,
                  margin: const EdgeInsets.all(10),
                  color: _status == null ? Colors.lime[50] : Colors.lime[100],
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(children: <Widget>[
                      _storedImage != null
                          ? (_isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                )
                              : (_status != null
                                  ? const SizedBox()
                                  : ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[300],),
                                      
                                      onPressed: runSearch,
                                      child: const Text('Scan Face'))))
                          : const SizedBox(),
                      _status == null
                          ? const SizedBox()
                          : SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                      _status == null
                          ? const SizedBox()
                          : (_status
                              ? Row(children: [
                                  Container(
                                    width: MediaQuery.of(context).size.height *
                                        0.25,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.002,
                                            color: Colors.black)),
                                    alignment: Alignment.center,
                                    child: Column(children: [
                                      Image.network(
                                          foundChildDatabaseAfterScan['Image'],
                                          fit: BoxFit.cover,
                                          width: double.infinity),
                                      const Text('Reported Image')
                                    ]),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.025,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.01),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text('Name of Child: ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red[600])),
                                            Text('Parent\'s Contact: ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red[600])),
                                            Text('Parent\'s Address: ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red[600])),
                                            Text('Parent\'s Email: ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red[600])),
                                            Text('Police\'s Email: ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red[600])),
                                          ])),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.025,
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          right: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.01),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${foundChildDatabaseAfterScan['Child Name']}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                                '${foundChildDatabaseAfterScan['Parent Phone']}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                '${foundChildDatabaseAfterScan['Parent Address']}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                '${foundChildDatabaseAfterScan['Parent Email']}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                '${foundChildDatabaseAfterScan['Police Email']}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ]))
                                ])
                              : const SizedBox())
                    ]),
                  )),
            )
          ])),
    );
  }
}
