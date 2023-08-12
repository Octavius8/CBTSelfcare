import 'package:flutter/material.dart';
import 'config/theme_configs.dart';
import 'models/lecture.dart';
import 'models/prompt.dart';
import 'package:video_player/video_player.dart';
import 'utils/logger.dart';

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
  bool _player_options_visible = true;
  double _trackerPosition = 0;
  Prompt? previous_lecture_prompt;
  Prompt? next_lecture_prompt;

  @override
  void initState() {
    super.initState();
    this.title = widget.prompt.name;
    this.description = widget.prompt.description;
    getLectures();
    _controller = VideoPlayerController.network(widget.prompt.extra_data1)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  void getLectures() async {
    Lecture lectureObject = Lecture();
    next_lecture_prompt = await lectureObject.getNextLecture();
    Log.debug("", "Next lecture is: " + next_lecture_prompt!.name ?? "");
    previous_lecture_prompt = await lectureObject.getPreviousLecture();
    Log.debug(
        "", "Previous lecture is: " + previous_lecture_prompt!.name ?? "");
  }

  void _loadVideo(int prompt_id) async {
    Lecture lectureObject = Lecture();
    Prompt? prompt = await lectureObject.getLecture(prompt_id);

    if (prompt != null) {
      widget.prompt = prompt;
      this.title = widget.prompt.name;
      this.description = widget.prompt.description;
      Log.debug("VideoPlayer | _loadVideo()",
          "New lecture is: " + widget.prompt.name);
      setState(() {});
      _controller = VideoPlayerController.network(widget.prompt.extra_data1)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Video',
        home: Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: BackButton(onPressed: () {
              Navigator.pop(context);
            }),
            bottomOpacity: 0.0,
            backgroundColor: Colors.grey[100],
            foregroundColor: Colors.black38,
            centerTitle: true,
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text('Video'),
          ),
          body: Stack(children: [
            SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(title,
                          style: TextStyle(
                              fontSize: ThemeConfigs.font_title_size)),
                    ),
                    _controller.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )
                        :

                        //Loading Screen
                        Container(
                            height: 180,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: ThemeConfigs.color_primary),
                              ),
                            )),

                    //Tracker
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: _trackerPosition,
                      color: ThemeConfigs.color_accent,
                    ),

                    //Play Thing
                    _controller.value.isInitialized
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Padding(
                                    padding: EdgeInsets.all(16),
                                    child: InkWell(
                                      onTap: () async {
                                        Duration? currentPosition =
                                            await _controller.position;
                                        int newSeconds =
                                            currentPosition?.inSeconds ?? 0 - 5;
                                        _controller.seekTo(
                                            Duration(seconds: newSeconds));
                                      },
                                      child: Icon(Icons.fast_rewind,
                                          color: ThemeConfigs.color_primary),
                                    )),
                                Padding(
                                    padding: EdgeInsets.all(16),
                                    child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _controller.value.isPlaying
                                                ? _controller.pause()
                                                : _controller.play();
                                          });
                                        },
                                        child: Icon(
                                            _controller.value.isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color:
                                                ThemeConfigs.color_primary))),
                                Padding(
                                    padding: EdgeInsets.all(16),
                                    child: InkWell(
                                      onTap: () async {
                                        Duration? currentPosition =
                                            await _controller.position;
                                        int newSeconds =
                                            currentPosition?.inSeconds ?? 0 + 5;
                                        _controller.seekTo(
                                            Duration(seconds: newSeconds));
                                      },
                                      child: Icon(Icons.fast_forward,
                                          color: ThemeConfigs.color_primary),
                                    )),
                              ])
                        : Container(),

                    //Description
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 0, bottom: 32),
                      child: Text(description),
                    ),
                    /* Padding(
                  padding:
                      const EdgeInsets.only(left: 32.0, right: 32, bottom: 32),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child:
                          Icon(Icons.edit_note, color: ThemeConfigs.color_accent),
                    ),
                    Text("Depression Form",
                        style: TextStyle(color: ThemeConfigs.color_accent)),
                  ]),
                ),*/
                    Divider(height: 0),
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0, bottom: 32),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                _loadVideo(int.parse(
                                        widget.prompt?.extra_data3 ?? '0') -
                                    1);
                              },
                              child: Row(children: [
                                Icon(Icons.chevron_left),
                                Text("Previous Video")
                              ]),
                            ),
                            Expanded(child: SizedBox.shrink()),
                            InkWell(
                              onTap: () {
                                print("New prompt_id: " +
                                    (int.parse(widget.prompt?.extra_data3 ??
                                                '0') +
                                            1)
                                        .toString());
                                _loadVideo(int.parse(
                                        widget.prompt?.extra_data3 ?? '0') +
                                    1);
                              },
                              child: Row(children: [
                                Text("Next Video"),
                                Icon(Icons.chevron_right),
                              ]),
                            ),
                            /*Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Icon(Icons.video_library,
                          color: ThemeConfigs.color_primary),
                    ),
                    Text("Video Library",
                        style: TextStyle(color: ThemeConfigs.color_primary))*/
                          ]),
                    ),
                  ]),
            ),
          ]

              //Wild

              /*Positioned(
            top: 200.0,
            child: AnimatedOpacity(
              opacity: _player_options_visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                  color: Color(0X33000000),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.all(16),
                            child:
                                Icon(Icons.fast_rewind, color: Colors.white)),
                        Padding(
                            padding: EdgeInsets.all(16),
                            child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _controller.value.isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                  });
                                },
                                child: Icon(Icons.play_arrow,
                                    color: Colors.white))),
                        Padding(
                            padding: EdgeInsets.all(16),
                            child:
                                Icon(Icons.fast_forward, color: Colors.white)),
                      ])),
            ),
          )
        ]),*/

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
        ));
  }

  @override
  void dispose() {
    super.dispose();
    //_controller.dispose();
  }
}
