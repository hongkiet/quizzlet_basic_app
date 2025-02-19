import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:quizlet_app/screens/add_folder.dart';
import 'package:quizlet_app/screens/add_topic.dart';
import 'package:quizlet_app/screens/list_class.dart';
import 'package:quizlet_app/screens/list_folder.dart';
import 'package:quizlet_app/screens/list_topic.dart';
import 'package:quizlet_app/screens/new_class.dart';
import 'package:quizlet_app/screens/signin_screen.dart';
import 'package:quizlet_app/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizlet_app/screens/settings_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quizlet_app/utils.dart';
import 'package:iconsax/iconsax.dart';
class HomeScreen extends StatefulWidget {

  final String? data;

  const HomeScreen({Key? key, this.data}) : super(key: key);

  // const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<int>? _image;
  int _selectedIndex = 0;
  late TabController _tabController;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  late SharedPreferences _prefs;
  String? displayName;
  late String userName = '';
  late String email = '';


  String? email_user = '';





  @override
  void initState() {
    super.initState();
    _checkUserAuthentication();
    _tabController = TabController(length: _navBarItems.length, vsync: this);
    _loadImageFromPrefs();
     getUserData();
    // fetchItemsFromFirebase();
  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

void getUserData() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null && mounted) { // Kiểm tra xem widget còn được gắn vào cây widget không
    String userId = user.uid;
    DatabaseReference userRef = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(userId)
        .child('username');
    try {
      DataSnapshot snapshot = (await userRef.once()).snapshot;
      dynamic username = snapshot.value;
      if (mounted) { // Kiểm tra xem widget còn được gắn vào cây widget không
        setState(() {
          userName = username ?? "Loading...";
        });
      }
    } catch (error) {
      print('Failed to fetch username: $error');
    }
    if (mounted) { // Kiểm tra xem widget còn được gắn vào cây widget không
      setState(() {
        email = user.email!;
      });
    }
  }
}

