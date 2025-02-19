import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ChangeUsernameScreen extends StatelessWidget {
  const ChangeUsernameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController newUsernameController = TextEditingController();

    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = FirebaseAuth.instance.currentUser;

    void changeDisplayName(String newDisplayName, BuildContext context) async {
      if (currentUser != null) {
        try {
          await currentUser.updateProfile(displayName: newDisplayName);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tên người dùng đã được cập nhật thành công.'),
            ),
          );

          DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users').child(currentUser.uid).child('username');
          await userRef.set(newDisplayName);

          Navigator.of(context).pushNamedAndRemoveUntil(
            '/', 
            (route) => false,
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật tên người dùng không thành công. Vui lòng thử lại.'),
            ),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thay đổi tên người dùng',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              String newDisplayName = newUsernameController.text.trim();
              changeDisplayName(newDisplayName, context); 
            },
            child: const Text(
              'Lưu',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: newUsernameController,
              decoration: InputDecoration(
                hintText: 'Tên người dùng mới',
                hintStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black45,
                ),
                filled: true,
                fillColor: const Color(0xFFFFECD6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
