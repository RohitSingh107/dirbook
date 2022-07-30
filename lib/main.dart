import 'dart:async';
import 'dart:convert';
import 'package:dir_book/bookmark_storage/bookmarks_storage.dart';
import 'package:dir_book/pages/folderSelect.dart';
import 'package:dir_book/pages/mainPage.dart';
import 'package:dir_book/theme/themes.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

late final String jsonString;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  jsonString = await BookMarkStorage().readStorage();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

//     widget.bmStorage.readStorage().then((value) {
//       setState(() {
//         Map<String, dynamic> decodedJson = jsonDecode(value);
//         widget.bmStorage.setOfBookmarks = decodedJson;
//       });
//     });
    setState(() {
      Map<String, dynamic> decodedJson = jsonDecode(jsonString);
      widget.bmStorage.setOfBookmarks = decodedJson;
    });
    //------------------------------------

    //This shared intent work when application is in memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return FolderSelect(
          bm: BookMarkStorage().setOfBookmarks,
          parentRoot: "/",
          paste: false,
          link: value,
        );
      }));
    });

    // ------------------------------------------------
    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      if (value != null) {
        // print("S link is ${value}");
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return FolderSelect(
            bm: BookMarkStorage().setOfBookmarks,
            parentRoot: "/",
            paste: false,
            link: value,
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
