import 'package:flutter/material.dart';

//importing Screens for navigation
import 'courses.dart';

class dashBoardScreen extends StatefulWidget {
  const dashBoardScreen({super.key});

  @override
  State<dashBoardScreen> createState() => _dashBoardScreenState();
}

class _dashBoardScreenState extends State<dashBoardScreen> {
  final List<Map<String, dynamic>> slides = [
    {
      'image': 'assets/images/carouselDashboard/carousel1.jpeg',
      'title': 'Learn Flutter Like a Pro',
      'desc': 'Master widgets, animations, and backend connections!',
    },
    {
      'image': 'assets/images/carouselDashboard/carousel2.jpeg',
      'title': 'Build Cool Projects',
      'desc': 'From portfolios to IoT dashboards — make ideas real.',
    },
    {
      'image': 'assets/images/carouselDashboard/carousel3.jpeg',
      'title': 'Join the Dev Revolution',
      'desc': 'Code smart, build fast, and ship proudly 💪',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color.fromARGB(255, 3, 62, 91),
        foregroundColor: Colors.white,
        centerTitle: true,
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
                                      debugPrint('Pressed ${slide['title']}');
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
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Icons/courses.png',
                                width: 50,
                                height: 50,
                              ),
                              const SizedBox(width: 6),
                              Image.asset(
                                'assets/images/Icons/rightarrow.png',
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Courses',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Explore all learning paths',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const courseScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Go to Courses',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Image.asset(
                                'assets/images/Icons/rightarrow.png',
                                width: 16,
                                height: 16,
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
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Icons/framework.png',
                                width: 50,
                                height: 50,
                              ),
                              const SizedBox(width: 6),
                              Image.asset(
                                'assets/images/Icons/rightarrow.png',
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Frameworks',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Master new tech stacks',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Go to Frameworks',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Image.asset(
                                'assets/images/Icons/rightarrow.png',
                                width: 16,
                                height: 16,
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
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Icons/quiz.png',
                                width: 50,
                                height: 50,
                              ),
                              const SizedBox(width: 6),
                              Image.asset(
                                'assets/images/Icons/rightarrow.png',
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Quizzes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Test Your Knowledge',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Go to Quizzes',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Image.asset(
                                'assets/images/Icons/rightarrow.png',
                                width: 16,
                                height: 16,
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
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Icons/about.png',
                                width: 50,
                                height: 50,
                              ),
                              const SizedBox(width: 6),
                              Image.asset(
                                'assets/images/Icons/rightarrow.png',
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'About',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Learn more about W3CST',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Go to About',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Image.asset(
                                'assets/images/Icons/rightarrow.png',
                                width: 16,
                                height: 16,
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
            ],
          ),
        ),
      ),
    );
  }
}
