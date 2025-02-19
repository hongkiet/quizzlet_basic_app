import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_app/screens/home_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quizlet_app/screens/topic_details.dart';

import '../firebase_options.dart';

class MyTopic {
  String email;
  String type;
  String status;
  Map<String, String> words;

  MyTopic({
    required this.email,
    required this.type,
    required this.status,
    required this.words,
  });

  factory MyTopic.fromMap(Map<String, dynamic> map) {
    var words = map['value'];
    Map<String, String> convertedWords = {};

    if (words is Map) {
      convertedWords = Map<String, String>.from(words);
    } else if (words is List) {
      // Gọi hàm chuyển đổi từ List sang Map
      convertedWords = listToMap(words);
    }

    return MyTopic(
      email: map['id_user'],
      type: map['name_topic'],
      status: map['public'].toString(),
      words: convertedWords,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id_user': email,
      'name_topic': type,
      'public': status,
      'value': words,
    };
  }
}

Map<String, String> listToMap(List<dynamic> list) {
  Map<String, String> map = {};
  for (var item in list) {
    if (item is String && item.contains(':')) {
      var parts = item.split(':');
      if (parts.length == 2) { // Kiểm tra để tránh lỗi nếu chuỗi không có dấu ':'
        var key = parts[0].trim();
        var value = parts[1].trim();
        map[key] = value;
      }
    }
  }
  return map;
}



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Topic_change(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Topic_change extends StatefulWidget {

  final String? data;


  final String? userEmail;

  const Topic_change({Key? key, this.data, this.userEmail}) : super(key: key);


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Topic_change> {
  DatabaseReference topicRef = FirebaseDatabase.instance.reference().child('topic');

  List<ListItemController> _listItemControllers = [];
  var _topicController = TextEditingController();

  List<String> _topicDetail = [];
  int count = 0;

  List<String> numberTopic = [];
  List<Map<String, String>> topicDetail = [];

  String user_email = '';

  bool _public = false;

  bool _isSwitchVisible = false;

  late List<TextEditingController> _wordControllers;
  late List<TextEditingController> _meaningControllers;

  bool _isFormFieldEmpty(TextEditingController controller) {
    return controller.text.isEmpty;
  }

  String? idTopic;

  @override
  void initState() {
    super.initState();
    idTopic = widget.data;
    fetchItemsFromFirebase();
  }

  @override
  void dispose() {
    _wordControllers.forEach((controller) => controller.dispose());
    _meaningControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void fetchItemsFromFirebase() {
    if (idTopic != null) {
      topicRef.child(idTopic!).onValue.listen((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          Map<String, dynamic> dataMap = Map<String, dynamic>.from(snapshot.value as Map);
          MyTopic myTopic = MyTopic.fromMap(dataMap);

          setState(() {
            _topicDetail = [
              myTopic.email,
              myTopic.type,
              myTopic.status.toString(),
            ];

            numberTopic = myTopic.words != null
                ? myTopic.words.entries.map((e) => '${e.key}:${e.value}').toList()
                : [];
            count = numberTopic.length;

            print(_topicDetail);

            bool switchStatus = _topicDetail[2].toLowerCase() == 'true';

            topicDetail = numberTopic.map((e) {
              List<String> pair = e.split(':');
              return {
                'term': pair[0].trim(),
                'definition': pair[1].trim()
              };
            }).toList();

            _topicController.text = myTopic.type;
            user_email = myTopic.email;
            _public = switchStatus;

            if (widget.userEmail == myTopic.email) {
              _isSwitchVisible = true;
            }

            _wordControllers = topicDetail.map((pair) => TextEditingController(text: pair['term'])).toList();
            _meaningControllers = topicDetail.map((pair) => TextEditingController(text: pair['definition'])).toList();

            _listItemControllers = List.generate(count, (index) {
              return ListItemController(
                wordController: _wordControllers[index],
                meaningController: _meaningControllers[index],
              );
            });
          });
        } else {
          print('Không nhận được dữ liệu cho topic với ID: $idTopic');
        }
      });
    } else {
      print('ID topic là null');
    }
  }


  void _pushDatatoFirebase() {
    if (_isFormFieldEmpty(_topicController)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Lỗi'),
            content: Text('Vui lòng nhập chủ đề.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    for (var controller in _listItemControllers) {
      if (_isFormFieldEmpty(controller.wordController) ||
          _isFormFieldEmpty(controller.meaningController)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Lỗi'),
              content:
              Text('Vui lòng nhập đầy đủ thông tin cho từng thuật ngữ.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }
    }

    String topic = _topicController.text;
    List<String> wordMeaning = [];

    _listItemControllers.forEach((itemController) {
      String word = itemController.wordController.text;
      String meaning = itemController.meaningController.text;
      wordMeaning.add("$word:$meaning");
    });

    Map<String, dynamic> data = {
      'name_topic': topic,
      'value': wordMeaning,
      'id_user': user_email,
      'public': _public.toString()
    };

    if (idTopic != null) {
      topicRef.child(idTopic!).update(data).then((value) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Thành công'),
              content: Text('Chủ đề đã được lưu thành công.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, (widget.data, widget.userEmail),);
                  },
                  child: Text('OK'),
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
              title: Text('Lỗi'),
              content: Text('Lưu dữ liệu thất bại: $error'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
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
        title: Text(
          'Chỉnh sửa chủ đề',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F2167),
          ),
        ),
        centerTitle: true,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back_outlined, size: 30, color: Color(0xFF0F2167)),
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => TopicDetail(data: widget.data, userEmail: widget.userEmail,)),
        //     );
        //   },
        // ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, size: 30, color: Color(0xFF0F2167)),
            onPressed: _pushDatatoFirebase,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                      visible: _isSwitchVisible,
                      child: Flexible(
                        child: Text('Cho phép mọi người được xem nó',
                          maxLines: 2,),
                      ),
                    ),
                    Visibility(
                      visible: _isSwitchVisible,
                      child: Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Switch(
                            activeColor: Colors.blue,
                            value: _public,
                            onChanged: (value) {
                              setState(() {
                                _public = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15,),


                TextFormField(
                  controller: _topicController,
                  decoration: InputDecoration(
                    hintText: 'Chủ đề, chương, đơn vị',
                    hintStyle: TextStyle(color: Colors.black45),
                    labelText: 'Tiêu đề',
                    filled: true,
                    fillColor: Color(0xFFFFECD6),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFFECD6)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white60),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Nội dung',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    return Dismissible(
                      key: Key(_listItemControllers[index].hashCode.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        setState(() {
                          _listItemControllers.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Item removed'))
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Color(0xFFF0D6FA),
                        ),
                        child: ListItem(
                          controller: _listItemControllers[index],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 20);
                  },
                  itemCount: _listItemControllers.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                ),
                SizedBox(height: 30),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _listItemControllers.add(ListItemController());
                        });
                      },
                      child: Icon(Icons.add_circle_outlined, color: Colors.pinkAccent, size: 30,),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListItemController {
  TextEditingController wordController;
  TextEditingController meaningController;

  ListItemController({TextEditingController? wordController, TextEditingController? meaningController})
      : this.wordController = wordController ?? TextEditingController(),
        this.meaningController = meaningController ?? TextEditingController();
}

class ListItem extends StatelessWidget {
  final ListItemController controller;

  const ListItem({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextFormField(
            controller: controller.wordController,
            maxLines: 1,
            decoration: InputDecoration(
              labelText: 'Thuật ngữ',
              labelStyle: TextStyle(color: Colors.black),
              filled: true,
              fillColor: Color(0xFF96EFFF),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF96EFFF)),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white60),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 10),
          Divider(color: Colors.white60),
          TextFormField(
            controller: controller.meaningController,
            maxLines: 1,
            decoration: InputDecoration(
              labelText: 'Định nghĩa',
              labelStyle: TextStyle(color: Colors.black),
              filled: true,
              fillColor: Color(0xFF96EFFF),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF96EFFF)),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white60),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}