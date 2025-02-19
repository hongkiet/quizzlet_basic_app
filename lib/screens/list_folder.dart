import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quizlet_app/screens/folder_detail.dart';

import 'home_screen.dart';
// import 'package:iconsax/iconsax.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: List_Folder(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class List_Folder extends StatefulWidget {

  final String? data;

  const List_Folder({Key? key, this.data}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<List_Folder> {
  List<Map<String, dynamic>> folderList = [];
  DatabaseReference folderRef = FirebaseDatabase.instance.reference().child('folder');
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
        List<Map<String, dynamic>> folders = [];
        Map<dynamic, dynamic> folderMap = snapshot.value as Map<dynamic, dynamic>;
        folderMap.forEach((key, value) {
          if (value is Map) {
            Map<String, dynamic> newFolder = {
              "id_folder": key,
              "name_folder": value["folder_name"],
              "user_email": value["id_user"],
            };
            if (!folders.any((folder) => folder['id_folder'] == newFolder['id_folder'])) {
              if (value["id_user"] == widget.data) {
                folders.add(newFolder);
              }
            }
          }
        });
        setState(() {
          folderList = folders;
        });
        print(folderList);
      } else {
        print('Không nhận được dữ liệu');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
           backgroundColor: Color(0xFFEADBC8),
          title: Text('Danh sách thư mục',style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F2167),
          ),),
          leading: IconButton(
          icon: Icon(Iconsax.arrow_left,
              size: 30, color: Color(0xFF0F2167)),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          },
        ),
        ),
        body: ListView.builder(
          itemCount: folderList.length,
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(folderList[index].hashCode.toString()),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                setState(() {

                  folderRef.child(folderList[index]['id_folder']).remove();

                  folderList.removeAt(index);


                });
              },
              confirmDismiss: (direction) async {
                await showDialog(
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
                          child: Text('Chắc chắn'),
                        ),

                        SizedBox(width: 7,),

                        TextButton(
                          onPressed: () {
                            _shouldDelete = false;
                            Navigator.of(context).pop(false);
                          },
                          child: Text('Huỷ'),
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
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete_outline, color: Colors.white),
              ),
              child: Expanded(
                child: InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Folder_Detail(data: folderList[index]['id_folder'], userEmail: widget.data,)),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFFFECD6)),
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFFFFECD6),
                    ),
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${folderList[index]['name_folder']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Tạo bởi: ${folderList[index]['user_email']}',
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
        )

    );
  }
}
