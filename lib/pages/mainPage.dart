import 'package:dir_book/bookmark_storage/bookmarks_storage.dart';
import 'package:dir_book/pages/folderSelect.dart';
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
  List<String> selectedItems = [];
  bool selectMode = false;
  // Map<String, bool> selectedStates = {};

  void selectModeTrue() {
    setState(() {
      selectMode = true;
    });
  }

  void selectModeFalse() {
    setState(() {
      selectMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> listOfAllItems = widget.bm.keys.toList()..sort();
    List<String> listOfDirectories = <String>[];
    List<String> listOfBookmarks = <String>[];

    for (String element in listOfAllItems) {
      if (widget.bm[element].runtimeType == String) {
        listOfBookmarks.add(element);
      } else {
        listOfDirectories.add(element);
      }
    }
    return SafeArea(
      child: Scaffold(
        appBar: !selectMode
            ? AppBar(
                title: Text(widget.parentRoot),
              )
            : AppBar(
                title: Text(widget.parentRoot),
                actions: <Widget>[
                  PopupMenuButton(
                    itemBuilder: (BuildContext context) {
                      return ["Edit", "Copy", "Move", "Delete"]
                          .map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                    onSelected: (item) async {
                      switch (item) {
                        case "Edit":
                          if (selectedItems.length != 1) {
                            showMessage(
                                context, "Please select only one item to edit");
                          } else {
                            if (listOfDirectories.contains(selectedItems[0])) {
                              TextEditingController folderController =
                                  TextEditingController();
                              final String oldFolderName = selectedItems[0];
                              folderController.text = oldFolderName;

                              await openDialogForFolder(
                                  context: context,
                                  folderController: folderController);

                              String folderNameVal = folderController.text;

                              if ((folderNameVal.isNotEmpty) &&
                                  !(folderNameVal == oldFolderName)) {
                                Map<String, dynamic> storeVal =
                                    widget.bm[selectedItems[0]];

                                widget.bm.addEntries(
                                    {folderNameVal: storeVal}.entries);
                                widget.bm.remove(oldFolderName);
                                await BookMarkStorage().saveToStorage();
                              }
                              setState(() {
                                // if (folderNameVal.isNotEmpty) {
                                //   widget.folderName = folderNameVal;
                                // }
                                selectedItems.clear();
                                selectMode = false;
                              });
                            } else {
                              TextEditingController nameController =
                                  TextEditingController();
                              final String oldname = selectedItems[0];
                              nameController.text = oldname;

                              TextEditingController linkController =
                                  TextEditingController();
                              final String oldlink =
                                  widget.bm[selectedItems[0]];
                              linkController.text = oldlink;

                              await openDialogForBookmark(
                                  context: context,
                                  nameController: nameController,
                                  linkController: linkController);

                              String nameVal = nameController.text;
                              String linkVal = linkController.text;

                              if ((nameVal.isNotEmpty) &&
                                  (linkVal.isNotEmpty) &&
                                  (!(nameVal == oldname) ||
                                      !(linkVal == oldlink))) {
                                widget.bm
                                    .addEntries({nameVal: linkVal}.entries);
                                widget.bm.remove(selectedItems[0]);
                                await BookMarkStorage().saveToStorage();
                              }
                              setState(() {
                                // if ((nameVal.isNotEmpty) &&
                                //     (linkVal.isNotEmpty)) {
                                //   widget.bookMarkLink = linkVal;
                                //   widget.bookMarkName = nameVal;
                                // }
                                selectedItems.clear();
                                selectMode = false;
                              });
                            }
                          }

                          break;
                        case "Copy":
                          print("Copy clicked");
                          print("Copying following items");
                          print(selectedItems);
                          Map<String, dynamic> itemsToAdd = {};
                          for (var item in selectedItems) {
                            itemsToAdd
                                .addEntries({item: widget.bm[item]}.entries);
                          }

                          await Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return FolderSelect(
                              bm: BookMarkStorage().setOfBookmarks,
                              parentRoot: "/",
                              paste: true,
                              itemsToAdd: itemsToAdd,
                            );
                          }));
                          setState(() {
                            selectedItems.clear();
                            selectMode = false;
                          });
                          break;
                        case "Delete":
                          print("Delete clicked");
                          print("Deleing following items");
                          print(selectedItems);
                          setState(() {
                            for (var key in selectedItems) {
                              widget.bm.remove(key);
                            }
                            selectedItems.clear();
                            selectMode = false;
                          });
                          break;
                        case "Move":
                          print("Move clicked");
                          print("Moving following items");
                          print(selectedItems);
                          Map<String, dynamic> itemsToAdd = {};
                          for (var item in selectedItems) {
                            itemsToAdd
                                .addEntries({item: widget.bm[item]}.entries);
                          }

                          await Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return FolderSelect(
                              bm: BookMarkStorage().setOfBookmarks,
                              parentRoot: "/",
                              paste: true,
                              itemsToAdd: itemsToAdd,
                            );
                          }));

                          setState(() {
                            for (var key in selectedItems) {
                              widget.bm.remove(key);
                            }
                            selectedItems.clear();
                            selectMode = false;
                          });
                          break;
                      }
                    },
                  )
                ],
              ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: listOfDirectories.length,
                itemBuilder: (BuildContext context, int index) {
                  return FolderTile(
                    bm: widget.bm,
                    folderName: listOfDirectories[index],
                    isSelected:
                        selectedItems.contains(listOfDirectories[index]),
                    listOfSelectedItems: selectedItems,
                    selectMode: selectMode,
                    selectModeTrue: selectModeTrue,
                    selectModeFalse: selectModeFalse,
                  );
                },
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: listOfBookmarks.length,
                itemBuilder: (BuildContext context, int index) {
                  return BookMarkTile(
                    bm: widget.bm,
                    bookMarkName: listOfBookmarks[index],
                    bookMarkLink: widget.bm[listOfBookmarks[index]].toString(),
                    isSelected: selectedItems.contains(listOfBookmarks[index]),
                    listOfSelectedItems: selectedItems,
                    selectMode: selectMode,
                    selectModeTrue: selectModeTrue,
                    selectModeFalse: selectModeFalse,
                  );
                },
              )
            ],
          ),
        ),
        drawer: Drawer(
            child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Bookmark Manager (Beta)'),
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
              backgroundColor: Colors.blue,
              onTap: () async {
                TextEditingController folderController =
                    TextEditingController();
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
      ),
    );
  }
}

