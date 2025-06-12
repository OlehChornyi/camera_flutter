import 'package:camera/camera.dart';
import 'package:camera_flutter/presentation/pages/camera/widgets/bottom_menu.dart';
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
            onSwitchCameraTap: _switchCamera,
            onAddOverlayTap: () {},
            onPlayStopTap: _isRecording ? _stopRecording : _startRecording,
            onTakeImageTap: () {},
          ),
          Positioned(
            top: 20,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
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
                  Text('00:00'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
