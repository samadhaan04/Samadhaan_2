import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faridabad/widgets/modalSheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileComplaint extends StatefulWidget {
  static const routeName = 'file-complaint';

  @override
  _FileComplaintState createState() => _FileComplaintState();
}

class _FileComplaintState extends State<FileComplaint>
    with SingleTickerProviderStateMixin {
  final databaseReference = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  bool isupdate = false;
  double width, height;
  bool loading = false;
  SharedPreferences pref;
  callback(bool value) {
    setState(() {
      loading = value;
    });
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  TextEditingController _detailsController = new TextEditingController();
  TextEditingController _subjectController = new TextEditingController();
  String _department;
  List _images = [];
  var urls = [];
  File _image;
  final List<String> depts = [
    "None",
    "Animal Husbandry",
    "BDPO",
    "Civil Hospital",
    "DHBVN(Urban)",
    "DHBVN(Rural)",
    "Distt. Town planner ",
    "Education(Elementary)",
    "Education(Higher)",
    "Fire Department",
    "HVPNL",
    "Irrigation",
    "Nagar Parishad",
    "PWD",
    "PUBLIC HEALTH(Water)",
    "Public health(Sewage)",
    "Public health (Reny Well)",
    "Social Welfare",
    "Tehsil"
  ];

  void showModalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ModalSheet();
      },
    );
  }

  @override
  void initState() {
    super.initState();

    fetchCity();
  }

  @override
  void didChangeDependencies() {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    fetchCity();
    super.didChangeDependencies();
  }

  var city;
  void fetchCity() async {
    pref = await SharedPreferences.getInstance();
    setState(() {
      city = pref.getString('city');
    });
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(15),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'File ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                        Text(
                          'Complaint',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.teal[200]),
                        ),
                      ],
                    ),
                  ),
                  // TO BE DONE: Render a custom image from backend
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    city ?? "empty",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      letterSpacing: 1,
                      color: Colors.blue[300],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    width: double.infinity,
                    height: height / 1.6,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            width: double.infinity,
                            // child: DropdownButton(
                            //   style: TextStyle(
                            //     fontSize: 21,
                            //   ),
                            //   // dropdownColor: Colors.red,
                            //   hint: Text(
                            //     'Select Department ',
                            //     style: TextStyle(
                            //       color: Colors.black54,
                            //     ),
                            //   ), // Not necessary for Option 1
                            //   value: _department,
                            //   isExpanded: true,
                            //   underline: Container(
                            //     color: Colors.black45,
                            //     child: Divider(
                            //       thickness: 1,
                            //       height: 1,
                            //     ),
                            //   ),
                            //   onChanged: (newValue) {
                            //     setState(() {
                            //       _department = newValue;
                            //     });
                            //   },
                            //   items: depts.map((location) {
                            //     return DropdownMenuItem(
                            //       child: new Text(
                            //         location,
                            //         style: TextStyle(color: Colors.black54),
                            //       ),
                            //       value: location,
                            //     );
                            //   }).toList(),
                            // ),
                            child: GestureDetector(
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    border: BorderDirectional(
                                        bottom:
                                            BorderSide(color: Colors.black54))),
                                child: Row(
                                  children: [
                                    Text(
                                      _department == null ? 
                                      "Select Department" : _department,
                                      style: TextStyle(
                                        fontSize: 21,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                              onTap: () => showModal(context),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: _subjectController,
                            keyboardType: TextInputType.text,
                            autocorrect: false,
                            maxLines: null,
                            validator: (value) {
                              if (value.isEmpty || value.length < 1) {
                                return 'Please enter Subject';
                              } else if (value.length > 150) {
                                return "Subject should Be less than 150 Words";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(5),
                              hintText: "Subject",
                            ),
                            style: TextStyle(
                              fontSize: 21,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              autocorrect: false,
                              controller: _detailsController,
                              maxLines: null,
                              validator: (value) {
                                if (value.isEmpty || value.length < 1) {
                                  return 'Please enter details about your issue';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(5),
                                hintText: "Complaint",
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontSize: 21,
                                color: Colors.black,
                              ),
                              minLines: 1,
                              // maxLines: 100,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              (_images.length == 0)
                                  ? Expanded(
                                      child: Container(),
                                    )
                                  : Expanded(
                                      child: SizedBox(
                                        height: 60,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          key: GlobalKey(),
                                          itemCount: _images.length,
                                          itemBuilder: (context, index) {
                                            return Row(
                                              children: [
                                                preview(_images[index]),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                              IconButton(
                                icon: Icon(
                                  Icons.photo_camera,
                                  size: 30,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    child: AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      title: Text(
                                        "Choose an Option",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      actions: <Widget>[
                                        MaterialButton(
                                          child: Text(
                                            "Gallery",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () async {
                                            final picker = ImagePicker();
                                            final pickedImage =
                                                await picker.getImage(
                                                    source: ImageSource.gallery,
                                                    imageQuality: 60,
                                                    maxWidth: 150);
                                            setState(() {
                                              _image = File(pickedImage.path);
                                              _images.add(_image);
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        MaterialButton(
                                          child: Text(
                                            "Camera",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () async {
                                            final picker = ImagePicker();
                                            final pickedImage =
                                                await picker.getImage(
                                                    source: ImageSource.camera,
                                                    imageQuality: 60,
                                                    maxWidth: 150);
                                            setState(() {
                                              _image = File(pickedImage.path);
                                              _images.add(_image);
                                              print(_images);
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  GestureDetector(
                    child: Container(
                      height: 70,
                      alignment: Alignment.center,
                      width: width / 2,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: loading
                          ? CircularProgressIndicator()
                          : Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 30,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                    onTap: () async {
                      {
                        setState(() {
                          loading = true;
                        });

                        if (_department == null ||
                            _detailsController.text == null ||
                            _subjectController.text == null) {
                          setState(() {
                            loading = false;
                          });
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                'Please Enter Your Details',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          // responeTimer();
                          bool result = await checkInternet();
                          if (!result) {
                            print('result checked $result');
                            setState(() {
                              loading = false;
                            });
                            showDialog(
                                context: context,
                                child: AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  title: Text(
                                    "TRY AGAIN",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: Text(
                                      "Please Check Your Internet Connection"),
                                  actions: <Widget>[
                                    MaterialButton(
                                      child: Text(
                                        "RETRY",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                ));
                          } else {
                            final result = await sendData();
                            if (result == true) {
                              print("work done!!");
                              Navigator.of(context).pop();
                            }
                          }
                          setState(() {
                            loading = false;
                          });
                          showModalSheet(context);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget preview(File image) {
    return Stack(
      overflow: Overflow.visible,
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: GestureDetector(
            child: Image.file(image),
            onTap: () {
              showDialog(
                context: context,
                child: AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Image.file(image),
                  actions: [
                    FlatButton(
                      padding: EdgeInsets.all(10),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Okay!"),
                    )
                  ],
                ),
              );
            },
          ),
        ),
        Positioned(
          top: -5,
          right: -5,
          child: CircleAvatar(
            radius: 10,
            backgroundColor: Colors.black,
            child: GestureDetector(
              child: Icon(
                Icons.clear,
                color: Colors.white,
                size: 20,
              ),
              onTap: () {
                _images.removeWhere((element) {
                  return element == image;
                });
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }

  // Future<bool> storeImages() async
  // {
  //   try {
  //     final uid = await _auth.currentUser().then((value) => value.uid);
  //     if (_images.length != 0) {
  //       _images.forEach((element) async {
  //         final ref2 = FirebaseStorage.instance
  //             .ref()
  //             .child('complaintImages')
  //             .child(uid + DateTime.now().toIso8601String() + '.jpg');
  //         await ref2.putFile(_image).onComplete;
  //         var url = await ref2.getDownloadURL();
  //         print(url);
  //         urls.add(url);
  //       });
  //     }
  //     return true;
  //   }
  //   catch(e) {
  //     return false;
  //   }
  // }

  void responeTimer() async {
    print('timer fired');
    await Future.delayed(Duration(seconds: 10))
        .then((value) => callback(false));
  }

  Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }
    return false;
  }

  Future<bool> sendData() async {
    try {
      final uid = await _auth.currentUser().then((value) => value.uid);
      if (_images.length != 0) {
        _images.forEach((element) async {
          final ref2 = FirebaseStorage.instance
              .ref()
              .child('complaintImages')
              .child(uid + DateTime.now().toIso8601String() + '.jpg');
          await ref2.putFile(_image).onComplete;
          var url = await ref2.getDownloadURL();
          print(url);
          urls.add(url);
        });
      }
      print(urls);
      DocumentReference ref =
          await databaseReference.collection("Complaints").add({
        'author': uid,
        'complaintText': _detailsController.text,
        'imageURL': _images.length == 0 ? null : urls,
        'state': "Haryana",
        'subject': _subjectController.text,
        'status': 0,
        'name': pref.getString('name'),
        'city': "Palwal",
        'department': _department,
        'deptFeedback': null,
        'userFeedback': null,
        'deptFeedbackImg': null,
        'adminRemark': null,
        'star': null,
        'date': DateTime.now().toIso8601String(),
        'token': pref.getString('token'),
      });
      print("start check");
      await databaseReference
          .collection("Users/$uid/previousComplaints")
          .add({"ref": ref.path});
      print(ref.path);
      int length;
      try {
        length = await databaseReference
            .collection("States/Haryana/Palwal")
            .document(_department)
            .get()
            .then((value) => value.data['p']);
      } catch (e) {
        await databaseReference
            .collection("States/Haryana/Palwal")
            .document(_department)
            .setData({"p": 1});
        length = 0;
      }
      if (length != 0) {
        await databaseReference
            .collection("States/Haryana/Palwal")
            .document(_department)
            .setData({"p": length + 1});
      }

      await databaseReference
          // .collection("States/Haryana/Palwal")
          .document('States/Haryana/Palwal/$_department')
          // .document(_department)
          .collection('Complaints')
          .add({
        'ref': ref.path,
        'subject': _subjectController.text,
        'status': 0,
        // .document()
        // .setData({
        // 'ref': ref.path,
      }).then((value) {
        print("Success");
        return true;
      });
      return true;
    } catch (e) {
      print(e);
      print('please try again');
      return false;
    }
  }

  void showModal(context) {
    showModalBottomSheet(
        isScrollControlled: false,
        backgroundColor: Colors.white,
        context: context,
        builder: (context) {
          return Container(
            height: 300,
            child: Column(
              children: [
                Container(
                  child: FlatButton(
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Done",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.blueAccent,
                      ),
                    ),
                    shape: CircleBorder(
                        side: BorderSide(
                      color: Colors.transparent,
                    )),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    magnification: 1.5,
                    diameterRatio: 100.0,
                    scrollController:
                        FixedExtentScrollController(initialItem: 5),
                    backgroundColor: Color(0xffd0d5da),
                    children: List<Widget>.generate(
                      depts.length,
                      (index) => Center(
                        child: Text(
                          depts[index],
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    itemExtent: 50, //height of each item
                    looping: false,
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        _department = depts[index];
                        print(_department);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}
