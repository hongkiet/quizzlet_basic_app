import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();

    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = FirebaseAuth.instance.currentUser;

// Update password
    void changePassword(String currentPassword, String newPassword) async {
      if (currentUser != null) {
        try {
          AuthCredential credential = EmailAuthProvider.credential(
              email: currentUser.email!, password: currentPassword);
          await currentUser.reauthenticateWithCredential(credential);
          
          await currentUser.updatePassword(newPassword);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mật khẩu đã được cập nhật thành công.')),
          );
        } catch (e) {
         
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật mật khẩu không thành công. Vui lòng thử lại.')),
          );
        }
      } 
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thay đổi mật khẩu',
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
              String currentPassword = currentPasswordController.text.trim();
              String newPassword = newPasswordController.text.trim();
              changePassword(currentPassword, newPassword);
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
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Mật khẩu hiện tại',
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
            const SizedBox(height: 20),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Mật khẩu mới',
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
