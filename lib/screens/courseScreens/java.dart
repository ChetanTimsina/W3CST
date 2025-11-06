import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class javaScreen extends StatefulWidget {
  final String courseName;
  const javaScreen({super.key, required this.courseName});

  @override
  State<javaScreen> createState() => _javaScreenState();
}

class _javaScreenState extends State<javaScreen> {
  List<Map<String, dynamic>> allcourses = [];

  @override
  void initState() {
    super.initState();
    ensureCoursesProgressExists().then((_) => loadData());
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
    final coursesCollections = [
      firestore.collection('DefaultCourses'),
      firestore.collection('ApprovedCourses'),
    ];

    final docData =
        await firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    List<Map<String, dynamic>> tempCourses = [];

    for (var coursesRef in coursesCollections) {
      final querySnapshot = await coursesRef.get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final courses = List<Map<String, dynamic>>.from(data['courses'] ?? []);

        for (var course in courses) {
          final contentList = course['content'] as List<dynamic>? ?? [];
          final contentProgress =
              docData['coursesProgress'] as List<dynamic>? ?? [];

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
                return {
                  'content': content is String ? content : content['content'],
                  'finished': finished,
                };
              }).toList();

          tempCourses.add({
            'userId': doc.id,
            'title': course['title'],
            'description': course['description'],
            'content': combined,
          });
        }
      }
    }

    setState(() {
      allcourses = tempCourses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Java'),
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
                        .contains(widget.courseName.toLowerCase().trim())) {
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
                                (course['content']).map(
                                  (content) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
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
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                10.0,
                                              ),
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

                                              final courseIndex =
                                                  coursesProgress.indexWhere(
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
                                                    contentIndex) {
                                                  finishedList.add(false);
                                                }
                                                finishedList[contentIndex] =
                                                    content['finished'];
                                                coursesProgress[courseIndex]['contentfinished'] =
                                                    finishedList;
                                              } else {
                                                coursesProgress.add({
                                                  'title': course['title'],
                                                  'contentfinished':
                                                      (course['content']
                                                              as List)
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
                                                  : Icons
                                                      .check_box_outline_blank,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
          ],
        ),
      ),
    );
  }
}
