import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:ftalk_recorder/playback_screen.dart';
import 'package:path_provider/path_provider.dart';

class FileListScreen extends StatefulWidget {
  const FileListScreen({Key? key, required this.recordings}) : super(key: key);

  final List<String> recordings;

  @override
  State<FileListScreen> createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  String? _currentPlaying;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await _player.openPlayer();
  }

  Future<void> _playRecording(String path) async {
    if (_currentPlaying == path && _isPlaying) {
      await _player.pausePlayer();
      setState(() {
        _isPlaying = false;
      });
    } else {
      if (_currentPlaying != null && _currentPlaying != path) {
        await _player.stopPlayer();
      }
      await _player.startPlayer(fromURI: path,);
      setState(() {
        _currentPlaying = path;
        _isPlaying = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    await _player.stopPlayer();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _deleteRecording(String path) async {
    File file = File(path);
    if (await file.exists()) {
      await file.delete();
      setState(() {
        widget.recordings.remove(path);
      });
    }
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recordings List'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          itemCount: widget.recordings.length,
          itemBuilder: (context, index) {
            String path = widget.recordings[index];
            return Card(
              color: Colors.white10,
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: ListTile(
                title: Text(
                  path.split('/').last,
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _currentPlaying == path && _isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.green,
                      ),
                      onPressed: () => _playRecording(path),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.stop,
                        color: Colors.red,
                      ),
                      onPressed: _stopRecording,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () => _deleteRecording(path),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
