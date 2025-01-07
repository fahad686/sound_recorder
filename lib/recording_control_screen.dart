import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingControlScreen extends StatefulWidget {
  final String filePath;

  const RecordingControlScreen({super.key, required this.filePath});

  @override
  _RecordingControlScreenState createState() =>
      _RecordingControlScreenState();
}

class _RecordingControlScreenState extends State<RecordingControlScreen> {
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _initializePlayer();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
  }

  Future<void> _initializePlayer() async {
    await _player.openPlayer();
  }

  Future<void> _pauseRecording() async {
    if (_isRecording) {
      await _recorder.pauseRecorder();
      setState(() {
        _isPaused = true;
      });
    }
  }

  Future<void> _resumeRecording() async {
    if (_isPaused) {
      await _recorder.resumeRecorder();
      setState(() {
        _isPaused = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
    _showSaveDialog();
  }

  void _showSaveDialog() {
    TextEditingController _nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Save Recording'),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(hintText: 'Enter file name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String newFileName = _nameController.text.trim();
              if (newFileName.isNotEmpty) {
                File(widget.filePath).renameSync(
                    '${Directory(widget.filePath).parent.path}/$newFileName.wav');
              }
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recording Controls")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Recording..."),
            // Add a widget for the graph animation of recording.
            // You could use a custom waveform widget here or any animation.
            SizedBox(height: 20),
            if (_isRecording || _isPaused)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.pause),
                    onPressed: _isRecording ? _pauseRecording : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.play_arrow),
                    onPressed: _isPaused ? _resumeRecording : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.stop),
                    onPressed: _stopRecording,
                  ),
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // To play back the recording after it's stopped
                _player.startPlayer(fromURI: widget.filePath);
                setState(() {
                  _isPlaying = true;
                });
              },
              child: Text(_isPlaying ? "Stop Playing" : "Play Recording"),
            ),
          ],
        ),
      ),
    );
  }
}
