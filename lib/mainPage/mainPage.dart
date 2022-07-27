import 'package:dir_book/bookmark_storage/bookmarks_storage.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:url_launcher/url_launcher.dart';

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
              ? bookmarkWidget(context, widget.bm, listOfItems, index)
              // : DirectoryTile(
              //     bm: widget.bm, listOfItems: listOfItems, index: index);

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
              // print(
              // "Here importing starts-------------------------------------------------------------------------------------------------------------");

              bool sucess = await BookMarkStorage().importData();

              if (sucess) {
                Restart.restartApp();
                // print(
                //     "Here app should be restarted-----------------------------------------------------------------------------------------------------------------------------");
              } else {
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
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.add_event,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.folder),
            label: "Add Folder",
            backgroundColor: Colors.red,
            onTap: () async {
              TextEditingController folderController = TextEditingController();
              await openDialogForFolder(context, folderController);

              String val = folderController.text;

              if (val.isNotEmpty) {
                Map<String, dynamic> emptyFolder = {};
                widget.bm.addEntries({val: emptyFolder}.entries);

                BookMarkStorage().saveToStorage();
              }

              setState(() {});
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.add_link),
            label: "Add Bookmark",
            backgroundColor: Colors.green,
            onTap: () async {
              TextEditingController nameController = TextEditingController();

              TextEditingController linkController = TextEditingController();
              await openDialogForBookmark(
                  context, nameController, linkController);

              String nameVal = nameController.text;
              String linkVal = linkController.text;

              if ((nameVal.isNotEmpty) && (linkVal.isNotEmpty)) {
                widget.bm.addEntries({nameVal: linkVal}.entries);

                BookMarkStorage().saveToStorage();
              }

              setState(() {});
            },
          )
        ],
      ),
    );
  }
}

Widget directoryTile(BuildContext context, Map<String, dynamic> bm,
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

// class DirectoryTile extends StatefulWidget {
//   Map<String, dynamic> bm;
//   List<String> listOfItems;
//   int index;

//   DirectoryTile(
//       {Key? key,
//       required this.bm,
//       required this.listOfItems,
//       required this.index})
//       : super(key: key);
//   @override
//   _DirectoryTileState createState() => _DirectoryTileState();
// }

// class _DirectoryTileState extends State<DirectoryTile> {
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(widget.listOfItems[widget.index]),
//       leading: const Icon(Icons.folder),
//       onTap: () {
//         Navigator.push(context, MaterialPageRoute(builder: (context) {
//           return MainPage(
//             bm: widget.bm[widget.listOfItems[widget.index]],
//             parentRoot: widget.listOfItems[widget.index],
//           );
//         }));
//       },
//       subtitle:
//           Text(widget.bm[widget.listOfItems[widget.index]].length.toString()),
//     );
//   }
// }

Widget bookmarkWidget(BuildContext context, Map<String, dynamic> bm,
    List<String> listOfItems, int index) {
  return InkWell(
    onLongPress: () {
      print("Bookmark is long pressed");
      //   // TODO:  <27-07-22, yourname> //
      //   // Update the item
    },
    onTap: () async {
      final url = bm[listOfItems[index]].toString();
      final uri = Uri.parse(url);
      await _launchInBrowser(uri);
    },
    child: Dismissible(
      direction: DismissDirection.endToStart,
      key: ValueKey<String>(bm[listOfItems[index]].toString()),
      background: Container(
        color: Colors.red,
        child: const Icon(Icons.delete_forever),
      ),
      onDismissed: (DismissDirection direction) async {
        // TODO:  <27-07-22, yourname> //
        // Deleting bookmark
        // print(listOfItems[index]);
        bm.remove(listOfItems[index]);
        await BookMarkStorage().saveToStorage();
      },
      child: Card(
        child: ListTile(
          title: Text(listOfItems[index]),
          leading: const Icon(Icons.link),
          subtitle: Text(bm[listOfItems[index]].toString()),
        ),
      ),
    ),
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

Future<void> _launchInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw 'Could not launch $url';
  }
}

Future<void> openDialogForFolder(
    BuildContext context, TextEditingController folderController) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text("Create a Folder"),
            content: TextField(
              controller: folderController,
              autofocus: true,
              decoration: const InputDecoration(hintText: "Name of Folder"),
            ),
            actions: [
              TextButton(
                child: const Text("SUBMIT"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ));
}

Future<void> openDialogForBookmark(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController linkController) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text("Create a Bookmark"),
            content: Container(
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration:
                        const InputDecoration(hintText: "Name of Bookmark"),
                  ),
                  TextField(
                    controller: linkController,
                    autofocus: true,
                    decoration: const InputDecoration(
                        hintText: "https//www.example.com"),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("SUBMIT"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ));
}
