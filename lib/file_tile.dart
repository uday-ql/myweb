import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class FileTile extends StatefulWidget {
  const FileTile({Key? key, required this.file}) : super(key: key);

  final File file;

  @override
  State<FileTile> createState() => _FileTileState();
}

class _FileTileState extends State<FileTile> {
  late Future<String> getSize;

  @override
  void initState() {
    super.initState();
    getSize = getFileSize();
  }

  Future<String> getFileSize() async {
    final int bytes = await widget.file.length();

    return getSizeString(bytes);
  }

  String getSizeString(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    String extension =
        p.extension(widget.file.path).replaceFirst(".", "").toUpperCase();
    String filename = p.basename(widget.file.path);

    debugPrint("Extension: $extension");
    debugPrint("Filename: $filename");
    return ListTile(
      tileColor: Colors.grey[300],
      leading: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.folder,
            size: 50,
            color: Colors.white,
          ),
          Text(
            extension,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
      title: Text(filename),
      subtitle: FutureBuilder<String>(
          future: getSize,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final size = snapshot.data ?? "0 B";
              return Text("$size • $extension");
            } else {
              return Text("0 B • $extension");
            }
          }),
    );
  }
}
