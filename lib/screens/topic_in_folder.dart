import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quizlet_app/screens/folder_detail.dart';
import 'package:quizlet_app/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: List_Topic_InFolder(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class List_Topic_InFolder extends StatefulWidget {
  final String? data;
  final String? id_folder;

  const List_Topic_InFolder({Key? key, this.data, this.id_folder}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<List_Topic_InFolder> {
  List<Map<String, dynamic>> topicList = [];
  DatabaseReference topicRef = FirebaseDatabase.instance.reference().child('topic');
  DatabaseReference folderRef = FirebaseDatabase.instance.reference().child('folder');

  List<String> id_topic = [];
  String? id_folder;
  List<bool> isPressedList = [];

  @override
  void initState() {
    super.initState();
    id_folder = widget.id_folder;
    fetchItemsFromFirebase();
  }

  void _onTap(int index) {
    setState(() {
      isPressedList[index] = !isPressedList[index];
      if (isPressedList[index] == true) {
        id_topic.add(topicList[index]['id_topic']);
      } else {
        id_topic.remove(topicList[index]['id_topic']);
      }
    });
  }

  void fetchItemsFromFirebase() {
    topicRef.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        List<Map<String, dynamic>> topics = [];
        Map<dynamic, dynamic> topicMap = snapshot.value as Map<dynamic, dynamic>;
        topicMap.forEach((key, value) {
          if (value is Map) {
            Map<String, dynamic> newTopic = {
              "id_topic": key,
              "name_topic": value["name_topic"],
              "user_email": value["id_user"],
            };
            if (!topics.any((topic) => topic['id_topic'] == newTopic['id_topic'])) {
              if (value["id_user"] == widget.data || value["public"] == "true") {
                topics.add(newTopic);
              }
            }
          }
        });
        setState(() {
          topicList = topics;
          isPressedList = List<bool>.filled(topicList.length, false); // Khởi tạo lại isPressedList
        });
        // print(topics);
      } else {
        print('Không nhận được dữ liệu');
      }
    });
  }

  void pushdatatofirebase() {
    Map<String, dynamic> data = {
      'id_topic': id_topic,
    };

    if (id_folder != null) {
      folderRef.child(id_folder!).update(data).then((value) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Thành công'),
              content: const Text('Chủ đề đã được thêm thành công.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Folder_Detail(
                          data: id_folder,
                          userEmail: widget.data,
                        ),
                      ),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }).catchError((error) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Lỗi'),
              content: Text('Thêm chủ đề thất bại: $error'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách chủ đề'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Color(0xFF7B66FF),
            size: 30,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              pushdatatofirebase();
            },
            child: const Text('Xong'),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFEFAF6),
        child: ListView.builder(
          itemCount: topicList.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                _onTap(index);
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: isPressedList[index]
                      ? Border.all(color: const Color(0xFFFF69B4), width: 3)
                      : Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF0D6FA),
                ),
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${topicList[index]['name_topic']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Tạo bởi: ${topicList[index]['user_email']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
