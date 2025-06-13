import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:camera_flutter/presentation/pages/camera/widgets/bottom_menu.dart';
import 'package:camera_flutter/presentation/pages/camera/widgets/timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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

  Uint8List? _overlayImage;
  final ImagePicker _picker = ImagePicker();

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
    final extDir = await getExternalStorageDirectory();
    final videoName = "video_${DateTime.now().millisecondsSinceEpoch}.mp4";
    final newPath = path.join(extDir!.path, videoName);

    setState(() {
      _isRecording = false;
    });
    _stopTimer();
    if (file != null) {
      final originalFile = File(file.path);
      final newFile = await originalFile.copy(newPath);
      await ImageGallerySaverPlus.saveFile(
        newFile.path,
        name: '${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isRecording)
      return;

    try {
      final file = await _controller!.takePicture();
      await ImageGallerySaverPlus.saveFile(
        file.path,
        name: '${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<Uint8List?> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) {
      return null;
    }

    final imageBytes = await File(pickedFile.path).readAsBytes();
    return imageBytes;
  }

  Future<void> _loadOverlayImage() async {
    if (_overlayImage != null) {
      setState(() => _overlayImage = null);
    } else {
      final imageBytes = await pickImage();
      if (imageBytes != null) {
        setState(() => _overlayImage = imageBytes);
      }
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
          Positioned.fill(child: CameraPreview(_controller!)),
          if (_overlayImage != null)
            Opacity(
              opacity: 0.2,
              child: Image.memory(
                _overlayImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          BottomMenu(
            isOverlaySelected: _overlayImage == null,
            isRecording: _isRecording,
            onSwitchCameraTap: _switchCamera,
            onAddOverlayTap: _loadOverlayImage,
            onPlayStopTap: _isRecording ? _stopRecording : _startRecording,
            onTakeImageTap: _takePicture,
          ),
          if (_isRecording) ...{
            TimerWidget(timerValue: _formatDuration(_recordDuration)),
          },
        ],
      ),
    );
  }
}
