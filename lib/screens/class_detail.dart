import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quizlet_app/screens/list_class.dart';
import 'package:quizlet_app/screens/list_folder.dart';
import 'package:quizlet_app/screens/topic_in_class.dart';
import 'package:quizlet_app/screens/topic_in_folder.dart';
import 'package:quizlet_app/screens/topic_details.dart';

class MyClass {
  String id_user;
  String name;
  String desmons;
  String status;
  List<String> id_topic;

  MyClass({
    required this.id_user,
    required this.name,
    required this.desmons,
    required this.status,
    required this.id_topic,
  });

  factory MyClass.fromMap(Map<String, dynamic> map) {
    var id_topic = map['id_topic'];
    List<String> topics = [];

    if (id_topic is Map) {
      topics = List<String>.from(id_topic.values);
    } else if (id_topic is List) {
      topics = List<String>.from(id_topic);
    }

    return MyClass(
      id_user: map['id_user'] ?? '', // Sử dụng giá trị mặc định nếu null
      name: map['class_name'] ?? '', // Sử dụng giá trị mặc định nếu null
      desmons: map['desmons'] ?? '', // Sử dụng giá trị mặc định nếu null
      status: map['status'] ?? 'unknown', // Sử dụng giá trị mặc định nếu null
      id_topic: topics,
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
      home: Class_Detail(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Class_Detail extends StatefulWidget {
  final String? data;
  final String? userEmail;

  const Class_Detail({Key? key, this.data, this.userEmail}) : super(key: key);

  @override
  _ClassDetailState createState() => _ClassDetailState();
}

class _ClassDetailState extends State<Class_Detail> {
  DatabaseReference classRef = FirebaseDatabase.instance.reference().child('class');
  DatabaseReference topicRef = FirebaseDatabase.instance.reference().child('topic');
  bool _shouldDelete = false;

  String? id_class;
  List<String> _class_detail = [];
  List<String> topic = [];
  int count = 0;

  bool _isSwitchOn = false;

  List<Map<String, dynamic>> topicList = [];

  List<String> numberTopic = [];

  bool _isSwitchVisible = false;

  bool canDelete = false;


  @override
  void initState() {
    super.initState();
    id_class = widget.data;
    fetchItemsFromFirebase();
    fetchTopicFromFirebase();
  }

  void fetchItemsFromFirebase() {
    if (id_class != null) {
      classRef.child(id_class!).onValue.listen((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          Map<String, dynamic> dataMap = Map<String, dynamic>.from(snapshot.value as Map);
          print('Dữ liệu nhận được: $dataMap'); // Thêm dòng này để in dữ liệu
          MyClass myClass = MyClass.fromMap(dataMap);
          setState(() {
            _class_detail = [
              myClass.id_user,
              myClass.name,
              myClass.desmons,
              myClass.status,
            ];
            numberTopic = myClass.id_topic;
            _isSwitchOn = myClass.status.toLowerCase() == 'true';
            if (widget.userEmail == myClass.id_user) {
              _isSwitchVisible = true;
              canDelete = true;
            }
            print('Class detail: $_class_detail');
            print('Number topic: $numberTopic');
          });
        } else {
          print('Không nhận được dữ liệu cho lớp học với ID: $id_class');
          setState(() {
            _class_detail = ['','','',''];
          });
        }
      });
    } else {
      print('ID lớp học là null');
      setState(() {
        _class_detail = ['','','',''];
      });
    }
  }

  void fetchTopicFromFirebase() {
    topicRef.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> topicMap = snapshot.value as Map<dynamic, dynamic>;

        print('Dữ liệu topic nhận được: $topicMap'); // Debug dữ liệu topic nhận được

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

        print('Danh sách topic đã lọc: $filteredTopics'); // Debug danh sách topic đã lọc

        setState(() {
          topicList = filteredTopics;
          topic = filteredTopics.map((e) => e['id_topic'].toString()).toList();
        });
      } else {
        print('Không nhận được dữ liệu');
        setState(() {
          topicList = [];
          topic = [];
        });
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

    classRef.child(id_class!).child('id_topic').once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        // Chuyển đổi danh sách cố định thành danh sách động
        List<dynamic> data = List.from(snapshot.value as List<dynamic>);

        // Xóa mục tại vị trí index
        data.removeAt(index);
        print(data);

        // Cập nhật lại Firebase với danh sách mới
        if (data.isEmpty) {
          classRef.child('$id_class/id_topic').set({}).catchError((error) {
            print('Error updating topic in database: $error');
          });
        } else {
          classRef.child('$id_class/id_topic').set(data).catchError((error) {
            print('Error updating topic in database: $error');
          });
        }
      }
    }).catchError((error) {
      print('Error finding topic in database: $error');
    });
  }

  void pushdatatofirebase() {
    Map<String, dynamic> data = {
      'status': _isSwitchOn.toString(),
    };
    if (id_class != null) {
      classRef.child(id_class!).update(data).then((value) {
      }).catchError((error) {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_class_detail.length > 1 ? _class_detail[1] : 'Loading...'}'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_outlined,
            color: Color(0xFF7B66FF),
            size: 30,
          ),
          onPressed: () {
            pushdatatofirebase();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => List_Class(data: widget.userEmail)),
            );
          },
        ),
        actions: [
          Visibility(
            visible: _isSwitchVisible,
            child: IconButton(
              icon: Icon(
                Icons.add,
                color: Color(0xFF7B66FF),
                size: 30,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => List_Topic_InClass(data: widget.userEmail, id_class: id_class)),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              _class_detail.length > 2 ? _class_detail[2] : '',
              style: TextStyle(fontSize: 30),
              maxLines: 2,
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: _isSwitchVisible,
                  child: Flexible(
                    child: Text(
                      'Cho phép thành viên thêm học phần và thành viên mới',
                      maxLines: 2,
                    ),
                  ),
                ),
                Visibility(
                  visible: _isSwitchVisible,
                  child: Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Switch(
                        activeColor: Color(0xFF4CB9E7),
                        value: _isSwitchOn,
                        onChanged: (value) {
                          setState(() {
                            _isSwitchOn = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: topicList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    key: Key(topicList[index]['id_topic'].hashCode.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      if (canDelete) {
                        removeTopicFromFirebase(index);
                      }
                    },
                    confirmDismiss: (direction) async {
                      if (!canDelete) {
                        // Hiển thị thông báo không thể xóa nếu không có quyền
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text("Hành động bị từ chối"),
                            content: Text("Cưng nghĩ cưng là ai mà được phép xóa cái này vị ..."),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                              ),
                            ],
                          ),
                        );
                        return Future.value(false);
                      } else {
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
                      }
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
                            MaterialPageRoute(builder: (context) => TopicDetail(data: topicList[index]['id_topic'], userEmail: widget.userEmail)),
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
                                topicList[index]['name_topic'] ?? 'Unknown',
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
            ),
          ],
        ),
      ),
    );
  }
}
