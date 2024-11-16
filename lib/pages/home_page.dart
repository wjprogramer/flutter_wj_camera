import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _initialized = false;

  late CameraController controller;
  late List<CameraDescription> _cameras;
  late Size _previewSize;

  @override
  void initState() {
    super.initState();
    _forceToLandscape();
    _init();
    _initializeCamera();
  }

  @override
  void dispose() {
    controller.dispose();
    _exitFullscreen();
    _restoreOrientation();
    super.dispose();
  }

  void _init() {
    // full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values);
  }

  void _forceToLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  void _restoreOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    controller = CameraController(
      _cameras[0],
      ResolutionPreset.max,
    );
    controller.initialize().then((_) async {
      _initialized = true;
      // controller.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
      _previewSize = controller.value.previewSize ?? Size.zero;
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _previewSize.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // final screenSize = MediaQuery.of(context).size;
    // final a = math.max(screenSize.width, screenSize.height);
    // final b = math.min(screenSize.width, screenSize.height);

    final a = _previewSize.width / 2;
    final b = _previewSize.height / 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Transform.rotate(
            angle: math.pi / 2,
            child: Center(
              child: OverflowBox(
                minWidth: b,
                maxWidth: b,
                minHeight: a,
                maxHeight: a,
                child: CameraPreview(controller),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
