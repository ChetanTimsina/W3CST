import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizShowPage extends StatefulWidget {
  final String courseName;
  const QuizShowPage({super.key, required this.courseName});

  @override
  State<QuizShowPage> createState() => _QuizShowPageState();
}

class _QuizShowPageState extends State<QuizShowPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int currentIndex = 0;
  int score = 0;
  List questions = [];
  bool isAnswered = false;
  String selectedAnswer = '';
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    fetchQuestions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchQuestions() async {
    final doc = await _firestore.collection('Quizzes').doc('Allcourses').get();
    final data = doc.data()?[widget.courseName];
    if (data != null && data['questions'] != null) {
      setState(() {
        questions = data['questions'];
      });
      _controller.forward();
    }
  }

  Future<void> saveScore() async {
    final user = _auth.currentUser;
    if (user == null || score <= 0) return;
    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();
    final existingScores = userDoc.data()?['scores'] ?? {};
    final previousScore = existingScores[widget.courseName] ?? 0;
    if (score > previousScore) {
      existingScores[widget.courseName] = score;
      await userRef.set({'scores': existingScores}, SetOptions(merge: true));
    }
  }

  void handleAnswer(String option) {
    if (isAnswered) return;
    final correct = questions[currentIndex]['correctAnswer'];
    final isCorrect = option == correct;
    setState(() {
      isAnswered = true;
      selectedAnswer = option;
      if (isCorrect) score++;
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (currentIndex < questions.length - 1) {
        setState(() {
          currentIndex++;
          isAnswered = false;
          selectedAnswer = '';
        });
        _controller
          ..reset()
          ..forward();
      } else {
        saveScore();
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('🎉 Quiz Completed!'),
                content: Text('You scored $score out of ${questions.length}.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.courseName),
          backgroundColor: const Color(0xff033E5B),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xff033E5B)),
        ),
      );
    }

    final question = questions[currentIndex];
    final options = question['options'] as List;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FA),
      appBar: AppBar(
        title: Text(widget.courseName),
        backgroundColor: const Color(0xff033E5B),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 3,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: (currentIndex + 1) / questions.length,
                backgroundColor: Colors.grey.shade300,
                color: const Color(0xff033E5B),
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 24),
              Text(
                'Question ${currentIndex + 1} of ${questions.length}',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                question['question'] ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff033E5B),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 30),
              ...options.map((option) {
                final isSelected = option == selectedAnswer;
                final correct = question['correctAnswer'];
                Color bgColor = Colors.white;
                Color borderColor = const Color(0xff033E5B);
                Color textColor = const Color(0xff033E5B);

                if (isAnswered) {
                  if (option == correct) {
                    bgColor = const Color(0xff4CAF50);
                    borderColor = const Color(0xff4CAF50);
                    textColor = Colors.white;
                  } else if (isSelected && option != correct) {
                    bgColor = const Color(0xffE53935);
                    borderColor = const Color(0xffE53935);
                    textColor = Colors.white;
                  }
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: bgColor,
                      foregroundColor: textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: borderColor, width: 1.5),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () => handleAnswer(option),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(option, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                );
              }).toList(),
              const Spacer(),
              Center(
                child: Text(
                  'Score: $score / ${questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
