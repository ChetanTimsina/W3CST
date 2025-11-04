import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class cprogrammingScreen extends StatefulWidget {
  const cprogrammingScreen({super.key});

  @override
  State<cprogrammingScreen> createState() => _cprogrammingScreenState();
}

class _cprogrammingScreenState extends State<cprogrammingScreen> {
  List<Map<String, dynamic>> allcourses = [];
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference courses = firestore.collection('DefaultCourses');
    CollectionReference courses2 = firestore.collection('ApprovedCourses');
    QuerySnapshot querySnapshot = await courses.get();
    QuerySnapshot querySnapshot2 = await courses2.get();

    List<Map<String, dynamic>> tempList = [];
    List<Map<String, dynamic>> tempList2 = [];

    for (var doc in querySnapshot.docs) {
      final userId = doc.id;
      final data = doc.data() as Map<String, dynamic>;
      final courses = List<Map<String, dynamic>>.from(data['courses'] ?? []);
      for (var course in courses) {
        tempList.add({
          'userId': userId,
          'title': course['title'],
          'description': course['description'],
          'content': List.from(course['content'] ?? []),
        });
      }
    }
    for (var doc in querySnapshot2.docs) {
      final userId = doc.id;
      final data = doc.data() as Map<String, dynamic>;
      final courses = List<Map<String, dynamic>>.from(data['courses'] ?? []);
      for (var course in courses) {
        tempList2.add({
          'userId': userId,
          'title': course['title'],
          'description': course['description'],
          'content': List.from(course['content'] ?? []),
        });
      }
    }
    setState(() {
      allcourses = tempList + tempList2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('C Programming'),
        backgroundColor: const Color.fromARGB(255, 3, 62, 91),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            allcourses.isEmpty
                ? const Center(child: Text('No courses available'))
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allcourses.length,
                  itemBuilder: (context, index) {
                    final course = allcourses[index];
                    if (course['title']
                        .toString()
                        .toLowerCase()
                        .trim()
                        .contains('c programming')) {
                      return SingleChildScrollView(
                        child: Card(
                          margin: const EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      course['title'] ?? 'No Title',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  course['description'] ?? 'No Description',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 10),
                                ...List<Widget>.from(
                                  (course['content'] as List<dynamic>? ?? [])
                                      .map(
                                        (content) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10.0,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                255,
                                                255,
                                                255,
                                                255,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color.fromARGB(
                                                    255,
                                                    3,
                                                    62,
                                                    91,
                                                  ),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  10.0,
                                                ),
                                                child: Text(
                                                  content ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
          ],
        ),
      ),
    );
  }
}
