import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:w3cst/services/storage_service.dart';

class adminApprovalScreen extends StatefulWidget {
  const adminApprovalScreen({super.key});

  @override
  State<adminApprovalScreen> createState() => _adminApprovalScreenState();
}

class _adminApprovalScreenState extends State<adminApprovalScreen> {
  List<Map<String, dynamic>> allRequests = [];
  @override
  void initState() {
    super.initState();
    loadRequest();
  }

  Future<void> loadRequest() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference requestsRef = firestore.collection('adminApproval');

    QuerySnapshot querySnapshot = await requestsRef.get();

    List<Map<String, dynamic>> tempList = [];

    for (var doc in querySnapshot.docs) {
      final userId = doc.id;
      final data = doc.data() as Map<String, dynamic>;
      final courses = List<Map<String, dynamic>>.from(data['courses'] ?? []);

      for (var course in courses) {
        tempList.add({
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

  Future<void> dissapproveFunction(
    String userId,
    String title,
    String description,
    dynamic createdAt,
  ) async {
    final firestore = FirebaseFirestore.instance;

    DocumentReference requestDocRef = firestore
        .collection('adminApproval')
        .doc(userId);

    final snapshot = await requestDocRef.get();

    if (!snapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Course disapproved (no request doc found)."),
        ),
      );
      await loadRequest();
      return;
    }

    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    final rawCourses = data['courses'] ?? [];

    final List<Map<String, dynamic>> courses = List<Map<String, dynamic>>.from(
      rawCourses.map(
        (c) => Map<String, dynamic>.from(c as Map<dynamic, dynamic>),
      ),
    );

    String _norm(dynamic v) {
      if (v == null) return '';
      if (v is Timestamp) return v.toDate().toIso8601String();
      if (v is DateTime) return v.toIso8601String();
      return v.toString();
    }

    final createdAtNorm = _norm(createdAt);

    courses.removeWhere((course) {
      final ca = course['createdAt'];
      final titleMatch = course['title'] == title;
      final createdAtMatch = _norm(ca) == createdAtNorm;
      return titleMatch && createdAtMatch;
    });

    if (courses.isEmpty) {
      await requestDocRef.delete();
    } else {
      await requestDocRef.update({'courses': courses});
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Course has been disapproved")),
    );

    await loadRequest();
  }

  Future<void> approvingFunction(
    String userId,
    String title,
    String description,
    dynamic createdAt,
  ) async {
    final firestore = FirebaseFirestore.instance;

    Map<String, dynamic> courseData = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toIso8601String(),
    };

    DocumentReference approvedRef = firestore
        .collection('ApprovedCourses')
        .doc(userId);

    await approvedRef.set({
      'courses': FieldValue.arrayUnion([courseData]),
    }, SetOptions(merge: true));

    DocumentReference requestDocRef = firestore
        .collection('adminApproval')
        .doc(userId);

    final snapshot = await requestDocRef.get();

    if (!snapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Course approved (no request doc found)."),
        ),
      );
      await loadRequest();
      return;
    }

    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    final rawCourses = data['courses'] ?? [];

    final List<Map<String, dynamic>> courses = List<Map<String, dynamic>>.from(
      rawCourses.map(
        (c) => Map<String, dynamic>.from(c as Map<dynamic, dynamic>),
      ),
    );

    String _norm(dynamic v) {
      if (v == null) return '';
      if (v is Timestamp) return v.toDate().toIso8601String();
      if (v is DateTime) return v.toIso8601String();
      return v.toString();
    }

    final createdAtNorm = _norm(createdAt);

    courses.removeWhere((course) {
      final ca = course['createdAt'];
      final titleMatch = course['title'] == title;
      final createdAtMatch = _norm(ca) == createdAtNorm;
      return titleMatch && createdAtMatch;
    });

    if (courses.isEmpty) {
      await requestDocRef.delete();
    } else {
      await requestDocRef.update({'courses': courses});
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Course has been approved")));

    await loadRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('adminApproval'),
        backgroundColor: const Color.fromARGB(255, 3, 62, 91),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body:
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
                                    IconButton(
                                      onPressed:
                                          () => {
                                            dissapproveFunction(
                                              request['userId'],
                                              request['title'],
                                              request['description'],
                                              request['createdAt'],
                                            ),
                                          },
                                      icon: Icon(
                                        Icons.cancel_presentation_sharp,
                                        color: Colors.red,
                                      ),
                                    ),

                                    IconButton(
                                      onPressed:
                                          () => {
                                            approvingFunction(
                                              request['userId'],
                                              request['title'],
                                              request['description'],
                                              request['createdAt'],
                                            ),
                                          },
                                      icon: Icon(
                                        Icons.check_box_outlined,
                                        color: Colors.green,
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
    );
  }
}
