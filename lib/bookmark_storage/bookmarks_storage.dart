import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class BookMarkStorage {
  Map<String, dynamic> setOfBookmarks = {};
  // Map<String, dynamic> setOfBookmarks = {
  //   "dir1": {"bm1.1": "link1.1", "bm1.2": "link1.2"},
  //   "dir2": {"bm2.1": "link2.1", "bm2.2": "link2.2"}
  // };

  static final BookMarkStorage _bookMarkStorage = BookMarkStorage._internal();

  factory BookMarkStorage() {
    return _bookMarkStorage;
  }
  // Real constructor
  BookMarkStorage._internal();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/test.json');
  }

  Future<String> readStorage() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      String emptyJsonString =
          jsonEncode({"About Me": "https://gitlab.com/RohitSingh107/dirbook"});

      final path = await _localPath;
      File f = File('$path/test.json');
      f.writeAsStringSync(emptyJsonString);

      return emptyJsonString;
    }
  }

  Future<File> writeStorage(String content) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(content);
  }

  Future<void> saveToStorage() async {
    final file = await _localFile;
    String content = jsonEncode(setOfBookmarks);

    // Write the file
    await file.writeAsString(content);
  }

  Future<bool> importData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.first.extension == 'json') {
      try {
        PlatformFile pFile = result.files.first;

        File file = File(pFile.path!);
        String content = file.readAsStringSync();

        await writeStorage(content);

        return true;
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> exportData() async {
    Map<String, dynamic> data = setOfBookmarks;
    String exportData = jsonEncode(data);

    var dateFormat = DateFormat('yyyy-MM-dd');
    var fileName = 'dir_book-${dateFormat.format(DateTime.now())}.json';

    var path = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
            fileName: fileName,
            data: Uint8List.fromList(utf8.encode(exportData))));

    // if (path != null) {
    //   final file = File(path);
    //   // Writing again
    //   await file.writeAsString(exportData);
    // }

    // final file = File(path!);

    // Write the file
    // await file.writeAsString(exportData);

    return path != null;
  }
}
