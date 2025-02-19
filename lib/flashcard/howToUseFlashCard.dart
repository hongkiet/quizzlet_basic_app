// import 'package:flutter/material.dart';
// import 'flashcard_screen.dart';
// import 'quizz_screen.dart';
// import 'typing_screen.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Example vocabulary list
//     List<String> vocabulary = [
//       'hot:nóng',
//       'cold:lạnh',
//       'warm:ấm',
//       'handsome:đẹp trai',
//       'beautiful:xinh đẹp',
//       'boy:con trai',
//       'girl:con gái',
//       'fish:con cá',
//       'cat:con mèo',
//       'duck:con vịt',
//       'dog:con chó',
//       'bird:con chim',
//       'elephant:con voi',
//       'tiger:con hổ',
//       'lion:sư tử',
//       'snake:rắn',
//       'monkey:con khỉ',
//       'ant:con kiến',
//       'bee:con ong',
//       'butterfly:bướm',
//       'spider:con nhện',
//       'mosquito:con muỗi',
//       'fly:con ruồi',
//     ];

//     return MaterialApp(
//       home: HomeScreen(vocabulary: vocabulary),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   final List<String> vocabulary;

//   HomeScreen({required this.vocabulary});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Choose Function'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // ElevatedButton(
//             //   onPressed: () {
//             //     Navigator.push(
//             //       context,
//             //       // MaterialPageRoute(
//             //       //   // builder: (context) => FlashcardScreen(vocabulary: vocabulary),
//             //       // ),
//             //     );
//             //   },
//             //   child: Text('Flashcards'),
//             // ),
//             SizedBox(height: 20),
//             // ElevatedButton(
//             //   onPressed: () {
//             //     Navigator.push(
//             //       context,
//             //       MaterialPageRoute(
//             //         builder: (context) => QuizScreen(vocabulary: vocabulary),
//             //       ),
//             //     );
//             //   },
//             //   child: Text('Quiz'),
//             // ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => TypingPracticeScreen(vocabulary: vocabulary),
//                   ),
//                 );
//               },
//               child: Text('Typing Practice'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