class FolderTile extends StatefulWidget {
  Map<String, dynamic> bm;
  String folderName;
  bool isSelected;
  bool selectMode;
  List<String> listOfSelectedItems;
  final VoidCallback selectModeTrue;
  final VoidCallback selectModeFalse;
  FolderTile(
      {Key? key,
      required this.bm,
      required this.folderName,
      required this.isSelected,
      required this.listOfSelectedItems,
      required this.selectMode,
      required this.selectModeTrue,
      required this.selectModeFalse})
      : super(key: key);

  @override
  _FolderTileState createState() => _FolderTileState();
}

class _FolderTileState extends State<FolderTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onLongPress: () async {
      //   TextEditingController folderController = TextEditingController();
      //   final String oldFolderName = widget.folderName;
      //   folderController.text = oldFolderName;

      //   await openDialogForFolder(
      //       context: context, folderController: folderController);

      //   String folderNameVal = folderController.text;

      //   if ((folderNameVal.isNotEmpty) && !(folderNameVal == oldFolderName)) {
      //     Map<String, dynamic> storeVal = widget.bm[widget.folderName];

      //     widget.bm.addEntries({folderNameVal: storeVal}.entries);
      //     widget.bm.remove(oldFolderName);
      //     await BookMarkStorage().saveToStorage();
      //   }
      //   setState(() {
      //     if (folderNameVal.isNotEmpty) {
      //       widget.folderName = folderNameVal;
      //     }
      //   });
      // },
      onLongPress: () {
        setState(() {
          print(widget.selectMode);
          if (widget.isSelected) {
            widget.listOfSelectedItems.remove(widget.folderName);
            if (widget.listOfSelectedItems.isEmpty) {
              widget.selectModeFalse();
            }
            print(widget.listOfSelectedItems);
          } else {
            widget.listOfSelectedItems.add(widget.folderName);
            widget.selectModeTrue();
            print(widget.listOfSelectedItems);
          }

          widget.isSelected = !widget.isSelected;
        });
      },
      onTap: !widget.selectMode
          ? () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MainPage(
                  bm: widget.bm[widget.folderName],
                  parentRoot: widget.folderName,
                );
              }));
            }
          : () {
              setState(() {
                print(widget.selectMode);
                if (widget.isSelected) {
                  widget.listOfSelectedItems.remove(widget.folderName);
                  if (widget.listOfSelectedItems.isEmpty) {
                    widget.selectModeFalse();
                  }
                  print(widget.listOfSelectedItems);
                } else {
                  widget.listOfSelectedItems.add(widget.folderName);
                  widget.selectModeTrue();
                  print(widget.listOfSelectedItems);
                }

                widget.isSelected = !widget.isSelected;
              });
            },
      child: Dismissible(
        direction: DismissDirection.endToStart,
        key: ValueKey<String>(widget.folderName),
        background: Container(
          color: Colors.red,
          child: const Icon(Icons.delete_forever),
        ),
        onDismissed: (DismissDirection direction) async {
          widget.bm.remove(widget.folderName);
          await BookMarkStorage().saveToStorage();
        },
        child: Card(
          child: ListTile(
            title: Text(widget.folderName),
            leading: const Icon(Icons.folder, color: Colors.blue),
            subtitle: Text(widget.bm[widget.folderName].length.toString()),
            selected: widget.isSelected,
            selectedTileColor: widget.isSelected ? Colors.pink[100] : null,
            trailing: widget.isSelected ? const Icon(Icons.check) : null,
          ),
        ),
      ),
    );
  }
}

