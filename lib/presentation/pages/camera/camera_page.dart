import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[_cameraIndex], ResolutionPreset.high);
    await _controller!.initialize();
    setState(() {});
  }

  Future<void> _switchCamera() async {
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _controller?.dispose();
    _controller = CameraController(_cameras[_cameraIndex], ResolutionPreset.high);
    await _controller!.initialize();
    setState(() {});
  }

  Future<void> _startRecording() async {
    final directory = await getTemporaryDirectory();
    final videoPath = join(directory.path, '${DateTime.now()}.mp4');

    await _controller?.startVideoRecording();
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    final file = await _controller?.stopVideoRecording();
    setState(() {
      _isRecording = false;
    });
    print('Video saved to: ${file?.path}');
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller!),
          Positioned(
            bottom: 30,
            left: 30,
            child: FloatingActionButton(
              child: const Icon(Icons.switch_camera),
              onPressed: _switchCamera,
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton(
              child: Icon(_isRecording ? Icons.stop : Icons.videocam),
              onPressed: _isRecording ? _stopRecording : _startRecording,
            ),
          ),
        ],
      ),
    );
  }
}