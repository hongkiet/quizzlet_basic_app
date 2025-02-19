import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:iconsax/iconsax.dart';

class TypingPracticeScreen extends StatefulWidget {
  final List<String> vocabulary;
  final String topicId;

  const TypingPracticeScreen({Key? key, required this.vocabulary, required this.topicId}) : super(key: key);

  @override
  _TypingPracticeScreenState createState() => _TypingPracticeScreenState();
}

class _TypingPracticeScreenState extends State<TypingPracticeScreen> {
  int _currentIndex = 0;
  int _score = 0;
  final TextEditingController _controller = TextEditingController();
  final List<String> _results = [];
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
    _initializeTts();

    User? user = _auth.currentUser;
    if (user != null) {
      _userRef = FirebaseDatabase.instance.reference().child('users').child(user.uid);
    }

    _checkIfTopicStudied();
  }

  Future<void> _checkIfTopicStudied() async {
    bool isStudied = await _isTopicStudied();
    if (isStudied) {
      _showAlreadyStudiedDialog();
    } else {
      if (_shuffleOrder) {
        widget.vocabulary.shuffle();
      }
      _speakCurrentWord();
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
                _restartLearning();
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

  void _restartLearning() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _results.clear();
      if (_shuffleOrder) {
        widget.vocabulary.shuffle();
      }
      _speakCurrentWord();
    });
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

  void _initializeTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
  }

  void _speakText(String text) async {
    await flutterTts.stop(); // Stop any ongoing speech
    await flutterTts.speak(text);
  }

  void _checkAnswer() {
    String userAnswer = _controller.text.trim().toLowerCase();
    String correctAnswer = _showEnglish
        ? widget.vocabulary[_currentIndex].split(':')[1].toLowerCase()
        : widget.vocabulary[_currentIndex].split(':')[0].toLowerCase();

    setState(() {
      if (userAnswer == correctAnswer) {
        _score++;
        _results.add("Correct: ${widget.vocabulary[_currentIndex]}");
        _updateProgress(widget.vocabulary[_currentIndex].split(':')[0], 'currently_learning');
      } else {
        _results.add("Wrong: ${widget.vocabulary[_currentIndex]} (Your answer: $userAnswer)");
        _updateProgress(widget.vocabulary[_currentIndex].split(':')[0], 'not_learned');
      }
      _controller.clear();
      if (_currentIndex + 1 < widget.vocabulary.length) {
        _currentIndex++;
        _speakCurrentWord();
      } else {
        Future.delayed(Duration.zero, _showResults);
      }
    });
  }

  void _showResults() {
    _updateProgressForAllMemorized();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Typing Practice Finished'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your score: $_score/${widget.vocabulary.length}'),
              ..._results.map((result) => Text(result)).toList(),
            ],
          ),
        ),
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
      _results.clear();
      widget.vocabulary.shuffle(); // Shuffle the vocabulary list
      _speakCurrentWord();
    });
  }

  void _speakCurrentWord() {
    if (_pronounceEnglish) {
      // Always speak the English word regardless of the current language shown
      String textToSpeak = widget.vocabulary[_currentIndex].split(':')[0];
      _speakText(textToSpeak);
    }
  }

  void _updateProgress(String word, String status) {
    _userRef.child('topics').child(widget.topicId).child('vocabulary').child(word).set({'status': status});
  }

  void _updateProgressForAllMemorized() {
    for (var vocab in widget.vocabulary) {
      _updateProgress(vocab.split(':')[0], 'memorized');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.vocabulary.length) {
      Future.delayed(Duration.zero, _showResults);
      return Container();
    }

    String prompt = _showEnglish
        ? widget.vocabulary[_currentIndex].split(':')[0]
        : widget.vocabulary[_currentIndex].split(':')[1];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEADBC8),
        title: const Text(
          'Typing Practice',
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
              'Progress: ${_currentIndex + 1}/${widget.vocabulary.length} (Score: $_score)',
              style: const TextStyle(fontSize: 20.0, color: Color(0xFF0F2167)),
            ),
            const SizedBox(height: 20.0),
            Text(
              prompt,
              style: const TextStyle(fontSize: 24.0, color: Color(0xFF0F2167)),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your answer',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F2167),
                textStyle: const TextStyle(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text('Submit',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
