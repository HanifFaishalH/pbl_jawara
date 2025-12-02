import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'display_picture_screen.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key});

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String? _error;
  List<CameraDescription> _cameras = const [];
  int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _error = 'Kamera tidak tersedia');
        return;
      }
      final controller = CameraController(
        _cameras[_currentCameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      setState(() {
        _controller = controller;
        _initializeControllerFuture = controller.initialize();
      });
      await _initializeControllerFuture;
      if (!mounted) return;
      setState(() {});
    } on CameraException catch (e) {
      setState(() => _error = 'Gagal inisialisasi kamera: ${e.description ?? e.code}');
    } catch (e) {
      setState(() => _error = 'Gagal inisialisasi kamera: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hanya satu kamera tersedia')),
      );
      return;
    }
    try {
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
      await _controller?.dispose();
      final controller = CameraController(
        _cameras[_currentCameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      setState(() {
        _controller = controller;
        _initializeControllerFuture = controller.initialize();
      });
      await _initializeControllerFuture;
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengganti kamera: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ambil Gambar')),
      body: _error != null
          ? Center(child: Text(_error!))
          : (_initializeControllerFuture == null)
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CameraPreview(_controller!);
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'flip-camera',
            onPressed: _switchCamera,
            child: const Icon(Icons.cameraswitch),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'take-photo',
            onPressed: () async {
              try {
                if (_controller == null) return;
                await _initializeControllerFuture;
                final image = await _controller!.takePicture();
                if (!mounted) return;
                // Buka preview dan tunggu hasil "Gunakan Foto"
                final selectedPath = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(imagePath: image.path),
                  ),
                );
                if (!mounted) return;
                if (selectedPath != null) {
                  // Kembalikan path ke AddBarangScreen
                  Navigator.of(context).pop<String>(selectedPath);
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal mengambil gambar: $e')),
                );
              }
            },
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
