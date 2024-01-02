import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tflite_v2/tflite_v2.dart';

class Ajout extends StatefulWidget {
  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<Ajout> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  TextEditingController imageController = TextEditingController();

  XFile? _image;
  File? file;

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = image;
        file = File(image!.path);
        imageController.text = _image?.path ?? '';
      });
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> getImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  void clearFields() {
    titleController.clear();
    placeController.clear();
    priceController.clear();
    categoryController.clear();
    imageController.clear();
    setState(() {
      _image = null;
      file = null;
    });
  }

  Future<void> uploadFile() async {
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("images/${DateTime.now().millisecondsSinceEpoch}.jpg");

      TaskSnapshot taskSnapshot = await storageReference.putFile(File(_image!.path));

      String photoUrl = await taskSnapshot.ref.getDownloadURL();

      Map<String, dynamic> data = {
        "lieu": placeController.text,
        "categorie": categoryController.text,
        "prix": int.parse(priceController.text),
        "titre": titleController.text,
        "image": photoUrl,
      };

      await FirebaseFirestore.instance.collection("activite").add(data);

      clearFields();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Activité enregistrée avec succès'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      print("Error during file upload: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Add Activity"),
              ),
              body: SingleChildScrollView( // Wrap with SingleChildScrollView
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        "Add Activity:",
                        style:
                            TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton.icon(
                                onPressed: getImageFromGallery,
                                icon: Icon(Icons.image),
                                label: Text("Pick an Image"),
                              ),
                              SizedBox(height: 10),
                              _image != null
                                  ? Image.file(
                                      File(_image!.path),
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: titleController,
                                decoration: InputDecoration(labelText: 'Title'),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: placeController,
                                keyboardType: TextInputType.number, // Use TextInputType.number for a number keyboard
                                decoration: InputDecoration(labelText: 'Place'),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: priceController,
                                keyboardType: TextInputType.number, // Use TextInputType.number for a number keyboard
                                decoration: InputDecoration(labelText: 'Price'),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: categoryController,
                                decoration:
                                    InputDecoration(labelText: 'Category'),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  uploadFile();
                                },
                                child: Text("Add Activity"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return SignInScreen();
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Sign In Screen"),
    );
  }
}
