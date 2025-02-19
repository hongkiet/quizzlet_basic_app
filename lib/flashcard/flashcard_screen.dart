import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quizlet_app/flashcard/flashcard_view.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FlashcardScreen extends StatefulWidget {
  final List<String> vocabulary;
  final String topicId;

  const FlashcardScreen({Key? key, required this.vocabulary, required this.topicId}) : super(key: key);

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late List<Flashcard> _flashcards;
  int _currentIndex = 0;
  late FlutterTts flutterTts;
  bool _questionFirst = true;
  bool _isSpeaking = false;
  bool _isButtonEnabled = true;
  bool _isSwapping = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference _userRef;

  @override
  void initState() {
    super.initState();
    _initializeFlashcards();
    flutterTts = FlutterTts();

    User? user = _auth.currentUser;
    if (user != null) {
      _userRef = FirebaseDatabase.instance.reference().child('users').child(user.uid);
    }

    _checkIfTopicStudied(); 
  }


  void _initializeFlashcards() {
    _flashcards = widget.vocabulary.map((vocab) {
      var parts = vocab.split(':');
      return Flashcard(question: parts[0], answer: parts[1]);
    }).toList();
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
                _restartFlashcards();
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

  void _restartFlashcards() {
    setState(() {
      _currentIndex = 0;
      _initializeFlashcards();
    });
  }



  @override
  Widget build(BuildContext context) {
    double progress = (_currentIndex + 1) / _flashcards.length;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEADBC8),
        title: const Text(
          'Flashcards',
          style: TextStyle(color: Color(0xFF0F2167)),
        ),
        leading: IconButton(
          icon: const Icon(
            Iconsax.arrow_left,
            color: Color(0xFF0F2167),
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              height: 450,
              child: FlipCard(
                front: FlashcardView(
                  text: _questionFirst
                      ? _flashcards[_currentIndex].question
                      : _flashcards[_currentIndex].answer,
                ),
                back: FlashcardView(
                  text: _questionFirst
                      ? _flashcards[_currentIndex].answer
                      : _flashcards[_currentIndex].question,
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _isButtonEnabled && !_isSpeaking
                      ? _delayedPreviousCard
                      : null,
                  icon: const Icon(Iconsax.arrow_circle_left),
                  label: const Text('Trước'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCAF4FF), // Màu nền cho nút
                  ),
                ),
                IconButton(
                  onPressed: _isButtonEnabled && !_isSpeaking
                      ? _speakCurrentWord
                      : null,
                  icon: const Icon(Iconsax.volume_high),
                ),
                ElevatedButton.icon(
                  onPressed: _isButtonEnabled && !_isSpeaking
                      ? _delayedNextCard
                      : null,
                  icon: const Icon(Iconsax.arrow_circle_right),
                  label: const Text('Sau'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCAF4FF), // Màu nền cho nút
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (!_isSpeaking) {
                      setState(() {
                        _questionFirst = !_questionFirst;
                        _isSwapping = true;
                      });
                      Future.delayed(const Duration(milliseconds: 500), () {
                        setState(() {
                          _isSwapping = false;
                        });
                      });
                    }
                  },
                  icon: const Icon(Iconsax.arrow_swap_horizontal),
                  label: const Text('Swap'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCAF4FF), // Màu nền cho nút
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton.icon(
                  onPressed: _isButtonEnabled && !_isSpeaking
                      ? _shuffleVocabulary
                      : null,
                  icon: const Icon(Iconsax.shuffle),
                  label: const Text('Đảo từ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCAF4FF), // Màu nền cho nút
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_currentIndex + 1}/${_flashcards.length} (${(progress * 100).toStringAsFixed(0)}%)',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              backgroundColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }

  void _delayedPreviousCard() {
    if (_isButtonEnabled && !_isSpeaking) {
      _toggleButton();
      Future.delayed(const Duration(milliseconds: 1000), () {
        showPreviousCard();
        speakText(_flashcards[_currentIndex].question);
        _toggleButton();
      });
    }
  }

  void _delayedNextCard() {
    if (_isButtonEnabled && !_isSpeaking) {
      _toggleButton();
      Future.delayed(const Duration(milliseconds: 1000), () {
        showNextCard();
        speakText(_flashcards[_currentIndex].question);
        _toggleButton();
        _updateProgress(_flashcards[_currentIndex].question, 'currently_learning');
      });
    }
  }

  void showNextCard() {
    setState(() {
      _currentIndex =
          (_currentIndex + 1 < _flashcards.length) ? _currentIndex + 1 : 0;
    });
  }

  void showPreviousCard() {
    setState(() {
      _currentIndex = (_currentIndex - 1 >= 0)
          ? _currentIndex - 1
          : _flashcards.length - 1;
    });
  }

  Future<void> speakText(String text) async {
    setState(() {
      _isSpeaking = true;
    });
    await flutterTts.setLanguage('en-US'); 
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    if (!_isSwapping) { 
      await flutterTts.speak(text);
    }
    setState(() {
      _isSpeaking = false;
    });
  }

  Future<void> _toggleButton() async {
    setState(() {
      _isButtonEnabled = !_isButtonEnabled;
    });
  }

  void _shuffleVocabulary() {
    setState(() {
      _flashcards.shuffle();
      _currentIndex = 0; 
    });
  }

  void _speakCurrentWord() {
    String currentWord = _questionFirst ? _flashcards[_currentIndex].question : _flashcards[_currentIndex].answer;
    speakText(currentWord);
  }

  void _updateProgress(String word, String status) {
    _userRef.child('topics').child(widget.topicId).child('vocabulary').child(word).set({'status': status});
  }
}

class Flashcard {
  final String question;
  final String answer;

  Flashcard({required this.question, required this.answer});
}
