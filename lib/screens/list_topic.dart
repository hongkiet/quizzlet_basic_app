import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quizlet_app/screens/home_screen.dart';
import 'package:quizlet_app/screens/topic_details.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: List_Topic(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class List_Topic extends StatefulWidget {

  final String? data;

  const List_Topic({Key? key, this.data}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<List_Topic> {
  List<Map<String, dynamic>> topicList = [];
  DatabaseReference topicRef = FirebaseDatabase.instance.reference().child('topic');
  bool _shouldDelete = false;

  @override
  void initState() {
    super.initState();
    fetchItemsFromFirebase();
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
        });
        // print(topics);
      } else {
        print('Không nhận được dữ liệu');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEADBC8),
        title: const Text('Danh sách chủ đề', style: TextStyle( color: Color(0xFF0F2167)),),
        leading: IconButton(
          icon: const Icon(
            Iconsax.arrow_left,
            color: Color(0xFF0F2167),
            size: 30,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),

      ),
      body: Container(
        color: const Color(0xFFFEFAF6),
        child: ListView.builder(
          itemCount: topicList.length,
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(topicList[index].hashCode.toString()),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                setState(() {

                  topicRef.child(topicList[index]['id_topic']).remove();

                topicList.removeAt(index);
              });

            },
            confirmDismiss: (direction) async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Xác nhận'),
                    content: const Text('Bạn có chắc muốn xóa mục này không?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          _shouldDelete = true;
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Chắc chắn'),
                      ),

                        const SizedBox(width: 7,),

                      TextButton(
                        onPressed: () {
                          _shouldDelete = false;
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Huỷ'),
                      ),
                    ],
                  );
                },
              );
              return _shouldDelete;
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            child: FractionalTranslation(
              translation: const Offset(0, 0),
              child: Expanded(
                child: InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TopicDetail(data: topicList[index]['id_topic'], userEmail: widget.data,)),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFFECD6)),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFFFECD6),
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
                          ' Tạo bởi: ${topicList[index]['user_email']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      )
    ),);
  }
}
