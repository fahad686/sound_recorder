import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:ftalk_recorder/file_screen.dart';

class RecordingControlScreen extends StatefulWidget {
  final String filePath;
  final FlutterSoundRecorder recorder;
  final VoidCallback onStopRecording;

  const RecordingControlScreen({
    Key? key,
    required this.filePath,
    required this.recorder,
    required this.onStopRecording,
  }) : super(key: key);

  @override
  _RecordingControlScreenState createState() => _RecordingControlScreenState();
}

class _RecordingControlScreenState extends State<RecordingControlScreen> {
  bool _isRecording = true;

  void _toggleRecording() async {
    if (_isRecording) {
      await widget.recorder.pauseRecorder();
    } else {
      await widget.recorder.resumeRecorder();
    }
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recording...")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Recording in progress..."),
            IconButton(
              icon: Icon(_isRecording ? Icons.pause : Icons.play_arrow),
              onPressed: _toggleRecording,
            ),
            ElevatedButton(
              onPressed: () {
                widget.onStopRecording();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FileListScreen(
                      recordings: [widget.filePath],
                    ),
                  ),
                );
              },
              child: Text("Stop Recording"),
            ),
          ],
        ),
      ),
    );
  }
}
