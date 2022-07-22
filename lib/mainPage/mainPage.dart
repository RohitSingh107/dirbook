import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  Map<String, dynamic> bm;
  String parentRoot;

  MainPage({Key? key, required this.bm, required this.parentRoot})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(parentRoot),
      ),
      body: ListView.builder(
        itemCount: bm.length,
        itemBuilder: (BuildContext context, int index) {
          List<String> listOfItems = bm.keys.toList();

          bool check = bm[listOfItems[index]].runtimeType == String;

          return check
              ? bookmarkTile(context, bm, listOfItems, index)
              : directoryTile(context, bm, listOfItems, index);
        },
      ),
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
