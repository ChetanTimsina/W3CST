import 'package:flutter/material.dart';

class bookmarkScreen extends StatefulWidget {
  const bookmarkScreen({super.key});

  @override
  State<bookmarkScreen> createState() => _bookmarkScreenState();
}

class _bookmarkScreenState extends State<bookmarkScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('bookmark'),
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
                            Icon(Icons.bookmark, size: 25, color: Colors.green),
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
                            Icon(Icons.bookmark, size: 25, color: Colors.green),
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
                            Icon(Icons.bookmark, size: 25, color: Colors.green),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Dive into modern web development. Learn HTML5, CSS3, and JavaScript to build responsive and interactive websites. Includes front-end bookmarks introduction.",
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
                            Icon(Icons.bookmark, size: 25, color: Colors.green),
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
    );
  }
}
