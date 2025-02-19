import 'package:flutter/material.dart';


Container cardButton(BuildContext context, bool isLogin, Function onTap) {
  return Container(
    child: ElevatedButton(
      style: ButtonStyle(
        backgroundColor:
            WidgetStateProperty.all<Color>( Colors.white),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.all(20)),
        fixedSize: WidgetStateProperty.all<Size>(
            const Size.fromWidth(350)), // Set width of the button
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      onPressed: () {
        // Call onTap function if provided
        onTap();
      },
      child: Text(
        isLogin ? 'Log in' : 'Sign up',
        style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 18),
      ),
    ),
  );
}