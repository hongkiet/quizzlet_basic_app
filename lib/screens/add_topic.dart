import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quizlet_app/screens/home_screen.dart';
import 'package:firebase_database/firebase_database.dart';

import '../firebase_options.dart';

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
      home: Add_Topic(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Add_Topic extends StatefulWidget {
  final String? data;

  const Add_Topic({Key? key, this.data}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Add_Topic> {
  var _topicRef = FirebaseDatabase.instance.reference().child('topic');

  List<ListItemController> _listItemControllers = [ListItemController()];

  var _topicController = TextEditingController();

  bool _public = false;

  bool _isFormFieldEmpty(TextEditingController controller) {
    return controller.text.isEmpty;
  }

  void _pushDatatoFirebase() {
    if (_isFormFieldEmpty(_topicController)) {
      // Hiển thị thông báo lỗi nếu TextFormField chủ đề trống
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
      return; // Dừng hàm nếu có ô trống
    }

    // Kiểm tra trạng thái của các TextFormField trong danh sách ListItemController
    for (var controller in _listItemControllers) {
      if (_isFormFieldEmpty(controller.wordController) ||
          _isFormFieldEmpty(controller.meaningController)) {
        // Hiển thị thông báo lỗi nếu có ô trống trong ListItemController
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
        return; // Dừng hàm nếu có ô trống
      }
    }

    String topic = _topicController.text;
    List<String> word_meaning = [];

    _listItemControllers.forEach((itemController) {
      String word = itemController.wordController.text;
      String meaning = itemController.meaningController.text;
      word_meaning.add("$word:$meaning");
    });

    Map<String, dynamic> data = {
      'name_topic': topic,
      'value': word_meaning,
      'id_user': widget.data,
      'public': _public.toString()
    };

    // final DatabaseReference topicRef = FirebaseDatabase.instance.ref('topic');
    final String topicId = _topicRef.push().key ?? '';

    //print (topicId);

    _topicRef.child(topicId).set(data).then((value) {
      //print("đụược rồi");
      // Hiển thị thông báo thành công
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thành công'),
            content: Text('Chủ đề đã được tạo thành công rùi nha gái :)'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }).catchError((error) {
      //print("Lỗi rồi");
      // Hiển thị thông báo lỗi
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Lỗi'),
            content: Text('Lưu dữ liệu thất bại rùi gái ơiiiiii :( $error'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tạo học phần',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F2167),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left,
              size: 30, color: Color(0xFF0F2167)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Iconsax.tick_circle, size: 30, color: Color(0xFF0F2167)),
            onPressed: _pushDatatoFirebase,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 50, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Cho phép mọi người được xem nó',
                        maxLines: 2,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Switch(
                          activeColor: Color(0xFF4CB9E7),
                          value: _public,
                          onChanged: (value) {
                            setState(() {
                              _public = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
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
                            SnackBar(content: Text('Item removed')));
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFFECD6),
                              offset: Offset(5, 5),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ],
                          // border: Border.all(color: Color(0xFF625DB9)),
                          borderRadius: BorderRadius.circular(7),
                          color: Color(0xFFFFECD6),
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
                SizedBox(height: 10),
              ],
            ),
          ),

          SizedBox(height: 10,),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _listItemControllers.add(ListItemController());
                  });
                },
                icon: Icon(
                  Iconsax.add_circle,
                  color: Color(0xFF0F2167),
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListItemController {
  TextEditingController wordController = TextEditingController();
  TextEditingController meaningController = TextEditingController();
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
              labelStyle: TextStyle(
                  color:
                      Colors.black45), 
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
          SizedBox(
            height: 10,
          ),
          Divider(color: Colors.white60),
          TextFormField(
            controller: controller.meaningController,
            maxLines: 1,
            decoration: InputDecoration(
              labelText: 'Định nghĩa', // Thay helperText bằng labelText
              labelStyle: TextStyle(
                  color:
                      Colors.black45), // Sử dụng labelStyle thay vì helperStyle
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
        ],
      ),
    );
  }
}
