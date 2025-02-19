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
      home: Add_Folder(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Add_Folder extends StatefulWidget {

  final String? data;

  const Add_Folder({Key? key, this.data}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Add_Folder> {
  final TextEditingController _folder_nameController = TextEditingController();
  final TextEditingController _folder_desmontrateController = TextEditingController();
  bool _isFirstFieldFilled = false;

  final _folderRed = FirebaseDatabase.instance.reference().child('folder');

  //print(widget.data);

  void _pushdatatoFirebase(){
    String folderName = _folder_nameController.text;
    String folderDesmon = _folder_desmontrateController.text;
    String idTopic = '';

    final String folderId = _folderRed.push().key?? '';

    Map<String, dynamic> data = {
      'desmons': folderDesmon,
      'folder_name': folderName,
      'id_topic': idTopic,
      'id_user': widget.data,
    };

    _folderRed.child(folderId).set(data).then((value) {
      //print("đụược rồi");
      // Hiển thị thông báo thành công
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Thành công'),
            content: const Text('Chủ đề đã được tạo thành công.'),
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
            content: Text('Lưu dữ liệu thất bại:$error'),
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
        backgroundColor:const Color(0xfffffecd6) ,
        title: const Text('Thư mục mới',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F2167),
            )),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left,
              color: Color(0xFF0F2167), size: 30),
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
              icon: const Icon(Iconsax.document_download,
                  color: Color(0xFF0F2167), size: 30),
              onPressed: _pushdatatoFirebase,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _folder_nameController,
              onChanged: (value) {
                setState(() {
                  _isFirstFieldFilled = value.isNotEmpty;
                });
              },
              decoration: InputDecoration(
                labelText:
                    'Tiêu đề thư mục',
                labelStyle: const TextStyle(
                    color: Colors
                        .black45),
                filled: true,
                fillColor: const Color(0xFFFFECD6),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFFECD6)),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white60),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _folder_desmontrateController,
              decoration: InputDecoration(
                labelText:
                    'Mô tả (không bắt buộc)',
                labelStyle: const TextStyle(
                    color: Colors
                        .black45),
                filled: true,
                fillColor: const Color(0xFFFFECD6),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFFECD6)),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white60),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
