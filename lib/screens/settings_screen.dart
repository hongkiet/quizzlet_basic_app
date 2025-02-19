import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:quizlet_app/screens/change_password_screen.dart';
import 'package:quizlet_app/screens/change_username_screen.dart';
import 'package:quizlet_app/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late String userName = '';
  late String email = '';
  late TextEditingController recentPasswordController = TextEditingController();
  bool _isSigning = false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users').child(userId).child('username');
      try {
        DataSnapshot snapshot = (await userRef.once()).snapshot;
        dynamic username = snapshot.value;
        setState(() {
          userName = username ?? "Loading..."; 
        });
      } catch (error) {
        print('Failed to fetch username: $error');
      }
      setState(() {
        email = user.email!; 
      });
    }
  }




  Future<void> signOut() async {
    setState(() {
      _isSigning = true;
    });
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('isLoggedIn');
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SignInScreen()));
    } catch (e) {
      print("Đã xảy ra lỗi khi đăng xuất: $e");
    } finally {
      setState(() {
        _isSigning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEADBC8),
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F2167),
          ),
        ),
        centerTitle: true,
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Container(
            color: const Color(0xFFFEFAF6),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin cá nhân',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet<void>(
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          color: const Color(0xFFEADBC8),
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 30,
                                left: 20,
                                right: 20,
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text(
                                  'Vui lòng xác minh tài khoản của bạn',
                                  style: TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black45),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  'Để xác nhận đây là bạn, vui lòng xác minh mật khẩu letquiz. của bạn.',
                                  style: TextStyle(
                                      color: Colors.black45, fontSize: 15),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  obscureText: true,
                                  controller: recentPasswordController,
                                  decoration: InputDecoration(
                                    hintText: 'Mật khẩu',
                                    hintStyle:
                                        const TextStyle(fontWeight: FontWeight.bold),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 50,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      bool isPasswordCorrect =
                                          await validatePassword(
                                              recentPasswordController.text);
                                      if (isPasswordCorrect) {
                                        Navigator.pop(context);
                                        final newUsername =
                                            await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ChangeUsernameScreen()),
                                        );
                                        if (newUsername != null) {
                                          setState(() {
                                            userName = newUsername;
                                          });
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Mật khẩu không chính xác'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'Gửi',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F2167)),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 50,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Huỷ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F2167)),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: ListTile(
                    title: Text(
                        'Tên người dùng: ${userName.isNotEmpty ? userName : 'Loading...'}'),
                    trailing: const Icon(Icons.navigate_next),
                  ),
                ),
                const Divider(),
                ListTile(
                  title:
                      Text('Email: ${email.isNotEmpty ? email : 'Loading...'}'),
                  // trailing: Icon(Icons.navigate_next),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Đổi mật khẩu'),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen()));
                  },
                ),
                const Divider(),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Học ngoại tuyến',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: const Text('Lưu học phần để học ngoại tuyến'),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  title: const Text('Quản lí dung lượng lưu trữ'),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {},
                ),
                const Divider(),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Ưu tiên',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: const Text('Thông báo đẩy'),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  title: const Text('Hiệu ứng âm thanh'),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {},
                ),
                const Divider(),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Giới thiệu',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(
                  height: 10,
                ),
                ListTile(
                  title: const Text('Quyền riêng tư'),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  title: const Text('Điều khoản dịch vụ'),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  title: const Text('Giấy phép mã nguồn mở'),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  title: const Text('Trung tâm hỗ trợ'),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () {},
                ),
                const Divider(),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSigning
                        ? null
                        : signOut, // Disable button khi đang đăng xuất
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: _isSigning
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Đăng xuất',
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: const Text(
                      'Xoá tài khoản',
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Validate the password
  Future<bool> validatePassword(String password) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.email!,
        password: password,
      );
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print('Error validating password: $e');
    return false;
  }
}


  @override
  void dispose() {
    recentPasswordController.dispose();
    super.dispose();
  }
}
