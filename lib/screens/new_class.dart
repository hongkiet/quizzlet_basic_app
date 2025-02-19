import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quizlet_app/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: New_Class(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class New_Class extends StatefulWidget {

  final String? data;

  const New_Class({Key? key, this.data}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<New_Class> {
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _classdemonsController = TextEditingController();
  bool _isFirstFieldFilled = false;
  bool _isSwitchOn = false;

  final _classRed = FirebaseDatabase.instance.reference().child('class');


  void _pushdatatoFirebase(){
    String className = _classController.text;
    String classDesmon = _classdemonsController.text;
    String idTopic = '';

    final String classId = _classRed.push().key?? '';


    Map<String, dynamic> data = {
      'desmons': classDesmon,
      'class_name': className,
      'status': _isSwitchOn.toString(),
      'id_topic': idTopic,
      'id_user': widget.data,
    };


    _classRed.child(classId).set(data).then((value) {
      //print("đụược rồi");
      // Hiển thị thông báo thành công
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Thành công'),
            content: const Text('Chủ đề đã được tạo thành công rùi nha gái :)'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: const Text('OK'),
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
            title: const Text('Lỗi'),
            content: Text('Lưu dữ liệu thất bại rùi gái ơiiiiii :( $error'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: const Text('OK'),
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
        centerTitle: true,
        backgroundColor: const Color(0xFFEADBC8),
        title: const Text(
          'Lớp Mới',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F2167),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left,
              color: Color(0xFF0F2167), ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        actions: [
          Visibility(
            visible: _isFirstFieldFilled,
            child: IconButton(
              icon: const Icon(
                Iconsax.document_download,
                color: Color(0xFF0F2167),
                size: 25,
              ),
              onPressed: () {
                _pushdatatoFirebase();
              },
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFEFAF6),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _classController,
                decoration: const InputDecoration(
                  hintText: 'Môn học, khóa học, niên học, v.v...',
                  hintMaxLines: 1,
                  helperText: 'Tên lớp',
                ),
                onChanged: (value) {
                  setState(() {
                    _isFirstFieldFilled = value.isNotEmpty;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _classdemonsController,
                decoration: const InputDecoration(
                  hintText: 'Thông tin bổ sung (không bắt buộc)',
                  hintMaxLines: 5,
                  helperText: 'Mô tả',
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text('Cho phép thành viên thêm học phần và thành viên mới',
                    maxLines: 2,),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Switch(
                        activeColor: const Color(0xFF4CB9E7),
                        value: _isSwitchOn,
                        onChanged: (value) {
                          setState(() {
                            _isSwitchOn = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
