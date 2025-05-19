import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  VideoPlayerController? _controller;
  bool _isVideoFinished = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4')
      ..addListener(() {
        final isPlaying = _controller?.value.isPlaying ?? false;
        final isFinished = _controller!.value.position >=
            _controller!.value.duration;
        setState(() {
          _isVideoFinished =   isFinished;
        });
      })
      ..initialize().then((_) {
        setState(() {});
        _controller?.play();
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _controller!.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            )
                : Container(),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    _controller?.pause();
                    Get.showSnackbar(const GetSnackBar(
                      message: 'Video paused',
                      duration: Duration(seconds: 2),
                    ));
                  },
                  child: const Text('Skip'),
                ),
                const Spacer(),
                if (_isVideoFinished)
                  TextButton(
                    onPressed: () {
                      Get.showSnackbar(const GetSnackBar(
                        message: 'Video finished',
                        duration: Duration(seconds: 2),
                      ));
                    },
                    child: const Text('Get Started'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}