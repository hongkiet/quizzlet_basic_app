import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quizlet_app/screens/list_folder.dart';
import 'package:quizlet_app/screens/topic_in_folder.dart';
import 'package:quizlet_app/screens/topic_details.dart';

class MyFolder {
  String id_user;
  String name;
  String desmons;
  List<String> id_topic;

  MyFolder({
    required this.id_user,
    required this.name,
    required this.desmons,
    required this.id_topic,
  });

  factory MyFolder.fromMap(Map<String, dynamic> map) {
    List<String> topicList = [];

    var folder = map['id_topic'];
    if (folder is Map) {
      topicList = folder.values.map((item) => item.toString()).toList();
    } else if (folder is List) {
      topicList = folder.cast<String>();
    } else if (folder is String && folder.isEmpty) {
      // Handle empty string case
      topicList = [];
    }

    return MyFolder(
      id_user: map['id_user'] ?? '',
      name: map['folder_name'] ?? '',
      desmons: map['desmons'] ?? '',
      id_topic: topicList,
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Folder_Detail(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Folder_Detail extends StatefulWidget {
  final String? data;
  final String? userEmail;

  const Folder_Detail({Key? key, this.data, this.userEmail}) : super(key: key);

  @override
  _FolderDetailState createState() => _FolderDetailState();
}

class _FolderDetailState extends State<Folder_Detail> {
  List<Map<String, dynamic>> folderList = [];
  DatabaseReference folderRef = FirebaseDatabase.instance.reference().child('folder');
  DatabaseReference topicRef = FirebaseDatabase.instance.reference().child('topic');
  bool _shouldDelete = false;

  String? id_folder;
  List<String> _folder_detail = [];
  List<String> topic = [];
  int count = 0;

  List<Map<String, dynamic>> topicList = [];

  List<String> numberTopic = [];

  @override
  void initState() {
    super.initState();
    id_folder = widget.data;
    fetchItemsFromFirebase();
  }

  void fetchItemsFromFirebase() {
    if (id_folder != null) {
      folderRef.child(id_folder!).onValue.listen((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          Map<String, dynamic> dataMap = Map<String, dynamic>.from(snapshot.value as Map);
          MyFolder myFolder = MyFolder.fromMap(dataMap);
          setState(() {
            _folder_detail = [
              myFolder.id_user,
              myFolder.name,
              myFolder.desmons,
            ];

            numberTopic = myFolder.id_topic;

            print('numberTopic: $numberTopic');

            // Fetch topics only after numberTopic is set
            fetchTopicFromFirebase();
          });
        } else {
          print('Không nhận được dữ liệu cho folder với ID: $id_folder');
        }
      });
    } else {
      print('ID folder là null');
    }
  }

  void fetchTopicFromFirebase() {
    if (numberTopic.isEmpty) {
      print('numberTopic is empty');
      return;
    }
    topicRef.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> topicMap = snapshot.value as Map<dynamic, dynamic>;
        // print('Dữ liệu topic nhận được: $topicMap'); // Debug dữ liệu topic nhận được

        // Lọc các topic có id trong numberTopic
        List<Map<String, dynamic>> filteredTopics = topicMap.entries.where((entry) {
          return numberTopic.contains(entry.key.toString());
        }).map((entry) {
          return {
            "id_topic": entry.key.toString(),
            "name_topic": entry.value["name_topic"],
            "user_email": entry.value["id_user"],
          };
        }).toList();

        // print('Danh sách topic đã lọc: $filteredTopics'); // Debug danh sách topic đã lọc

        setState(() {
          topicList = filteredTopics;
          topic = filteredTopics.map((e) => e['id_topic'].toString()).toList();
        });
      } else {
        print('Không nhận được dữ liệu');
      }
    });
  }

  void removeTopicFromFirebase(int index) {
    String topicIdToRemove = topic[index];

    setState(() {
      topic.removeAt(index);
      numberTopic = topic;
      topicList = topicList.where((t) => t['id_topic'] != topicIdToRemove).toList();
    });

    folderRef.child(id_folder!).child('id_topic').once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        List<dynamic> data = List.from(snapshot.value as List<dynamic>);

        // Xóa mục tại vị trí index
        data.removeAt(index);

        // Nếu danh sách trống, đặt lại 'id_topic' thành một danh sách trống
        if (data.isEmpty) {
          folderRef.child('$id_folder/id_topic').set({}).catchError((error) {
            print('Error updating topic in database: $error');
          });
        } else {
          folderRef.child('$id_folder/id_topic').set(data).catchError((error) {
            print('Error updating topic in database: $error');
          });
        }
      }
    }).catchError((error) {
      print('Error finding topic in database: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_folder_detail.length > 1 ? _folder_detail[1] : 'Loading...'}'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_outlined,
            color: Color(0xFF7B66FF),
            size: 30,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => List_Folder(data: widget.userEmail)),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Color(0xFF7B66FF),
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => List_Topic_InFolder(data: widget.userEmail, id_folder: id_folder)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
        child: Column(
          children: [
            Text(
              _folder_detail.isNotEmpty ? _folder_detail[2] : '',
              style: TextStyle(fontSize: 20),
              maxLines: 2,
            ),
            SizedBox(height: 15),
            ListView.builder(
              shrinkWrap: true, // Quan trọng: Chỉ định kích thước nhỏ hơn
              physics: NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn của ListView bên trong SingleChildScrollView
              itemCount: topicList.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: Key(topic[index].hashCode.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    removeTopicFromFirebase(index);
                  },
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Xác nhận'),
                          content: Text('Bạn có chắc muốn xóa mục này không?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                _shouldDelete = true;
                                Navigator.of(context).pop(true);
                              },
                              child: Text('Xóa đi chời'),
                            ),
                            SizedBox(width: 7),
                            TextButton(
                              onPressed: () {
                                _shouldDelete = false;
                                Navigator.of(context).pop(false);
                              },
                              child: Text('Không má'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  child: FractionalTranslation(
                    translation: Offset(0, 0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TopicDetail(data: topic[index], userEmail: widget.userEmail)),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFFF69B4)),
                          borderRadius: BorderRadius.circular(8),
                          color: Color(0xFFF0D6FA),
                        ),
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${topicList[index]['name_topic']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Tạo bởi: ${topicList[index]['user_email']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
