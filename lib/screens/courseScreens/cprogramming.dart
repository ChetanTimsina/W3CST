import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

Color getRandomColor() {
  Random random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}

class CProgrammingScreen extends StatefulWidget {
  final String courseName;
  const CProgrammingScreen({super.key, required this.courseName});

  @override
  State<CProgrammingScreen> createState() => _CProgrammingScreenState();
}

class _CProgrammingScreenState extends State<CProgrammingScreen> {
  List<Map<String, dynamic>> allCourses = [];
  bool loading = true;

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
    final firestore = FirebaseFirestore.instance;
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docData = await firestore.collection('users').doc(userId).get();
    final userProgress = List<Map<String, dynamic>>.from(
      docData['coursesProgress'] ?? [],
    );

    final defaultCoursesSnap =
        await firestore.collection('DefaultCourses').get();
    final approvedCoursesSnap =
        await firestore.collection('ApprovedCourses').get();

    List<Map<String, dynamic>> tempList = [];

    for (var snap in [
      ...defaultCoursesSnap.docs,
      ...approvedCoursesSnap.docs,
    ]) {
      final data = snap.data() as Map<String, dynamic>;
      final courses = List<Map<String, dynamic>>.from(data['courses'] ?? []);

      for (var course in courses) {
        final contentList = List.from(course['content'] ?? []);
        final progressForCourse = userProgress.firstWhere(
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
          'title': course['title'],
          'description': course['description'],
          'content': combined,
        });
      }
    }

    setState(() {
      allCourses = tempList;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final filteredCourses =
        allCourses
            .where(
              (course) => course['title'].toString().toLowerCase().contains(
                widget.courseName.toLowerCase(),
              ),
            )
            .toList();

    if (filteredCourses.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('C Programming'),
          backgroundColor: const Color.fromARGB(255, 3, 62, 91),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('No courses available')),
      );
    }

    return CourseContentPager(course: filteredCourses[0]);
  }
}

class CourseContentPager extends StatefulWidget {
  final Map<String, dynamic> course;
  const CourseContentPager({super.key, required this.course});

  @override
  State<CourseContentPager> createState() => _CourseContentPagerState();
}

class _CourseContentPagerState extends State<CourseContentPager> {
  int currentIndex = 0;
  late List contentList;

  @override
  void initState() {
    super.initState();
    contentList = widget.course['content'] ?? [];
  }

  Future<void> saveProgress() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final docSnapshot = await userDoc.get();

    final coursesProgress = List<Map<String, dynamic>>.from(
      docSnapshot.data()?['coursesProgress'] ?? [],
    );

    final courseIndex = coursesProgress.indexWhere(
      (p) => p['title'] == widget.course['title'],
    );

    List<bool> finishedList =
        contentList.map((item) => item['finished'] == true).toList();

    int progressCount = finishedList.where((done) => done).length;

    double percent = 0;
    if (finishedList.isNotEmpty) {
      percent = (progressCount / finishedList.length) * 100;
    }

    if (courseIndex != -1) {
      coursesProgress[courseIndex] = {
        'title': widget.course['title'],
        'contentfinished': finishedList,
        'progress': {
          'completed': progressCount,
          'total': finishedList.length,
          'percentage': percent.toStringAsFixed(1),
        },
      };
    } else {
      coursesProgress.add({
        'title': widget.course['title'],
        'contentfinished': finishedList,
        'progress': {
          'completed': progressCount,
          'total': finishedList.length,
          'percentage': percent.toStringAsFixed(1),
        },
      });
    }
    await userDoc.update({'coursesProgress': coursesProgress});
  }

  Future<void> toggleFinished(int index) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final docSnapshot = await userDoc.get();
    final coursesProgress = List<Map<String, dynamic>>.from(
      docSnapshot['coursesProgress'] ?? [],
    );
    final courseIndex = coursesProgress.indexWhere(
      (p) => p['title'] == widget.course['title'],
    );
    if (courseIndex != -1) {
      final finishedList = List<bool>.from(
        coursesProgress[courseIndex]['contentfinished'] ?? [],
      );
      while (finishedList.length <= index) finishedList.add(false);
      finishedList[index] = !(finishedList[index]);
      coursesProgress[courseIndex]['contentfinished'] = finishedList;
    } else {
      coursesProgress.add({
        'title': widget.course['title'],
        'contentfinished': List.generate(contentList.length, (i) => i == index),
      });
    }
    await userDoc.update({'coursesProgress': coursesProgress});
    await saveProgress();
  }

  void nextPage() {
    if (currentIndex < contentList.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void prevPage() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentContent = contentList[currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course['title'] ?? 'Course'),
        backgroundColor: const Color.fromARGB(255, 3, 62, 91),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 3, color: getRandomColor()),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.course['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.course['description'] ?? '',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      currentContent['content'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentIndex > 0)
                    ElevatedButton(
                      onPressed: prevPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text('Previous'),
                    ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await toggleFinished(currentIndex);
                          setState(() {
                            currentContent['finished'] =
                                !(currentContent['finished'] ?? false);
                          });
                          await saveProgress();
                        },
                        icon: Icon(
                          currentContent['finished'] ?? false
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        child: Text(
                          currentIndex < contentList.length - 1
                              ? 'Next'
                              : 'Finish',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
