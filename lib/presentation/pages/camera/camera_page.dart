import 'dart:async';

import 'package:camera/camera.dart';
import 'package:camera_flutter/presentation/pages/camera/widgets/bottom_menu.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  bool _isRecording = false;
  int _cameraIndex = 0;

  Timer? _timer;
  int _recordDuration = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras[_cameraIndex],
      ResolutionPreset.high,
    );
    await _controller!.initialize();
    setState(() {});
  }

  Future<void> _switchCamera() async {
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _controller?.dispose();
    _controller = CameraController(
      _cameras[_cameraIndex],
      ResolutionPreset.high,
    );
    await _controller!.initialize();
    setState(() {});
  }

  void _startTimer() {
    _recordDuration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  Future<void> _startRecording() async {
    await _controller?.startVideoRecording();
    setState(() {
      _isRecording = true;
    });
    _startTimer();
  }

  Future<void> _stopRecording() async {
    final file = await _controller?.stopVideoRecording();
    setState(() {
      _isRecording = false;
    });
    _stopTimer();

    if (file != null) {
      await GallerySaver.saveVideo(file.path, albumName: 'MyFlutterApp');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isRecording)
      return;

    try {
      final file = await _controller!.takePicture();
      await GallerySaver.saveImage(file.path, albumName: 'MyFlutterApp');
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Camera test task',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          BottomMenu(
            isRecording: _isRecording,
            onSwitchCameraTap: _switchCamera,
            onAddOverlayTap: () {},
            onPlayStopTap: _isRecording ? _stopRecording : _startRecording,
            onTakeImageTap: _takePicture,
          ),
          if (_isRecording) ...{
            Positioned(
              top: 20,
              right: 40,
              child: Container(
                width: 64,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(50),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      _formatDuration(_recordDuration),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          },
        ],
      ),
    );
  }
}
