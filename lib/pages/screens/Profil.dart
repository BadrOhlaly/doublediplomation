import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> saveAddressToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;

        Map<String, dynamic> data = {
          "address": addressController.text,
          "postalCode": postalCodeController.text,
          "city": cityController.text,
          "birthday": selectedDate,
        };

        await FirebaseFirestore.instance.collection("users").doc(uid).set(data);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Address saved successfully'),
          duration: Duration(seconds: 2),
        ));

        // Clear the form fields after saving
        addressController.clear();
        postalCodeController.clear();
        cityController.clear();
        setState(() {
          selectedDate = null;
        });
      }
    } catch (e) {
      print("Error saving address to Firestore: $e");
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Add Address:",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: addressController,
                            decoration: InputDecoration(labelText: 'Address'),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: postalCodeController,
                            decoration:
                                InputDecoration(labelText: 'Postal Code'),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: cityController,
                            decoration: InputDecoration(labelText: 'City'),
                          ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: TextEditingController(
                                  text: selectedDate != null
                                      ? "${selectedDate!.toLocal()}"
                                          .split(' ')[0]
                                      : '',
                                ),
                                decoration:
                                    InputDecoration(labelText: 'Birthday'),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              saveAddressToFirestore();
                            },
                            child: Text("Save Address"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    child: Text("Logout"),
                  ),
                ],
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
    // You can customize the sign-in screen UI here
    return Center(
      child: Text("Sign In Screen"),
    );
  }
}
