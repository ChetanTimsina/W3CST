import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class webdevelopmentScreen extends StatefulWidget {
  final String courseName;
  const webdevelopmentScreen({super.key, required this.courseName});

  @override
  State<webdevelopmentScreen> createState() => _webdevelopmentScreenState();
}

class _webdevelopmentScreenState extends State<webdevelopmentScreen> {
  List<Map<String, dynamic>> allcourses = [];
  final TextEditingController contenttitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ensureCoursesProgressExists().then((_) {
      loadData();
    });
  }

  Future<void> ensureCoursesProgressExists() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({'coursesProgress': []});
    } else {
      final data = docSnapshot.data() as Map<String, dynamic>;
      if (!data.containsKey('coursesProgress')) {
        await userDoc.set({'coursesProgress': []}, SetOptions(merge: true));
      }
    }
  }

  Future<void> loadData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference defaultCourses = firestore.collection('DefaultCourses');
    CollectionReference approvedCourses = firestore.collection(
      'ApprovedCourses',
    );

    QuerySnapshot querySnapshot1 = await defaultCourses.get();
    QuerySnapshot querySnapshot2 = await approvedCourses.get();

    List<Map<String, dynamic>> tempList = [];
    List<Map<String, dynamic>> tempList2 = [];

    final userDocData =
        await firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    for (var doc in querySnapshot1.docs) {
      final userId = doc.id;
      final data = doc.data() as Map<String, dynamic>;
      final courses = List<Map<String, dynamic>>.from(data['courses'] ?? []);
      for (var course in courses) {
        final contentList = (course['content'] as List<dynamic>? ?? []);
        final contentProgress =
            (userDocData['coursesProgress'] as List<dynamic>? ?? []);
        final progressForCourse = contentProgress.firstWhere(
          (p) => p['title'] == course['title'],
          orElse: () => {'contentfinished': []},
        );
        final finishedList = List<bool>.from(
          progressForCourse['contentfinished'] ?? [],
        );
        final combined =
            contentList.asMap().entries.map((entry) {
              final i = entry.key;
              final content = entry.value;
              final finished =
                  i < finishedList.length ? finishedList[i] : false;
              return {'content': content, 'finished': finished};
            }).toList();

        tempList.add({
          'userId': userId,
          'title': course['title'],
          'description': course['description'],
          'content': combined,
        });
      }
    }

    for (var doc in querySnapshot2.docs) {
      final userId = doc.id;
      final data = doc.data() as Map<String, dynamic>;
      final courses = List<Map<String, dynamic>>.from(data['courses'] ?? []);
      for (var course in courses) {
        final contentList = (course['content'] as List<dynamic>? ?? []);
        final contentProgress =
            (userDocData['coursesProgress'] as List<dynamic>? ?? []);
        final progressForCourse = contentProgress.firstWhere(
          (p) => p['title'] == course['title'],
          orElse: () => {'contentfinished': []},
        );
        final finishedList = List<bool>.from(
          progressForCourse['contentfinished'] ?? [],
        );
        final combined =
            contentList.asMap().entries.map((entry) {
              final i = entry.key;
              final content = entry.value;
              final finished =
                  i < finishedList.length ? finishedList[i] : false;
              return {'content': content, 'finished': finished};
            }).toList();

        tempList2.add({
          'userId': userId,
          'title': course['title'],
          'description': course['description'],
          'content': combined,
        });
      }
    }

    setState(() {
      print(tempList);
      print("++++++++++++++++++++++++++++++++++++");
      print(tempList2);
      print("---------------------------------------");
      print(allcourses);
      allcourses = tempList + tempList2;
    });
  }

  void addnewcontent() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference coursesRef = firestore.collection('ApprovedCourses');
    final contentTitle = contenttitleController.text.trim();

    if (contentTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    try {
      DocumentSnapshot docSnapshot = await coursesRef.doc(uid).get();
      if (!docSnapshot.exists) throw Exception("Document not found!");

      List<dynamic> courses = List.from(docSnapshot.get('courses'));
      int index = courses.indexWhere((c) => c['title'] == widget.courseName);
      if (index == -1) throw Exception("Course not found!");

      Map<String, dynamic> targetCourse = Map<String, dynamic>.from(
        courses[index],
      );

      List<dynamic> existingContent = List.from(targetCourse['content'] ?? []);
      existingContent.add(contentTitle); // <-- save string only
      targetCourse['content'] = existingContent;
      courses[index] = targetCourse;

      await coursesRef.doc(uid).update({'courses': courses});
      contenttitleController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Content added successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCourses =
        allcourses
            .where(
              (course) => course['title'].toString().toLowerCase().contains(
                widget.courseName.toLowerCase(),
              ),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Development'),
        backgroundColor: const Color.fromARGB(255, 3, 62, 91),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            filteredCourses.isEmpty
                ? const Center(child: Text('No courses available'))
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = filteredCourses[index];
                    return Card(
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
                              (course['content'] as List).map((content) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                          255,
                                          3,
                                          62,
                                          91,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text(
                                              content['content'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            setState(() {
                                              content['finished'] =
                                                  !(content['finished']
                                                          as bool? ??
                                                      false);
                                            });
                                            final userId =
                                                FirebaseAuth
                                                    .instance
                                                    .currentUser!
                                                    .uid;
                                            final userDoc = FirebaseFirestore
                                                .instance
                                                .collection('users')
                                                .doc(userId);
                                            final docSnapshot =
                                                await userDoc.get();
                                            final coursesProgress = List<
                                              Map<String, dynamic>
                                            >.from(
                                              docSnapshot['coursesProgress'] ??
                                                  [],
                                            );
                                            final courseIndex = coursesProgress
                                                .indexWhere(
                                                  (p) =>
                                                      p['title'] ==
                                                      course['title'],
                                                );
                                            final contentIndex =
                                                (course['content'] as List)
                                                    .indexOf(content);

                                            if (courseIndex != -1) {
                                              final finishedList = List<
                                                bool
                                              >.from(
                                                coursesProgress[courseIndex]['contentfinished'] ??
                                                    [],
                                              );
                                              while (finishedList.length <=
                                                  contentIndex)
                                                finishedList.add(false);
                                              finishedList[contentIndex] =
                                                  content['finished'];
                                              coursesProgress[courseIndex]['contentfinished'] =
                                                  finishedList;
                                            } else {
                                              coursesProgress.add({
                                                'title': course['title'],
                                                'contentfinished':
                                                    (course['content'] as List)
                                                        .map(
                                                          (c) =>
                                                              c == content
                                                                  ? content['finished']
                                                                  : false,
                                                        )
                                                        .toList(),
                                              });
                                            }
                                            await userDoc.update({
                                              'coursesProgress':
                                                  coursesProgress,
                                            });
                                          },
                                          icon: Icon(
                                            (content['finished'] as bool? ??
                                                    false)
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add New Course'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Course Name',
                      ),
                      controller: contenttitleController,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        addnewcontent();
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
