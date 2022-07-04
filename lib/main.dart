import 'package:flutter/material.dart';
import 'package:person_info_app/views/person_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Person Info',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
     // home: MyHomePage(title: 'Flutter Demo Home Page'),
     home:PersonList()
    );
  }
}

