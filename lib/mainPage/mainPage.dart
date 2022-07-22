import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  Map<String, dynamic> bm;

  MainPage({Key? key, required this.bm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DirBook"),
      ),
      body: ListView.builder(
        itemCount: bm.length,
        itemBuilder: (BuildContext context, int index) {
          List<String> listOfItems = bm.keys.toList();
          return ListTile(
            title: Text(listOfItems[index]),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MainPage(
                  bm: bm[listOfItems[index]],
                );
              }));
            },
          );
        },
      ),
    );
  }
}
