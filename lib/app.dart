import 'package:flutter/material.dart';
import 'pages/home_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sinoniza',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        fontFamily: 'Bangers',
        primaryTextTheme: TextTheme(
          title: TextStyle(
            color: Color(0xFF2B4BB5),
            fontSize: 24.0,
          ),
          body1: TextStyle(
            color: Colors.red,
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}
