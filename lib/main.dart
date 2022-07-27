import 'dart:convert';

import 'package:dir_book/bookmark_storage/bookmarks_storage.dart';
import 'package:dir_book/mainPage/mainPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  //This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(
        bmStorage: BookMarkStorage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  BookMarkStorage bmStorage;
  MyHomePage({super.key, required this.bmStorage});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    widget.bmStorage.readStorage().then((value) {
      setState(() {
        Map<String, dynamic> decodedJson = jsonDecode(value);
        widget.bmStorage.setOfBookmarks = decodedJson;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainPage(
      bm: widget.bmStorage.setOfBookmarks,
      parentRoot: "/",
    );
  }
}
