import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quizlet_app/screens/signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2167),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'letquiz.',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              TextFormField(
                controller: _usernameController,
                style: const TextStyle(color: Color(0xFF0F2167)),
                decoration: InputDecoration(
                  hintText: 'Tên người dùng',
                  hintStyle: const TextStyle(color: Color(0xFF0F2167)),
                  filled: true,
                  fillColor: const Color(0xFFFEFAF6),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFEFAF6)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFEFAF6)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Color(0xFF0F2167)),
                decoration: InputDecoration(
                  hintText: 'example@email.com',
                  hintStyle: const TextStyle(color: Color(0xFF0F2167)),
                  filled: true,
                  fillColor: const Color(0xFFFEFAF6),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFEFAF6)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFEFAF6)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorText: emailError,
                  errorStyle: const TextStyle(color: Colors.redAccent),
                ),
                onChanged: (value) {
                  setState(() {
                    emailError = _validateEmail(value);
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                style: const TextStyle(color: Color(0xFF0F2167)),
                decoration: InputDecoration(
                  hintText: 'Tạo mật khẩu của bạn',
                  hintStyle: const TextStyle(color: Color(0xFF0F2167)),
                  filled: true,
                  fillColor: const Color(0xFFFEFAF6),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFEFAF6)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFEFAF6)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorText: passwordError,
                  errorStyle: const TextStyle(color: Colors.redAccent),
                ),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    passwordError = _validatePassword(value);
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                style: const TextStyle(color: Color(0xFF0F2167)),
                decoration: InputDecoration(
                  hintText: 'Xác nhận mật khẩu của bạn',
                  hintStyle: const TextStyle(color: Color(0xFF0F2167)),
                  filled: true,
                  fillColor: const Color(0xFFFEFAF6),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFEFAF6)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFEFAF6)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorText: confirmPasswordError,
                  errorStyle: const TextStyle(color: Colors.redAccent),
                ),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    confirmPasswordError = _validateConfirmPassword(value);
                  });
                },
              ),
              const SizedBox(height: 250),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      const Color(0xFFFEFAF6),
                    ),
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(20),
                    ),
                    shape: WidgetStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Đăng ký',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0F2167),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInScreen()),
                  );
                },
                child: const Text(
                  'Bạn đã có tài khoản? Đăng nhập',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    setState(() {
      confirmPasswordError = _validateConfirmPassword(_confirmPasswordController.text);
    });

    if (passwordError == null && confirmPasswordError == null) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn đã đăng ký thành công!'),
            duration: Duration(seconds: 2),
          ),
        );

        writeUsername(_usernameController.text, userCredential.user!.uid);

        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _usernameController.clear();

        print('User registered: ${userCredential.user!.email}');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          setState(() {
            passwordError = 'Mật khẩu quá yếu';
          });
        } else if (e.code == 'email-already-in-use') {
          setState(() {
            emailError = 'Email đã được sử dụng';
          });
        }
      } catch (e) {
        print(e);
      }
    }
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email không được bỏ trống';
    } else if (!value.contains('@') || !value.contains('.')) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Mật khẩu không được bỏ trống';
    } else if (value.length < 6) {
      return 'Mật khẩu phải chứa ít nhất 6 ký tự';
    }
    return null;
  }

  String? _validateConfirmPassword(String value) {
    if (value.isEmpty) {
      return 'Xác nhận mật khẩu không được bỏ trống';
    } else if (value != _passwordController.text) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }

  void writeUsername(String username, String id) {
    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users').child(id);
    userRef.set({'username': username});
  }
}

void main() {
  runApp(const MaterialApp(
    title: 'Sign Up Demo',
    home: SignUpScreen(),
  ));
}
