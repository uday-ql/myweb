import 'dart:io';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';

class CachedVideoPlayerWidget extends StatefulWidget {
  final String filePath;

  const CachedVideoPlayerWidget({super.key, required this.filePath});

  @override
  State<CachedVideoPlayerWidget> createState() =>
      _CachedVideoPlayerWidgetState();
}

class _CachedVideoPlayerWidgetState extends State<CachedVideoPlayerWidget> {
  late CachedVideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _videoController = CachedVideoPlayerController.file(File(widget.filePath));
    _initializeVideoPlayerFuture = _videoController.initialize().then((_) {
      _videoController.play();
      _videoController.setLooping(true);
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(
                  child: Text(
                "There was a error in Loading video",
                style: TextStyle(color: Colors.red),
              ));
            } else {
              return SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: CachedVideoPlayer(_videoController),
                  ),
                ),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
