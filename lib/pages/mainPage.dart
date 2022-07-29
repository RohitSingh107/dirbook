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
          List<String> listOfItems = widget.bm.keys.toList()..sort();

          bool check = widget.bm[listOfItems[index]].runtimeType == String;

          return check
              ? BookMarkTile(
                  bm: widget.bm,
                  bookMarkName: listOfItems[index],
                  bookMarkLink: widget.bm[listOfItems[index]].toString())
              : FolderTile(bm: widget.bm, folderName: listOfItems[index]);
          // : directoryTile(context, widget.bm, listOfItems, index);
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
              await openDialogForFolder(
                  context: context, folderController: folderController);

              String val = folderController.text;

              if (val.isNotEmpty) {
                Map<String, dynamic> emptyFolder = {};
                widget.bm.addEntries({val: emptyFolder}.entries);

                await BookMarkStorage().saveToStorage();
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
                  context: context,
                  nameController: nameController,
                  linkController: linkController);

              String nameVal = nameController.text;
              String linkVal = linkController.text;

              if ((nameVal.isNotEmpty) && (linkVal.isNotEmpty)) {
                widget.bm.addEntries({nameVal: linkVal}.entries);

                await BookMarkStorage().saveToStorage();
              }

              setState(() {});
            },
          )
        ],
      ),
    );
  }
}

class FolderTile extends StatefulWidget {
  Map<String, dynamic> bm;
  String folderName;

  FolderTile({Key? key, required this.bm, required this.folderName})
      : super(key: key);

  @override
  _FolderTileState createState() => _FolderTileState();
}

class _FolderTileState extends State<FolderTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
        // TODO:  <27-07-22, yourname> //
        // Update directory
        //-----------------------------------------------

        TextEditingController folderController = TextEditingController();
        final String oldFolderName = widget.folderName;
        folderController.text = oldFolderName;

        await openDialogForFolder(
            context: context, folderController: folderController);

        String folderNameVal = folderController.text;

        if ((folderNameVal.isNotEmpty) && !(folderNameVal == oldFolderName)) {
          Map<String, dynamic> storeVal = widget.bm[widget.folderName];

          widget.bm.addEntries({folderNameVal: storeVal}.entries);
          widget.bm.remove(oldFolderName);
          await BookMarkStorage().saveToStorage();
        }
        setState(() {
          if (folderNameVal.isNotEmpty) {
            widget.folderName = folderNameVal;
          }
        });
        //----------------------------------------------
      },
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MainPage(
            bm: widget.bm[widget.folderName],
            parentRoot: widget.folderName,
          );
        }));
      },
      child: Card(
        child: ListTile(
          title: Text(widget.folderName),
          leading: const Icon(Icons.folder),
          subtitle: Text(widget.bm[widget.folderName].length.toString()),
        ),
      ),
    );
  }
}

class BookMarkTile extends StatefulWidget {
  Map<String, dynamic> bm;
  String bookMarkName;
  String bookMarkLink;
  BookMarkTile(
      {Key? key,
      required this.bm,
      required this.bookMarkName,
      required this.bookMarkLink})
      : super(key: key);

  @override
  State<BookMarkTile> createState() => _BookMarkTileState();
}

class _BookMarkTileState extends State<BookMarkTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
        TextEditingController nameController = TextEditingController();
        final String oldname = widget.bookMarkName;
        nameController.text = oldname;

        TextEditingController linkController = TextEditingController();
        final String oldlink = widget.bookMarkLink;
        linkController.text = oldlink;

        await openDialogForBookmark(
            context: context,
            nameController: nameController,
            linkController: linkController);

        String nameVal = nameController.text;
        String linkVal = linkController.text;

        if ((nameVal.isNotEmpty) &&
            (linkVal.isNotEmpty) &&
            (!(nameVal == oldname) || !(linkVal == oldlink))) {
          widget.bm.addEntries({nameVal: linkVal}.entries);
          widget.bm.remove(widget.bookMarkName);
          await BookMarkStorage().saveToStorage();
        }
        setState(() {
          if ((nameVal.isNotEmpty) && (linkVal.isNotEmpty)) {
            widget.bookMarkLink = linkVal;
            widget.bookMarkName = nameVal;
          }
        });
      },
      onTap: () async {
        final url = widget.bookMarkLink;
        final uri = Uri.parse(url);
        await _launchInBrowser(uri);
      },
      child: Dismissible(
        direction: DismissDirection.endToStart,
        key: ValueKey<String>(widget.bookMarkName),
        background: Container(
          color: Colors.red,
          child: const Icon(Icons.delete_forever),
        ),
        onDismissed: (DismissDirection direction) async {
          widget.bm.remove(widget.bookMarkName);
          await BookMarkStorage().saveToStorage();
        },
        child: Card(
          child: ListTile(
            title: Text(widget.bookMarkName),
            leading: const Icon(Icons.link),
            subtitle: Text(widget.bookMarkLink),
          ),
        ),
      ),
    );
  }
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
    {required BuildContext context,
    required TextEditingController folderController}) {
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
    {required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController linkController}) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text("Create a Bookmark"),
            content: SizedBox(
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
                    decoration:
                        const InputDecoration(hintText: "www.example.com"),
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
