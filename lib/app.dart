import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'styles.dart';

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
            color: AppColors.blue,
            fontSize: 24.0,
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}
