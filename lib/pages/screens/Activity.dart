import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Activity extends StatefulWidget {
  @override
  _ActivityState createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  int _selectedIndex = 0;
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List of Activities"),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.active) {
            final user = userSnapshot.data;
            if (user != null) {
              return Column(
                children: [
                  BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.list),
                        label: 'All',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.sports),
                        label: 'Sport',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_cart),
                        label: 'Shopping',
                      ),
                    ],
                    currentIndex: _selectedIndex,
                    selectedItemColor: Colors.blue,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('activite')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          print('Error: ${snapshot.error}');
                          return Text('Error fetching data');
                        }

                        List<ActivityItem> activities = snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          return ActivityItem(
                            title: data['titre'],
                            imageUrl: data['image'] ??
                                'DEFAULT_IMAGE_URL', // Provide a default image URL or handle this case
                            place: data['lieu'],
                            price: data['prix'].toString(),
                            category: data['categorie'],
                          );
                        }).toList();

                        List<ActivityItem> filteredActivities = [];
                        if (_selectedIndex == 0) {
                          filteredActivities = activities; // All
                        } else {
                          String selectedCategory =
                              _selectedIndex == 1 ? "Sport" : "Shopping";
                          filteredActivities = activities
                              .where((activity) =>
                                  activity.category.toLowerCase() ==
                                  selectedCategory.toLowerCase())
                              .toList();
                        }

                        return ListView.builder(
                          itemCount: filteredActivities.length,
                          itemBuilder: (context, index) {
                            return ActivityCard(
                                activity: filteredActivities[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return SignInScreen();
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
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

class ActivityItem {
  final String title;
  final String imageUrl;
  final String place;
  final String price;
  final String category;

  ActivityItem({
    required this.title,
    required this.imageUrl,
    required this.place,
    required this.price,
    required this.category,
  });
}

class ActivityCard extends StatelessWidget {
  final ActivityItem activity;

  ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      elevation: 5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image on the left
          Container(
            width: 150,
            height: 150,
            child: Image.network(
              activity.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          // Information on the right
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text("Place: ${activity.place}"),
                  Text("Price: ${activity.price}"),
                  Text("Category: ${activity.category}"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