void _checkUserAuthentication() async {
  _prefs = await SharedPreferences.getInstance();

    User? user = _auth.currentUser;
    email_user = user?.email;
    print(email_user);
    if (user == null) {
      // Navigator.pushReplacementNamed(context, '/login');
    } else {
    String userId = user.uid;
    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users').child(userId).child('username');
    userRef.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      dynamic username = snapshot.value;
      if (username != null) {
        setState(() {
          displayName = username.toString();
        });
        print('Username: $username');
      } else {
        print('Username is null');
      }
    }).catchError((error) {
      print('Failed to fetch username: $error');
    });
  }
}


  void _loadImageFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final imageBytes = _prefs.getString('profile_image');
    if (imageBytes != null) {
      setState(() {
        _image = imageBytes.codeUnits;
      });
    }
  }

  void _saveImageToPrefs(List<int> imageBytes) async {
    _prefs.setString('profile_image', String.fromCharCodes(imageBytes));
  }

  void _selectImage() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _updateProfileImage(File(pickedFile.path));
    }
  }

  void _selectImageFromStack() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _updateProfileImage(File(pickedFile.path));
    }
  }

  void _updateProfileImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('Người dùng chưa được xác thực');
      return;
    }

    try {
      final imageBytes = await imageFile.readAsBytes();
      _saveImageToPrefs(imageBytes);

      setState(() {
        _image = imageBytes;
      });

      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('profile_image.jpg');

      final uploadTask = ref.putData(imageBytes);

      await uploadTask
          .whenComplete(() => print('Hình ảnh được tải lên Firebase Storage'));

      final imageUrl = await ref.getDownloadURL();
      print('URL Tải xuống: $imageUrl');
    } catch (e) {
      print('Lỗi tải lên hình ảnh: $e');
    }
  }

  Widget buildProfileImage() {
    return GestureDetector(
      onTap: _selectImageFromStack,
      child: CircleAvatar(
        radius: 50,
        backgroundImage:
            _image != null ? MemoryImage(Uint8List.fromList(_image!)) : null,
        child: _image == null
            ? Image.network(
                'https://static.vecteezy.com/system/resources/previews/020/911/740/non_2x/user-profile-icon-profile-avatar-user-icon-male-icon-face-icon-profile-icon-free-png.png',
                width: 100,
                height: 100,
              )
            : null,
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Color(0xFF0F2167),
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 40.0, right: 40.0, top: 30.0),
              decoration: BoxDecoration(
                color: Color(0xFFFEFAF6),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Add_Topic(data: email_user)),
                  );
                },
                child: ListTile(
                  leading: Icon(Iconsax.additem, color: Color(0xFF0F2167)),
                  title: Text('Học phần',
                      style: TextStyle(fontSize: 16, color: Color(0xFF0F2167))),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 40.0, right: 40.0, top: 15.0),
              decoration: BoxDecoration(
                color: Color(0xFFFEFAF6),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Add_Folder(data: email_user)),
                  );
                },
                child: ListTile(
                  leading: Icon(Iconsax.folder, color: Color(0xFF0F2167)),
                  title: Text('Thư mục',
                      style: TextStyle(fontSize: 16, color: Color(0xFF0F2167))),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: 40.0, right: 40.0, top: 15.0, bottom: 30.0),
              decoration: BoxDecoration(
                color: Color(0xFFFEFAF6),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => New_Class(data: email_user)),
                  );
                },
                child: ListTile(
                  leading: Icon(Iconsax.building, color: Color(0xFF0F2167)),
                  title: Text('Lớp',
                      style: TextStyle(fontSize: 16, color: Color(0xFF0F2167))),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildTabContent(entry) {
    switch (entry) {
      case 'Trang chủ':
        return Container(
          color: Color(0xFFFEFAF6),
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: 70, left: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose what',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F2167)),
                        ),
                        Text('to learn today?',
                            style: TextStyle(
                                fontSize: 30, color: Color(0xFF0F2167))),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFFF1F1F1),
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Iconsax.search_normal, color: Color(0xFF0F2167)),
                          Text(
                            'Học phần, sách giáo khoa, câu hỏi',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF0F2167)),
                          ),
                          Icon(Iconsax.camera, color: Color(0xFF0F2167)),
                        ],
                      ),
                    )),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  'Thành tựu',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F2167)),
                ),
                const SizedBox(
                  height: 10,
                ),
                Scrollbar(
                  child: Container(
                    child: SingleChildScrollView(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: 300,
                              width: 180,
                              child: ElevatedButton(
                                onPressed: () {
                                   Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => List_Topic(data: email_user,)),
                                        );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFfbecd9),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/topic.png', // Đường dẫn đến tệp hình ảnh của bạn
                                      height:
                                          250, // Điều chỉnh kích thước hình ảnh theo ý muốn
                                      width: 200,
                                    ),
                                    Text(
                                      'Các chủ đề',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: 150,
                              width: 150,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => List_Folder(data: email_user,),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF4CB9E7),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/folder.png',
                                      height: 120,
                                      width: 120,
                                    ),
                                    Text(
                                      'Các thư mục',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 150,
                              width: 150,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => List_Class(data: email_user,),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF3559E0),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/class.png',
                                      height: 120,
                                      width: 120,
                                    ),
                                    Text(
                                      'Các lớp học',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                  ),
                ),
              ],
            ),
          ),
        );
        
      case 'Lời giải':
        return Container(
          color: Color(0xFFFEFAF6),

        );

      case '':
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          _showBottomSheet(); // Gọi hàm showBottomSheet mà không cần truyền context
        });
        return Container( color: Color(0xFFFEFAF6),);

      case 'Thư viện':
        return Container(
          color: Color(0xFFFEFAF6),
          padding: EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 45,
                  ),
                  const Expanded(
                    child: Text(
                      'Thư viện',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2167),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.add,
                      color: Color(0xFF0F2167),
                      size: 35,
                    ),
                  )
                ],
              ),
              const Text(
                'Nội dung của thư viện',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F2167),
                ),
              ),
            ],
          ),
        );

      case 'Hồ sơ':
        return FutureBuilder<User?>(
          future: _auth.authStateChanges().first,
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
             Text(' ${userName.isNotEmpty ? userName : 'Loading...'}');
              return Container(
                color: Color(0xFFFEFAF6),
                padding: EdgeInsets.only(top: 60, left: 20, right: 20),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Row(
                    children: [Image.asset(
                      'assets/setting.png', 
                      height: 70,
                      width: 70,
                    ),],
                   ),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        buildProfileImage(),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      ' ${userName.isNotEmpty ? userName : 'Loading...'}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2167),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 70,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SettingScreen(),
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Color(0xFFF1F1F1),
                          padding: EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Iconsax.setting, color: Color(0xFF0F2167)),
                            Text(
                              'Cài đặt của bạn',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0F2167),
                              ),
                            ),
                            Icon(Icons.navigate_next_outlined,
                                color: Color(0xFF0F2167)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        );

      default:
        return Container();
    }
  }

  Widget buildHomePage() {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _navBarItems.map(buildTabContent).toList(),
            ),
          ),
        ],
      ),
    );
  }

   @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
              indicatorColor: Color(0xFFFEFAF6),
              labelTextStyle: MaterialStateProperty.all(
                  TextStyle(color: Color(0xFFFEFAF6), fontSize: 12)))),
      child: Scaffold(
        body:
            Center(child: buildTabContent(_navBarItems[_selectedIndex].label)),
        bottomNavigationBar: NavigationBar(
          height: 80,
          backgroundColor: Color(0xFF0F2167),
          animationDuration: const Duration(seconds: 1),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: _navBarItems,
        ),
      ),
    );
  }
}

const _navBarItems = [
  NavigationDestination(
    icon: Icon(Iconsax.home, color: Color(0xFFFEFAF6)),
    selectedIcon: Icon(Iconsax.home, color: Color(0xFF0F2167)),
    label: 'Trang chủ',
  ),
  NavigationDestination(
    icon: Icon(Iconsax.book, color: Color(0xFFFEFAF6)),
    selectedIcon: Icon(Iconsax.book, color: Color(0xFF0F2167)),
    label: 'Lời giải',
  ),
  NavigationDestination(
    icon: Icon(Iconsax.add_circle, size: 40, color: Color(0xFFFEFAF6)),
    selectedIcon: Icon(Iconsax.add_circle, size: 40, color: Color(0xFF0F2167)),
    label: '',
  ),
  NavigationDestination(
    icon: Icon(Iconsax.folder, color: Color(0xFFFEFAF6)),
    selectedIcon: Icon(Iconsax.folder, color: Color(0xFF0F2167)),
    label: 'Thư viện',
  ),
  NavigationDestination(
    icon: Icon(Iconsax.user, color: Color(0xFFFEFAF6)),
    selectedIcon: Icon(Iconsax.user, color: Color(0xFF0F2167)),
    label: 'Hồ sơ',
  ),
];
