import 'dart:async';
import 'dart:convert';

import 'package:dir_book/bookmark_storage/bookmarks_storage.dart';
import 'package:dir_book/mainPage/mainPage.dart';
import 'package:dir_book/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

// Widget? root;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  //This widget is the root of My application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      theme: MyTheme.lightTheme(context),
      darkTheme: MyTheme.darkTheme(context),
      title: 'Flutter Demo',
      home: MyHomePage(bmStorage: BookMarkStorage()),
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
  late StreamSubscription _intentDataStreamSubscription;
  @override
  void initState() {
    super.initState();
    widget.bmStorage.readStorage().then((value) {
      setState(() {
        Map<String, dynamic> decodedJson = jsonDecode(value);
        widget.bmStorage.setOfBookmarks = decodedJson;
      });
    });

    //------------------------------------

    //This shared intent work when application is in memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return SharePage(
          sharedLink: value,
        );
      }));
    });

    //-----------------------------------------

    // ------------------------------------------------
    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      if (value != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SharePage(
            sharedLink: value,
          );
        }));
      }
    });
    //------------------------------------------------

    @override
    void dispose() {
      super.dispose();
      _intentDataStreamSubscription.cancel();
    }
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

// Future<Widget> routeToCorrectPage() async {
//   String? sharedValue = await ReceiveSharingIntent.getInitialText();
//   if (sharedValue != null) {
//     return SharePage(sharedLink: sharedValue);
//   }

//   return MyHomePage(bmStorage: BookMarkStorage());
// }
