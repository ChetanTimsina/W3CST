import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

//importing Screens for navigation
import 'courses.dart';
import 'bookmarks.dart';
import 'quiz.dart';
import 'about.dart';
import 'Login_screen.dart';
import 'adminApproval.dart';
// Importing screens for navigation
import 'courseScreens/cprogramming.dart';
import 'courseScreens/java.dart';
import 'courseScreens/htmlcss.dart';
import 'courseScreens/webdevelopment.dart';
import 'package:w3cst/screens/courseScreens/database.dart';

class dashBoardScreen extends StatefulWidget {
  const dashBoardScreen({super.key});

  @override
  State<dashBoardScreen> createState() => _dashBoardScreenState();
}

class _dashBoardScreenState extends State<dashBoardScreen> {
  final List<Map<String, dynamic>> slides = [
    {
      'image': 'assets/images/cprogramming.png',
      'title': 'C Programming',
      'desc': 'Master widgets, animations, and backend connections!',
      'screen': 'CProgrammingScreen',
    },
    {
      'image': 'assets/images/java.png',
      'title': 'Java Basics',
      'desc': 'From portfolios to IoT dashboards — make ideas real.',
      'screen': 'javaScreen',
    },
    {
      'image': 'assets/images/htmlcss.png',
      'title': 'Html & Css',
      'desc': 'Code smart, build fast, and ship proudly',
      'screen': 'htmlcssScreen',
    },
    {
      'image': 'assets/images/web.png',
      'title': 'Web Development',
      'desc': 'Code smart, build fast, and ship proudly',
      'screen': 'webdevelopmentScreen',
    },
    {
      'image': 'assets/images/database.png',
      'title': 'Database Management',
      'desc': 'Code smart, build fast, and ship proudly',
      'screen': 'databaseScreen',
    },
  ];

  Widget _getScreen(String screenName) {
    switch (screenName) {
      case 'CProgrammingScreen':
        return const CProgrammingScreen(courseName: 'C Programming');
      case 'javaScreen':
        return const javaScreen(courseName: 'Java');
      case 'htmlcssScreen':
        return const htmlcssScreen(courseName: 'HTML&CSS');
      case 'webdevelopmentScreen':
        return const webdevelopmentScreen(courseName: 'Web Development');
      case 'databaseScreen':
        return const databaseScreen(courseName: 'Database Management');
      default:
        return const Scaffold(body: Center(child: Text('Screen not found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color.fromARGB(255, 3, 62, 91),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('rememberMe');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Log Out Successful")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hi there! Ready to Learn?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Learning Journey',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('You have completed X/Y lessons'),
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(value: 0.5),
                      const SizedBox(height: 8),
                      const Text(
                        'Keep up the great work! Consistency is key to mastery.',
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Continue Learning'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color.fromARGB(
                              255,
                              3,
                              62,
                              91,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Featured Topics', style: TextStyle(fontSize: 20)),
              SizedBox(
                height: 290,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: slides.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return Container(
                      width: 200,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: Image.asset(
                                slide['image'],
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    slide['title'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    slide['desc'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  _getScreen(slide['screen']),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      minimumSize: const Size(120, 35),
                                    ),
                                    child: const Text('Explore'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text('Explore More', style: TextStyle(fontSize: 20)),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1,
                mainAxisSpacing: 5,
                crossAxisSpacing: 12,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const courseScreen(),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  'assets/images/Icons/courses.png',
                                  width: 30,
                                  height: 30,
                                  color: Colors.blue,
                                ),
                                const Text(
                                  'Courses',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                Image.asset(
                                  'assets/images/Icons/rightarrow.png',
                                  width: 24,
                                  height: 24,
                                  color: Colors.blue,
                                ),
                              ],
                            ),

                            const Text(
                              'Explore all learning paths',
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 13),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Go to Courses',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const bookmarkScreen(),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  'assets/images/Icons/bookmarks.png',
                                  width: 30,
                                  height: 30,
                                  color: Colors.blue,
                                ),
                                const Text(
                                  'Bookmarks',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/Icons/rightarrow.png',
                                  width: 24,
                                  height: 24,
                                  color: Colors.blue,
                                ),
                              ],
                            ),

                            const Text(
                              'Your saved Lessons',
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Go to Bookmarks',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                'assets/images/Icons/quiz.png',
                                width: 30,
                                height: 30,
                                color: Colors.blue,
                              ),
                              const Text(
                                'Quizzes',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              Image.asset(
                                'assets/images/Icons/rightarrow.png',
                                width: 24,
                                height: 24,
                                color: Colors.blue,
                              ),
                            ],
                          ),

                          const Text(
                            'Test Your Knowledge',
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed:
                                    () => {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const quizScreen(),
                                        ),
                                      ),
                                    },
                                child: const Text(
                                  'Go to Quizzes',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              Image.asset(
                                'assets/images/Icons/rightarrow.png',
                                width: 16,
                                height: 16,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                'assets/images/Icons/about.png',
                                width: 30,
                                height: 30,
                                color: Colors.blue,
                              ),
                              const Text(
                                'About',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Image.asset(
                                'assets/images/Icons/rightarrow.png',
                                width: 24,
                                height: 24,
                                color: Colors.blue,
                              ),
                            ],
                          ),

                          const Text(
                            'Learn more about W3CST',
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const aboutScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Go to About',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              Image.asset(
                                'assets/images/Icons/rightarrow.png',
                                width: 16,
                                height: 16,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/Icons/Campaign.png',
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'New Updates Available!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'W3CST v2.0 brings interactive code editors and new courses in AI/ML. Check it out now!',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Read More...',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const adminApprovalScreen(),
                    ),
                  );
                },
                child: const Text('Admin Approval page demo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
