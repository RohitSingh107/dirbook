import 'dart:convert';

import 'package:dir_book/bookmarks/bookmarks.dart';
import 'package:dir_book/mainPage/mainPage.dart';
import 'package:flutter/material.dart';
import 'package:dir_book/main.dart';
import 'package:flutter/services.dart';

Future<void> loadData() async {
  print("Loading Starts...");
  await Future.delayed(const Duration(seconds: 2));

  String jsonString = await rootBundle.loadString("assets/bookmarks.json");

  Map<String, dynamic> decodedJson = jsonDecode(jsonString);

  BookMarks.setOfBookmarks = decodedJson;

  print("Suceessfully Loaded");
}

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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    loadData();

    return MainPage(
      bm: BookMarks.setOfBookmarks,
      parentRoot: "/",
    );
  }
}
