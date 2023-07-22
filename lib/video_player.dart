import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'config/theme_info.dart';
import 'models/lecture.dart';
import 'models/prompt.dart';

/// Stateful widget to fetch and then display video content.
class VideoApp extends StatefulWidget {
  Prompt prompt;
  VideoApp(this.prompt, {super.key});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  String title = "";
  String description = "What the what what is going on with the library";

  @override
  void initState() {
    super.initState();
    this.title = widget.prompt.name;
    this.description = widget.prompt.description;
    _controller = VideoPlayerController.network(widget.prompt.extra_data1)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video',
      home: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: BackButton(),
          bottomOpacity: 0.0,
          backgroundColor: Colors.grey[100],
          foregroundColor: Colors.black38,
          centerTitle: true,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text('Video'),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title,
                style: TextStyle(fontSize: ThemeInfo.font_title_size)),
          ),
          _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 32, bottom: 32),
            child: Text(description),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(Icons.edit_note, color: ThemeInfo.color_accent),
              ),
              Text("Depression Form",
                  style: TextStyle(color: ThemeInfo.color_accent)),
            ]),
          ),
          Divider(height: 0),
          Padding(
            padding: const EdgeInsets.only(top: 32.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(Icons.video_library, color: Colors.blue),
              ),
              Text("Video Library", style: TextStyle(color: Colors.blue))
            ]),
          )
        ]),

        //Float
        /*floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),*/
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
