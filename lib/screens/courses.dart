import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class courseScreen extends StatefulWidget {
  const courseScreen({super.key});

  @override
  State<courseScreen> createState() => _courseScreenState();
}

class _courseScreenState extends State<courseScreen> {
  final TextEditingController coursetitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> sendToAdmin() async {
    final coursetitle = coursetitleController.text.trim();
    final description = descriptionController.text.trim();

    if (coursetitle.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in")));
        return;
      }

      final userId = user.uid;

      Map<String, dynamic> courseData = {
        'title': coursetitle,
        'description': description,
        'createdAt': DateTime.now().toIso8601String(),
      };

      DocumentReference userDoc = FirebaseFirestore.instance
          .collection('adminApproval')
          .doc(userId);

      await userDoc.set({
        'courses': FieldValue.arrayUnion([courseData]),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Course sent for admin approval")),
      );

      coursetitleController.clear();
      descriptionController.clear();
    } catch (e) {
      print('Error saving course: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
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

  Map<String, bool> bookmarkedCourses = {
    'C Programming': false,
    'Java Basics': false,
    'Web Development': false,
    'Database Management': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course'),
        backgroundColor: const Color.fromARGB(255, 3, 62, 91),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  print('C Programming Tapped');
                },
                child: Container(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.code,
                                size: 25,
                                color: Colors.blueAccent,
                              ),
                            ),
                            Text(
                              'C Programming',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => toggleBookmark('C Programming'),
                              icon: Icon(
                                bookmarkedCourses['C Programming'] == true
                                    ? Icons.bookmark
                                    : Icons.bookmark_border_outlined,
                                size: 25,
                                color:
                                    bookmarkedCourses['C Programming'] == true
                                        ? Colors.green
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Master the fundamentals of C programming, a powerful language for system-level development and competitive programming. Learn syntax, data structures, and algorithms.",
                        ),
                        SizedBox(height: 20),
                        LinearProgressIndicator(
                          value: 0.7,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  print('Java Basics Tapped');
                },
                child: Container(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.format_align_justify_sharp,
                                size: 25,
                                color: Colors.blueAccent,
                              ),
                            ),
                            Text(
                              'Java Basics',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => toggleBookmark('Java Basics'),
                              icon: Icon(
                                bookmarkedCourses['Java Basics'] == true
                                    ? Icons.bookmark
                                    : Icons.bookmark_border_outlined,
                                size: 25,
                                color:
                                    bookmarkedCourses['Java Basics'] == true
                                        ? Colors.green
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Get started with Java, an object-oriented language essential for Android app development and enterprise systems. Explore core concepts and practical applications.",
                        ),
                        SizedBox(height: 20),
                        LinearProgressIndicator(
                          value: 0.7,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  print('Web Development Tapped');
                },
                child: Container(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.web,
                                size: 25,
                                color: Colors.blueAccent,
                              ),
                            ),
                            Text(
                              'Web Development',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed:
                                  () => toggleBookmark('Web Development'),
                              icon: Icon(
                                bookmarkedCourses['Web Development'] == true
                                    ? Icons.bookmark
                                    : Icons.bookmark_border_outlined,
                                size: 25,
                                color:
                                    bookmarkedCourses['Web Development'] == true
                                        ? Colors.green
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Dive into modern web development. Learn HTML5, CSS3, and JavaScript to build responsive and interactive websites. Includes front-end frameworks introduction.",
                        ),
                        SizedBox(height: 20),
                        LinearProgressIndicator(
                          value: 0.7,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  print('Database Management Tapped');
                },
                child: Container(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.data_array,
                                size: 25,
                                color: Colors.blueAccent,
                              ),
                            ),
                            Text(
                              'Database Management',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed:
                                  () => toggleBookmark('Database Management'),
                              icon: Icon(
                                bookmarkedCourses['Database Management'] == true
                                    ? Icons.bookmark
                                    : Icons.bookmark_border_outlined,
                                size: 25,
                                color:
                                    bookmarkedCourses['Database Management'] ==
                                            true
                                        ? Colors.green
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Understand relational databases and SQL. Design, query, and manage databases efficiently. Essential for any data-driven application development.",
                        ),
                        SizedBox(height: 20),
                        LinearProgressIndicator(
                          value: 0.7,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add New Course'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'Course Name'),
                      controller: coursetitleController,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Description'),
                      controller: descriptionController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed:
                          () => {Navigator.of(context).pop(), sendToAdmin()},
                      child: Text('Submit'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
