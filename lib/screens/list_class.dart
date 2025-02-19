import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quizlet_app/screens/class_detail.dart';

import 'home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: List_Class(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class List_Class extends StatefulWidget {
  final String? data;

  const List_Class({Key? key, this.data}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<List_Class> {
  List<Map<String, dynamic>> class_List = [];
  DatabaseReference folderRef = FirebaseDatabase.instance.reference().child('class');
  bool _shouldDelete = false;

  @override
  void initState() {
    super.initState();
    fetchItemsFromFirebase();
  }

  void fetchItemsFromFirebase() {
    folderRef.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        List<Map<String, dynamic>> classes = [];
        Map<dynamic, dynamic> class_Map = snapshot.value as Map<dynamic, dynamic>;
        class_Map.forEach((key, value) {
          if (value is Map) {
            String topics;
            if (value['id_topic'] is List) {
              topics = (value['id_topic'] as List).join(',');
            } else if (value['id_topic'] is String) {
              topics = value['id_topic'];
            } else {
              topics = '';
            }

            Map<String, dynamic> newClass = {
              "id_class": key,
              "name_class": value["class_name"],
              "user_email": value["id_user"],
              "topic": topics,
              "status": value["status"].toString(),
              "desmon": value["desmons"] ?? '',
            };

            // print(newClass);
            if (!classes.any((cla) => cla['id_class'] == newClass['id_class'])) {
              if (value["id_user"] == widget.data || value["status"] == "true") {
                classes.add(newClass);
              }
            }

          }
        });
        setState(() {
          class_List = classes;
          // print(class_List);
        });
      } else {
        print('Không nhận được dữ liệu');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_outlined,
            color: Color(0xFF7B66FF),
            size: 30,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: ListView.builder(
        itemCount: class_List.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(class_List[index].hashCode.toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              setState(() {
                folderRef.child(class_List[index]['id_class']).remove();
                class_List.removeAt(index);
              });
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
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Class_Detail(data: class_List[index]['id_class'], userEmail: widget.data)),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF4CB9E7)),
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xFFF0D6FA),
                ),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${class_List[index]['name_class']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.people_alt_outlined,
                          size: 40,
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${class_List[index]['topic'].isEmpty ? 0 : class_List[index]['topic'].split(',').length} học phần',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${class_List[index]['user_email'].split(',').length} thành viên',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
