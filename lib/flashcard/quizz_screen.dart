import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:iconsax/iconsax.dart';

class QuizScreen extends StatefulWidget {
  final List<String> vocabulary;
  final String topicId;

  const QuizScreen({Key? key, required this.vocabulary, required this.topicId}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Flashcard> _flashcards;
  int _currentIndex = 0;
  int _score = 0;
  String _selectedAnswer = '';
  bool _showFeedback = false;
  final bool _immediateFeedback = true;
  bool _showEnglish = true;
  final bool _pronounceEnglish = true;
  final bool _shuffleOrder = true;
  late FlutterTts flutterTts;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference _userRef;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _flashcards = widget.vocabulary.map((vocab) {
      var parts = vocab.split(':');
      return Flashcard(question: parts[0], answer: parts[1]);
    }).toList();

    if (_shuffleOrder) {
      _flashcards.shuffle();
    }

    User? user = _auth.currentUser;
    if (user != null) {
      _userRef = FirebaseDatabase.instance.reference().child('users').child(user.uid);
    }

    _checkIfTopicStudied();
  }


  Future<bool> _isTopicStudied() async {
    DataSnapshot snapshot = await _userRef.child('topics').child(widget.topicId).child('vocabulary').get();
    if (snapshot.exists) {
      Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
      for (var word in data.values) {
        if (word['status'] == 'currently_learning' || word['status'] == 'memorized') {
          return true;
        }
      }
    }
    return false;
  }

  void _checkIfTopicStudied() async {
    bool isStudied = await _isTopicStudied();
    if (isStudied) {
      _showAlreadyStudiedDialog();
    }
  }

  void _showAlreadyStudiedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đã học rồi'),
          content: const Text('Bạn đã học topic này rồi. Bạn muốn học lại hay thoát?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Học Lại'),
              onPressed: () {
                Navigator.of(context).pop();
                _restartQuiz();
              },
            ),
            TextButton(
              child: const Text('Thoát'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _selectedAnswer = '';
      _showFeedback = false;
      _flashcards.shuffle();
      _speakCurrentWord();
    });
  }


  

  void _speakText(String text) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.speak(text);
  }

  void _speakCurrentWord() {
    String textToSpeak = _flashcards[_currentIndex].question;
    _speakText(textToSpeak);
  }

  void _checkAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
      String correctAnswer = _showEnglish
          ? _flashcards[_currentIndex].answer
          : _flashcards[_currentIndex].question;
      if (answer == correctAnswer) {
        _score++;
        _updateProgress(_flashcards[_currentIndex].question, 'currently_learning');
      } else {
        _updateProgress(_flashcards[_currentIndex].question, 'not_learned');
      }
      _showFeedback = true;
    });

    if (_immediateFeedback) {
      Future.delayed(const Duration(seconds: 2), _nextQuestion);
    }
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _selectedAnswer = '';
      _showFeedback = false;
    });

    if (_currentIndex < _flashcards.length) {
      _speakCurrentWord();
    }
  }

  void _showResults() {
    _updateProgressForAllMemorized();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Finished'),
        content: Text('Your score: $_score/${_flashcards.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _swapLanguage() {
    setState(() {
      _showEnglish = !_showEnglish;
      _currentIndex = 0;
      _score = 0;
      _selectedAnswer = '';
      _showFeedback = false;
      _flashcards.shuffle();
      _speakCurrentWord();
    });
  }

  void _updateProgress(String word, String status) {
    _userRef.child('topics').child(widget.topicId).child('vocabulary').child(word).set({'status': status});
  }

  void _updateProgressForAllMemorized() {
    for (var flashcard in _flashcards) {
      _updateProgress(flashcard.question, 'memorized');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= _flashcards.length) {
      // Delay the call to _showResults() to ensure it runs after the build is complete.
      Future.delayed(Duration.zero, _showResults);
      return Container();
    }

    String questionText = _showEnglish
        ? _flashcards[_currentIndex].question
        : _flashcards[_currentIndex].answer;
    List<String> options = _generateOptions(_showEnglish
        ? _flashcards[_currentIndex].answer
        : _flashcards[_currentIndex].question);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEADBC8),
        title: const Text(
          'Quiz',
          style: TextStyle(color: Color(0xFF0F2167)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.arrow_swap_horizontal),
            onPressed: _swapLanguage,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_currentIndex + 1}/${_flashcards.length}',
               style: const TextStyle(
                  fontSize: 20.0,
                  color: Color(0xFF0F2167),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Text(
              'Score: $_score',
               style: const TextStyle(
                  fontSize: 20.0,
                  color: Color(0xFF0F2167),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            Text(
              questionText,
              style: const TextStyle(
                  fontSize: 20.0,
                  color: Color(0xFF0F2167),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            ...options.map((option) {
              return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (!_showFeedback) {
              _checkAnswer(option);
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFFF1F1F1),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), 
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), 
            ),
          ),
          child: Text(
            option,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      );
            }).toList(),
            if (_showFeedback)
              Text(
                _selectedAnswer ==
                        (_showEnglish
                            ? _flashcards[_currentIndex].answer
                            : _flashcards[_currentIndex].question)
                    ? 'Correct!'
                    : 'Wrong!',
                style: const TextStyle(fontSize: 20.0, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }


  List<String> _generateOptions(String correctAnswer) {
    List<String> options = [];

    options.add(correctAnswer);

    Random random = Random();
    while (options.length < 4) {
      String option = _showEnglish
          ? _flashcards[random.nextInt(_flashcards.length)].answer
          : _flashcards[random.nextInt(_flashcards.length)].question;
      if (!options.contains(option)) {
        options.add(option);
      }
    }

    options.shuffle();
    return options;
  }
}

class Flashcard {
  final String question;
  final String answer;

  Flashcard({required this.question, required this.answer});
}
