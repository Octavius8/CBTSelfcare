import 'package:flutter/material.dart';
import 'models/video.dart';
import 'video_player.dart';
import 'models/prompt.dart';
import 'utils/logger.dart';
import 'dart:async';

class VideoLibraryPage extends StatefulWidget {
  @override
  VideoLibraryPageState createState() => new VideoLibraryPageState();
}

class VideoLibraryPageState extends State<VideoLibraryPage> {
  Future<bool>? status;
  String user_message = "";
  List<Widget> video_list = [];

  @override
  void initState() {
    super.initState();
    _getVideoData();
  }

  void _getVideoData() async {
    Log.debug("VideoLibraryPage | _getVideoData", "Starting...");
    Video mh = new Video();
    List<Prompt> video_prompts = await mh.getList();
    Log.debug("VideoLibraryPage | _getVideoData",
        "Received list. Count is " + video_prompts.length.toString());
    video_prompts.forEach((prompt) {
      Log.debug("VideoLibraryPage | _getVideoData",
          "Processing prompt: " + prompt.name);
      video_list.add(InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VideoApp(prompt)),
            );
          },
          child: ListTile(
              leading: Icon(Icons.ondemand_video_outlined),
              title: Text(prompt.name),
              subtitle: Text(prompt.description))));
      video_list.add(Divider(height: 0));
      Log.debug("VideoLibraryPage | _getVideoData",
          "video_list lenggth is: " + this.video_list.length.toString());
    });

    Log.debug("VideoLibraryPage | _getVideoData",
        "Setting state: video_list length is: " + video_list.length.toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0,
          bottomOpacity: 0.0,
          backgroundColor: Colors.grey[100],
          foregroundColor: Colors.black38,
          centerTitle: true,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: GestureDetector(
              onTap: () {
                setState(() {});
              },
              child: Text('Video Library')),
        ),
        body: ListView.builder(
            itemCount: video_list.length,
            padding: EdgeInsets.all(8),
            itemBuilder: (BuildContext context, int Itemindex) {
              return video_list[Itemindex]; // return your widget
            }));
  }
}
