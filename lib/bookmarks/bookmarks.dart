import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

class BookMarkStorage {
  Map<String, dynamic> setOfBookmarks = {
    "dir1": {"bm1.1": "link1.1", "bm1.2": "link1.2"},
    "dir2": {"bm2.1": "link2.1", "bm2.2": "link2.2"}
  };

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
    return File('$path/bookmarks.json');
  }

  Future<String> readStorage() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      String emptyJsonString = jsonEncode({});

      final path = await _localPath;
      File f = File('$path/bookmarks.json');
      f.writeAsStringSync(emptyJsonString);

      return emptyJsonString;
    }
  }

  Future<File> writeStorage(String content) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(content);
  }
}
