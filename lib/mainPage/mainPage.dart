import 'package:dir_book/bookmarks/bookmarks.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class MainPage extends StatefulWidget {
  Map<String, dynamic> bm;
  String parentRoot;

  MainPage({Key? key, required this.bm, required this.parentRoot})
      : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parentRoot),
      ),
      body: ListView.builder(
        itemCount: widget.bm.length,
        itemBuilder: (BuildContext context, int index) {
          List<String> listOfItems = widget.bm.keys.toList();

          bool check = widget.bm[listOfItems[index]].runtimeType == String;

          return check
              ? bookmarkTile(context, widget.bm, listOfItems, index)
              : directoryTile(context, widget.bm, listOfItems, index);
        },
      ),
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            title: const Text('Import'),
            onTap: () async {
              bool sucess = await BookMarkStorage().importData();
              if (sucess) {
                Restart.restartApp();
              } else {
                await importFailedDialog(
                    context); // This might cause issues ----------------------------------------------------------------------------------
              }
            },
          ),
          ListTile(
            title: const Text('Export'),
            onTap: () async {
              // ------------------------------------------------------------------------

              // ------------------------------------------------------------------------
            },
          ),
        ],
      )),
    );
  }
}

ListTile directoryTile(BuildContext context, Map<String, dynamic> bm,
    List<String> listOfItems, int index) {
  return ListTile(
    title: Text(listOfItems[index]),
    leading: Icon(Icons.folder),
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MainPage(
          bm: bm[listOfItems[index]],
          parentRoot: listOfItems[index],
        );
      }));
    },
    subtitle: Text(bm[listOfItems[index]].length.toString()),
  );
}

ListTile bookmarkTile(BuildContext context, Map<String, dynamic> bm,
    List<String> listOfItems, int index) {
  return ListTile(
    title: Text(listOfItems[index]),
    leading: Icon(Icons.link),
    onTap: () {
      print(bm[listOfItems[index]]);
    },
    subtitle: Text(bm[listOfItems[index]].toString()),
  );
}

Future<dynamic> importFailedDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Import Failed"),
      content: const Text("Please select a valid json file"),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.all(14),
            child: const Text("okay"),
          ),
        ),
      ],
    ),
  );
}
