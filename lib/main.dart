import 'dart:convert';

import 'package:dir_book/bookmark_storage/bookmarks_storage.dart';
import 'package:dir_book/mainPage/mainPage.dart';
import 'package:dir_book/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

// Widget? root;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Widget root = await routeToCorrectPage();
  runApp(MyApp(
    home: root,
  ));
}

class MyApp extends StatelessWidget {
  Widget? home;
  MyApp({Key? key, required this.home}) : super(key: key);

  //This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      theme: MyTheme.lightTheme(context),
      darkTheme: MyTheme.darkTheme(context),
      title: 'Flutter Demo',
      // home: MyHomePage(
      //   bmStorage: BookMarkStorage(),
      // ),
      home: home,
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

class SharePage extends StatefulWidget {
  final String sharedLink;
  SharePage({super.key, required this.sharedLink});
  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Share link"),
      ),
      body: Container(
        child: Text("Shared Link is ${widget.sharedLink}"),
      ),
    );
  }
}

Future<Widget> routeToCorrectPage() async {
  String? sharedValue = await ReceiveSharingIntent.getInitialText();
  if (sharedValue != null) {
    return SharePage(sharedLink: sharedValue);
  }

  return MyHomePage(bmStorage: BookMarkStorage());
}
