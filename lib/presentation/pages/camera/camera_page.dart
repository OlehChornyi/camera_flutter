import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:camera_flutter/presentation/pages/camera/widgets/bottom_menu.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

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
      await GallerySaver.saveVideo(file.path);
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isRecording)
      return;

    try {
      final file = await _controller!.takePicture();
      await GallerySaver.saveImage(file.path);
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<Uint8List?> retrieveSingleImageBytes() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (!result.isAuth) {
      print("Permission denied.");
      return null;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    if (albums.isEmpty) return null;

    final imageAssets = await albums.first.getAssetListPaged(page: 0, size: 1);
    if (imageAssets.isEmpty) return null;

    final imageData = await imageAssets.first.thumbnailDataWithSize(
      const ThumbnailSize(500, 500),
    );

    return imageData;
  }

  Future<void> _loadOverlayImage() async {
    final imageBytes = await retrieveSingleImageBytes();
    if (imageBytes != null) {
      setState(() => _overlayImage = imageBytes);
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
          if (_overlayImage != null)
            Opacity(
              opacity: 0.8,
              child: Image.memory(
                _overlayImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          BottomMenu(
            isRecording: _isRecording,
            onSwitchCameraTap: _switchCamera,
            onAddOverlayTap: _loadOverlayImage,
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
