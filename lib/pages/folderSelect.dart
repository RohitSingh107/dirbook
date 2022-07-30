import 'package:dir_book/bookmark_storage/bookmarks_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FolderSelect extends StatefulWidget {
  Map<String, dynamic> bm;
  String parentRoot;
  bool paste;
  String link;

  FolderSelect(
      {Key? key,
      required this.bm,
      required this.parentRoot,
      required this.paste,
      this.link = ""})
      : super(key: key);

  @override
  State<FolderSelect> createState() => _FolderSelect();
}

class _FolderSelect extends State<FolderSelect> {
  @override
  Widget build(BuildContext context) {
    List<String> listOfAllItems = widget.bm.keys.toList()..sort();
    List<String> listOfDirectories = <String>[];

    for (String element in listOfAllItems) {
      if (widget.bm[element].runtimeType != String) {
        listOfDirectories.add(element);
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parentRoot),
      ),
      body: ListView.builder(
        itemCount: listOfDirectories.length,
        itemBuilder: (BuildContext context, int index) {
          return FolderTile(
              bm: widget.bm,
              folderName: listOfDirectories[index],
              paste: widget.paste,
              link: widget.link);
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: null,
            tooltip: "New Folder",
            backgroundColor: Colors.blue,
            child: const Icon(Icons.create_new_folder),
            onPressed: () async {
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
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: null,
            tooltip: "Select this folder",
            backgroundColor: Colors.green,
            child: const Icon(Icons.pin_drop),
            onPressed: () async {
              try {
                print(
                    "printinf details ---------------------------------------------------------------------------");
                if (!widget.paste) {
                  print("Folder name is ${widget.parentRoot}");
                  print("Shared link is ${widget.link}");

                  final uri = Uri.parse(widget.link);

                  TextEditingController nameController =
                      TextEditingController();
                  print("h1");
                  final String oldname =
                      uri.pathSegments.last.replaceAll('-', ' ');
                  nameController.text = oldname;

                  print("h2");
                  TextEditingController linkController =
                      TextEditingController();
                  final String oldlink = widget.link;
                  linkController.text = oldlink;

                  print("h3");
                  await openDialogForBookmark(
                      context: context,
                      nameController: nameController,
                      linkController: linkController);

                  String nameVal = nameController.text;
                  String linkVal = linkController.text;

                  print("h4");
                  if ((nameVal.isNotEmpty) && (linkVal.isNotEmpty)) {
                    widget.bm.addEntries({nameVal: linkVal}.entries);
                    await BookMarkStorage().saveToStorage();
                  }

                  print("h5");
                  SystemNavigator.pop();
                }
              } catch (e) {
                await invalidUrlDialog(
                    context: context,
                    title: "INVALID URL",
                    message: "${widget.link} is not a valid url");
                SystemNavigator.pop();
              }
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
  bool paste;
  String link;

  FolderTile(
      {Key? key,
      required this.bm,
      required this.folderName,
      required this.paste,
      this.link = ""})
      : super(key: key);

  @override
  _FolderTileState createState() => _FolderTileState();
}

class _FolderTileState extends State<FolderTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () async {
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
      },
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return FolderSelect(
            bm: widget.bm[widget.folderName],
            parentRoot: widget.folderName,
            paste: widget.paste,
            link: widget.link,
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

Future<void> invalidUrlDialog(
    {required BuildContext context,
    required String title,
    required String message}) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: const TextStyle(color: Colors.red)),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: Container(
            color: Colors.pink,
            padding: const EdgeInsets.all(14),
            child: const Text(
              "okay",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}
