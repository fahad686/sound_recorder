import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'file_screen.dart';

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  _RecorderScreenState createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String _filePath = '';

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
    if (await Permission.microphone.request().isDenied) {
      if (await Permission.microphone.isPermanentlyDenied) {
        openAppSettings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Microphone permission is required.")),
        );
      }
    }
  }

  @override
  void dispose() async {
    await _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      Directory? appDocDir = await getExternalStorageDirectory();
      String folderPath = '${appDocDir!.path}/Ftalk Record';
      await Directory(folderPath).create(recursive: true);

      _filePath = '$folderPath/temp_record.wav'; // Use WAV instead of MP3

      try {
        await _recorder.startRecorder(
          toFile: _filePath,
         // codec: Codec.wav, // Using WAV codec
        );
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error starting recorder: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Microphone permission is required.")),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder.stopRecorder();
      _showSaveDialog();
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to stop recording: $e")),
      );
    }
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
                Directory? appDocDir = await getExternalStorageDirectory();
                String folderPath = '${appDocDir!.path}/Ftalk Record';
                String newPath = '$folderPath/$newFileName.mp3';

                if (await File(_filePath).exists()) {
                  File(_filePath).renameSync(newPath);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Recording file not found.")),
                  );
                }
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Voice Recorder")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? "Stop Recording" : "Start Recording"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FileListScreen()),
                );
              },
              child: Text("View Recordings"),
            ),
          ],
        ),
      ),
    );
  }
}
