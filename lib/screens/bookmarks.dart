import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:w3cst/screens/courseScreens/defaultstyle.dart';
import 'courseScreens/Restofthecourses.dart';

class bookmarkScreen extends StatefulWidget {
  const bookmarkScreen({super.key});

  @override
  State<bookmarkScreen> createState() => _bookmarkScreenState();
}

class _bookmarkScreenState extends State<bookmarkScreen> {
  List<Map<String, dynamic>> allRequests = [];

  @override
  void initState() {
    super.initState();
    loadBookmarks();
    loadRequest();
  }

  Future<void> loadRequest() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference requestsRef = firestore.collection('ApprovedCourses');
    CollectionReference requestsRef2 = firestore.collection('DefaultCourses');

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    final currentuserId = user.uid;
    QuerySnapshot querySnapshot = await requestsRef.get();
    QuerySnapshot querySnapshot2 = await requestsRef2.get();

    List<Map<String, dynamic>> tempList = [];
    List<Map<String, dynamic>> tempList2 = [];

    for (var doc in querySnapshot.docs) {
      final userId = doc.id;
      final data = doc.data() as Map<String, dynamic>;
      final courses = List<Map<String, dynamic>>.from(data['courses'] ?? []);
      for (var course in courses) {
        tempList.add({
          'currentuserId': currentuserId,
          'userId': userId,
          'title': course['title'],
          'description': course['description'],
          'createdAt': course['createdAt'],
        });
      }
    }

    for (var doc in querySnapshot2.docs) {
      final userId = doc.id;
      final data = doc.data() as Map<String, dynamic>;
      final courses = List<Map<String, dynamic>>.from(data['courses'] ?? []);
      for (var course in courses) {
        tempList2.add({
          'currentuserId': currentuserId,
          'userId': userId,
          'title': course['title'],
          'description': course['description'],
          'createdAt': course['createdAt'],
        });
      }
    }

    setState(() {
      allRequests = tempList2 + tempList;
    });
  }

  Map<String, bool> bookmarkedCourses = {};

  Future<void> loadBookmarks() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance.collection("users").doc(userId);
    final snapshot = await docRef.get();
    final bookmarks = List<String>.from(snapshot.data()?['bookmarks'] ?? []);
    setState(() {
      for (var bookmark in bookmarks) {
        bookmarkedCourses[bookmark] = true;
      }
    });
  }

  Future<void> toggleBookmark(String courseName) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await docRef.get();
    final bookmarks = List<String>.from(snapshot.data()?['bookmarks'] ?? []);
    bool isBookmarked = bookmarks.contains(courseName);

    if (isBookmarked) {
      await docRef.update({
        'bookmarks': FieldValue.arrayRemove([courseName]),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$courseName removed from bookmarks')),
      );
    } else {
      await docRef.set({
        'bookmarks': FieldValue.arrayUnion([courseName]),
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$courseName added to bookmarks')));
    }

    setState(() {
      bookmarkedCourses[courseName] = !isBookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('bookmark'),
        backgroundColor: const Color.fromARGB(255, 3, 62, 91),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body:
          allRequests.isEmpty
              ? const Center(child: Text('No requests yet'))
              : SingleChildScrollView(
                child: Column(
                  children:
                      allRequests.map((request) {
                        if (bookmarkedCourses[request['title']] != true) {
                          return const SizedBox.shrink();
                        }
                        final lowerTitle = request['title'].toLowerCase();
                        final defaultCourses = [
                          "c programming",
                          "java basics",
                          "web development",
                          "html&css",
                          "database management",
                        ];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        defaultCourses.contains(lowerTitle)
                                            ? defaultstyleScreen(
                                              courseName: request['title'],
                                            )
                                            : restofthecourseScreen(
                                              courseName: request['title'],
                                              canEdit:
                                                  (request['currentuserId'] ==
                                                      request['userId']),
                                            ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blueAccent,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.data_array,
                                          size: 25,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      Text(
                                        request['title'],
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          if (request['currentuserId'] ==
                                              request['userId'])
                                            IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                              ),
                                            ),
                                          if (defaultCourses.contains(
                                            lowerTitle,
                                          ))
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(),
                                              onPressed: () {},
                                              icon: Icon(
                                                Icons.workspace_premium,
                                                color: Colors.amber,
                                              ),
                                            ),
                                          IconButton(
                                            onPressed:
                                                () => toggleBookmark(
                                                  request['title'],
                                                ),
                                            icon: Icon(
                                              bookmarkedCourses[request['title']] ==
                                                      true
                                                  ? Icons.bookmark
                                                  : Icons
                                                      .bookmark_border_outlined,
                                              size: 25,
                                              color:
                                                  bookmarkedCourses[request['title']] ==
                                                          true
                                                      ? Colors.green
                                                      : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    request['description'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const LinearProgressIndicator(
                                    value: 0.7,
                                    color: Colors.amber,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
    );
  }
}
