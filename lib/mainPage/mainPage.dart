import 'package:dir_book/bookmark_storage/bookmarks_storage.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

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
              print(
                  "Here importing starts-------------------------------------------------------------------------------------------------------------");

              bool sucess = await BookMarkStorage().importData();

              if (sucess) {
                // Restart.restartApp();
                print(
                    "Here app should be restarted-----------------------------------------------------------------------------------------------------------------------------");
              } else {
                // await importExportDialog(
                //     context,
                //     "Import Failed",
                //     "Please select a valid json file");
                showMessage(context,
                    "Import Failed! Please select a valid json file"); // This might cause issues -------------------------------------------------------------------
              }
            },
          ),
          ListTile(
            title: const Text('Export'),
            onTap: () async {
              bool sucess = await BookMarkStorage().exportData();
              if (sucess) {
                // await importExportDialog(
                //     context, // This might cause issues ----------------------------------------------------------------------------------
                //     "Sucess!",
                //     "Data Exported sucessfully");

                showMessage(context, "Data Exported sucessfully!");
              } else {
                // await importExportDialog(
                //     context, // This might cause issues ----------------------------------------------------------------------------------
                //     "Export Failed",
                //     "Export Failed");
                showMessage(context, "Export Failed!");
              }
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
    leading: const Icon(Icons.folder),
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
    leading: const Icon(Icons.link),
    onTap: () {},
    subtitle: Text(bm[listOfItems[index]].toString()),
  );
}

// Future<dynamic> importExportDialog(
//     BuildContext context, String title, String content) {
//   return showDialog(
//     context: context,
//     builder: (ctx) => AlertDialog(
//       title: Text(title),
//       content: Text(content),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () {
//             Navigator.of(ctx).pop();
//           },
//           child: Container(
//             color: Colors.green,
//             padding: const EdgeInsets.all(14),
//             child: const Text("okay"),
//           ),
//         ),
//       ],
//     ),
//   );
// }

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}
