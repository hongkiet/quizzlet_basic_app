import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quizlet_app/flashcard/flashcard.dart';
import 'package:quizlet_app/flashcard/flashcard_screen.dart';
import 'package:quizlet_app/flashcard/quizz_screen.dart';
import 'package:quizlet_app/flashcard/typing_screen.dart';
import 'package:quizlet_app/screens/home_screen.dart';
import 'package:quizlet_app/screens/list_topic.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:quizlet_app/screens/word_after.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TopicDetail(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TopicDetail extends StatefulWidget {
  final String? data;

  final String? userEmail;

  const TopicDetail({Key? key, this.data, this .userEmail}) : super(key: key);

  @override
  _TopicDetailState createState() => _TopicDetailState();
}

class _TopicDetailState extends State<TopicDetail> {
  DatabaseReference topicRef = FirebaseDatabase.instance.reference().child('topic');

  String? id_topic;
  List<String> _topic_detail = [];
  List<String> number_topic = [];
  List<Map<String, String>> topic_detail = [];
  List<String> listVocab = [];
  List<dynamic> vocabList = [];
  int count = 0;

  bool _isSpeaking = false;
  late FlutterTts flutterTts;
  final bool _isSwapping = false;

  @override
  void initState() {
    super.initState();
    id_topic = widget.data;
    fetchItemsFromFirebase();
    fetchVocabularyFromTopic(id_topic!);
    flutterTts = FlutterTts();
  }

  void   fetchItemsFromFirebase() async{
    if (id_topic != null) {
      
      topicRef.child(id_topic!).onValue.listen((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          Map<String, dynamic> dataMap = Map<String, dynamic>.from(snapshot.value as Map);
          setState(() {
            _topic_detail = [
              dataMap['id_user'],
              dataMap['name_topic'],
              dataMap['value'].toString()
            ];
          });

          number_topic = List<String>.from(dataMap['value']);
          count = number_topic.length;

          topic_detail = number_topic.map((e) {
            List<String> pair = e.split(':');
            return {
              'term': pair[0].trim(),
              'definition': pair[1].trim()
            };
          }).toList();
        } else {
          print('Không nhận được dữ liệu cho topic với ID: $id_topic');
        }
      });
    } else {
      print('ID topic là null');
    }
  }

  Future<List<String>> fetchVocabularyFromTopic(String topicId) async {
    DatabaseReference topicRef = FirebaseDatabase.instance.ref().child('topic/$topicId/value');
    DataSnapshot snapshot = await topicRef.get();

    if (snapshot.exists) {
      var value = snapshot.value;
      if (value is List) {
        vocabList = value;
        return vocabList.map((item) => item.toString()).toList();
      } else {
        print('Dữ liệu cho topic với topicId: $topicId không phải là danh sách');
        return [];
      }
    } else {
      print('Không nhận được dữ liệu cho topic với topicId: $topicId');
      return [];
    }
  }



  Future<void> speakText(String text) async {
    setState(() {
      _isSpeaking = true;
    });
    print(text);
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

  void _showBottomSheet() {
    showModalBottomSheet(
      backgroundColor: const Color(0xFF0F2167),
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 40.0, right: 40.0, top: 30.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECD6),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Topic_change(data: id_topic, userEmail: widget.userEmail,)),
                  );
                },
                child: const ListTile(
                  leading: Icon(Iconsax.edit, color: Color(0xFF0F2167)),
                  title: Text('Chỉnh sửa', style: TextStyle(fontSize: 16, color: Color(0xFF0F2167))),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFECD6),
        title: Text(
          _topic_detail.isNotEmpty ? _topic_detail[1] : '',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F2167),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Color(0xFF0F2167),
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context, widget.userEmail);
          },
        ),
        actions: [
          Visibility(
            visible: true,
            child: IconButton(
              icon: const Icon(
                Iconsax.arrow_circle_down,
                color: Color(0xFF0F2167),
                size: 30,
              ),
              onPressed: () {
                _showBottomSheet();
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.only(left: 5.5, top: 5.5, right: 10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_topic_detail.isNotEmpty ? _topic_detail[0] : ''),
                const SizedBox(width: 10),
                const Divider(),
                const SizedBox(width: 10),
                Text('${number_topic.length} thuật ngữ'),
              ],
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
              onTap: () {
                if (vocabList.isNotEmpty) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FlashcardScreen(vocabulary: vocabList.cast<String>(), topicId: id_topic!,)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã có lỗi xảy ra. Vui lòng thử lại!')),
                  );
                }
              },

                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECD6),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFFFECD6),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Icon(Iconsax.layer, color: Color(0xFF0F2167)),
                      SizedBox(width: 10),
                      Text(
                        'Thẻ ghi nhớ',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
              onTap: () {
                if (vocabList.isNotEmpty) {
                  print('It still running...');
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuizScreen(vocabulary: vocabList.cast<String>(), topicId: id_topic!,)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã có lỗi xảy ra. Vui lòng thử lại!')),
                  );
                }
              },

                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  decoration: BoxDecoration(
                     color: const Color(0xFFFFECD6),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFFFECD6),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Icon(Iconsax.layer, color: Color(0xFF0F2167)),
                      SizedBox(width: 10),
                      Text(
                        'Học bằng Quiz',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
              onTap: () {
                if (vocabList.isNotEmpty) {
                  print('It still running...');
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TypingPracticeScreen(vocabulary: vocabList.cast<String>(), topicId: id_topic!,)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã có lỗi xảy ra. Vui lòng thử lại!')),
                  );
                }
              },

                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECD6),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFFFECD6),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Icon(Iconsax.layer, color: Color(0xFF0F2167)),
                      SizedBox(width: 10),
                      Text(
                        'Điền từ vào chỗ trống',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                Text(
                  'Thuật ngữ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ...List.generate(
                count,
                (index) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFF4CB9E7),
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${topic_detail[index]['term']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${topic_detail[index]['definition']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            speakText(topic_detail[index]['term']!);
                          },
                          icon: const Icon(Iconsax.volume_high),
                        )
                      ],
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}