class BookMarkTile extends StatefulWidget {
  Map<String, dynamic> bm;
  String bookMarkName;
  String bookMarkLink;
  bool isSelected;
  bool selectMode;
  List<String> listOfSelectedItems;
  final VoidCallback selectModeTrue;
  final VoidCallback selectModeFalse;
  BookMarkTile(
      {Key? key,
      required this.bm,
      required this.bookMarkName,
      required this.bookMarkLink,
      required this.isSelected,
      required this.listOfSelectedItems,
      required this.selectMode,
      required this.selectModeTrue,
      required this.selectModeFalse})
      : super(key: key);

  @override
  State<BookMarkTile> createState() => _BookMarkTileState();
}

class _BookMarkTileState extends State<BookMarkTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onLongPress: () async {
      //   TextEditingController nameController = TextEditingController();
      //   final String oldname = widget.bookMarkName;
      //   nameController.text = oldname;

      //   TextEditingController linkController = TextEditingController();
      //   final String oldlink = widget.bookMarkLink;
      //   linkController.text = oldlink;

      //   await openDialogForBookmark(
      //       context: context,
      //       nameController: nameController,
      //       linkController: linkController);

      //   String nameVal = nameController.text;
      //   String linkVal = linkController.text;

      //   if ((nameVal.isNotEmpty) &&
      //       (linkVal.isNotEmpty) &&
      //       (!(nameVal == oldname) || !(linkVal == oldlink))) {
      //     widget.bm.addEntries({nameVal: linkVal}.entries);
      //     widget.bm.remove(widget.bookMarkName);
      //     await BookMarkStorage().saveToStorage();
      //   }
      //   setState(() {
      //     if ((nameVal.isNotEmpty) && (linkVal.isNotEmpty)) {
      //       widget.bookMarkLink = linkVal;
      //       widget.bookMarkName = nameVal;
      //     }
      //   });
      // },
      onLongPress: () {
        setState(() {
          print(widget.selectMode);
          if (widget.isSelected) {
            widget.listOfSelectedItems.remove(widget.bookMarkName);
            if (widget.listOfSelectedItems.isEmpty) {
              widget.selectModeFalse();
            }
            print(widget.listOfSelectedItems);
          } else {
            widget.listOfSelectedItems.add(widget.bookMarkName);
            widget.selectModeTrue();
            print(widget.listOfSelectedItems);
          }

          widget.isSelected = !widget.isSelected;
        });
      },
      onTap: !widget.selectMode
          ? () async {
              final url = widget.bookMarkLink;
              final uri = Uri.parse(url);
              await _launchInBrowser(uri);
            }
          : () {
              setState(() {
                print(widget.selectMode);
                if (widget.isSelected) {
                  widget.listOfSelectedItems.remove(widget.bookMarkName);
                  if (widget.listOfSelectedItems.isEmpty) {
                    widget.selectModeFalse();
                  }
                  print(widget.listOfSelectedItems);
                } else {
                  widget.listOfSelectedItems.add(widget.bookMarkName);
                  widget.selectModeTrue();
                  print(widget.listOfSelectedItems);
                }

                widget.isSelected = !widget.isSelected;
              });
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
            selected: widget.isSelected,
            selectedTileColor: widget.isSelected ? Colors.pink[100] : null,
            title: Text(widget.bookMarkName),
            leading: const Icon(Icons.link, color: Colors.green),
            subtitle: Text(widget.bookMarkLink),
            trailing: widget.isSelected ? const Icon(Icons.check) : null,
          ),
        ),
      ),
    );
  }
}

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
