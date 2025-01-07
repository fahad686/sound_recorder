import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ftalk_recorder/playback_screen.dart';
import 'package:path_provider/path_provider.dart';

class FileListScreen extends StatelessWidget {
  Future<List<File>> _getRecordings() async {
    Directory? appDocDir = await getExternalStorageDirectory();
    String folderPath = '${appDocDir!.path}/Ftalk Record';
    Directory folder = Directory(folderPath);
    if (!folder.existsSync()) {
      return [];
    }
    return folder.listSync().whereType<File>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recorded Files")),
      body: FutureBuilder<List<File>>(
        future: _getRecordings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading recordings."));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No recordings found."));
          } else {
            List<File> recordings = snapshot.data!;
            return ListView.builder(
              itemCount: recordings.length,
              itemBuilder: (context, index) {
                File file = recordings[index];
                return ListTile(
                  title: Text(file.path.split('/').last),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaybackScreen(file: file),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
