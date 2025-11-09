import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importing screens for navigation
import 'courseScreens/cprogramming.dart';
import 'courseScreens/java.dart';
import 'courseScreens/htmlcss.dart';
import 'package:w3cst/screens/courseScreens/database.dart';
import 'courseScreens/webdevelopment.dart';
import 'courseScreens/Restofthecourses.dart';

class courseScreen extends StatefulWidget {
  const courseScreen({super.key});

  @override
  State<courseScreen> createState() => _courseScreenState();
}

class _courseScreenState extends State<courseScreen> {
  List<Map<String, dynamic>> allRequests = [];
  @override
  void initState() {
    super.initState();
    loadRequest();
    loadBookmarks();
  }

  Future<Map<String, dynamic>> loadProgress(String courseName) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final docSnapshot = await userDoc.get();

    final coursesProgress = List<Map<String, dynamic>>.from(
      docSnapshot.data()?['coursesProgress'] ?? [],
    );

    final courseIndex = coursesProgress.indexWhere(
      (p) => p['title'].toLowerCase() == courseName.toLowerCase(),
    );

    int completed = 0;
    int total = 0;
    double percentage = 0.0;

    if (courseIndex != -1) {
      final courseData = coursesProgress[courseIndex];

      // Load finished list if available
      final finishedList = List<bool>.from(courseData['contentfinished'] ?? []);

      // Try reading saved progress (if stored)
      final progressData = Map<String, dynamic>.from(
        courseData['progress'] ?? {},
      );

      completed =
          progressData['completed'] ?? finishedList.where((e) => e).length;
      total = progressData['total'] ?? finishedList.length;

      if (total > 0) {
        percentage = (completed / total) * 100;
      } else {
        percentage =
            double.tryParse(progressData['percentage']?.toString() ?? '0') ?? 0;
      }

      debugPrint(
        "Loaded progress for $courseName: $completed/$total ($percentage%)",
      );
    } else {
      debugPrint("No saved progress found for $courseName");
    }

    return {'completed': completed, 'total': total, 'percentage': percentage};
  }

  final TextEditingController coursetitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> loadRequest() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference requestsRef = firestore.collection('ApprovedCourses');

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    final currentuserId = user.uid;

    QuerySnapshot querySnapshot = await requestsRef.get();

    List<Map<String, dynamic>> tempList = [];

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
    setState(() {
      allRequests = tempList;
    });
  }

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

  Map<String, bool> bookmarkedCourses = {};

  Future<void> loadBookmarks() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance.collection("users").doc(userId);

    final snapshot = await docRef.get();
    final bookmarks = List<String>.from(snapshot.data()?['bookmarks'] ?? []);

    for (var bookmark in bookmarks) {
      bookmarkedCourses[bookmark] = true;
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const CProgrammingScreen(
                            courseName: 'C Programming',
                          ),
                    ),
                  );
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
                            Row(
                              children: [
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
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  onPressed:
                                      () => toggleBookmark('C Programming'),
                                  icon: Icon(
                                    bookmarkedCourses['C Programming'] == true
                                        ? Icons.bookmark
                                        : Icons.bookmark_border_outlined,
                                    size: 25,
                                    color:
                                        bookmarkedCourses['C Programming'] ==
                                                true
                                            ? Colors.green
                                            : Colors.grey,
                                  ),
                                ),
                              ],
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const javaScreen(courseName: 'java'),
                    ),
                  );
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
                            Row(
                              children: [
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
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  onPressed:
                                      () => toggleBookmark('Java Basics'),
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const htmlcssScreen(courseName: 'HTML&CSS'),
                    ),
                  );
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
                              'HTML & CSS',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
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
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  onPressed: () => toggleBookmark('HTML&CSS'),
                                  icon: Icon(
                                    bookmarkedCourses['HTML&CSS'] == true
                                        ? Icons.bookmark
                                        : Icons.bookmark_border_outlined,
                                    size: 25,
                                    color:
                                        bookmarkedCourses['HTML&CSS'] == true
                                            ? Colors.green
                                            : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Welcome to HTML Basics Tutorial HTML stands for HyperText Markup Language. It’s the standard language for creating web pages. With HTML, you structure content like headings, paragraphs, links, images, and more on a website.",
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const databaseScreen(
                            courseName: 'Database Management',
                          ),
                    ),
                  );
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
                              'Database Management',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
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
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  onPressed: () => toggleBookmark('Database'),
                                  icon: Icon(
                                    bookmarkedCourses['Database'] == true
                                        ? Icons.bookmark
                                        : Icons.bookmark_border_outlined,
                                    size: 25,
                                    color:
                                        bookmarkedCourses['Database'] == true
                                            ? Colors.green
                                            : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Welcome to Database Management Systems (DBMS).A database is a structured collection of data, and a DBMS is software used to store, manage, and retrieve that data efficiently.",
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const webdevelopmentScreen(
                            courseName: 'Web Development',
                          ),
                    ),
                  );
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
                            Row(
                              children: [
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
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  onPressed:
                                      () => toggleBookmark('Web Development'),
                                  icon: Icon(
                                    bookmarkedCourses['Web Development'] == true
                                        ? Icons.bookmark
                                        : Icons.bookmark_border_outlined,
                                    size: 25,
                                    color:
                                        bookmarkedCourses['Web Development'] ==
                                                true
                                            ? Colors.green
                                            : Colors.grey,
                                  ),
                                ),
                              ],
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
              allRequests.isEmpty
                  ? const Center(child: Text('No requests yet'))
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allRequests.length,
                    itemBuilder: (context, index) {
                      final request = allRequests[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => restofthecourseScreen(
                                    courseName: request['title'],
                                    canEdit:
                                        (request['currentuserId'] ==
                                                request['userId'])
                                            ? true
                                            : false,
                                  ),
                            ),
                          );
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.blueAccent,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.data_array,
                                        size: 25,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    Text(
                                      request['title'],
                                      style: TextStyle(
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
                                            icon: Icon(Icons.edit_outlined),
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
                                SizedBox(height: 20),
                                Text(
                                  request['description'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
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
                      );
                    },
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
