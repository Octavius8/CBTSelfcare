import 'dart:ffi';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:flutter/material.dart';
import 'moodtracker.dart';
import 'mental_hygiene_page.dart';
import 'models/mental_hygiene.dart';
import 'models/prompt.dart';
import 'config/theme_info.dart';
import 'models/sqlite_database.dart';
import 'dart:developer';
import 'dart:math';
import 'utils/logger.dart';
import 'video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'CBT Selfcare';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: ThemeInfo.color_text_default, //<-- SEE HERE
              displayColor: ThemeInfo.color_text_default, //<-- SEE HERE
            ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.
  // This class is the configuration for the state.
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<Prompt> mental_health_prompts = [];
  Prompt? randomMentalHygienePrompt;
  int randomNumber = 0;

  initState() {
    // ignore: avoid_print
    Log.debug("MyHomePage | initState()", "Starting initState...");
    _getMentalHealthData();
  }

  void _loadMoodTracker() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MoodTracker()),
    );
  }

  void _loadMentalHygienePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MentalHygienePage()),
    );
  }

  void _loadVideoPlayer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VideoApp()),
    );
  }

  void _getMentalHealthData() async {
    print("Starting...");
    MentalHygiene mh = new MentalHygiene();
    mental_health_prompts = await mh.getList();
    _counter = mental_health_prompts.length;
    Random random = new Random();
    int randomNumber = random.nextInt(_counter);
    randomMentalHygienePrompt = mental_health_prompts[randomNumber];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        bottomOpacity: 0.0,
        backgroundColor: ThemeInfo.color_secondary,
        foregroundColor: ThemeInfo.color_text_default,
        centerTitle: true,
        title: Row(children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset('assets/logo_alt.png', height: 24),
          ),
          Text("CBT Selfcare", style: TextStyle(color: ThemeInfo.color_primary))
        ]),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        //title: Text('CBT Selfcare'),
      ),
      body: Column(children: [
        Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: ThemeInfo.color_secondary,
                border: Border.all(
                  color: ThemeInfo.color_secondary,
                ),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            margin: EdgeInsets.only(bottom: 24),
            width: MediaQuery.of(context).size.width,
            child: Center(child: Text("Welcome to Selfcare"))),
        Column(children: [
          SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                  padding: EdgeInsets.all(ThemeInfo.size_card_padding),
                  child: Card(
                      child: Padding(
                          padding: EdgeInsets.all(ThemeInfo.size_card_padding),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //My Tasks
                                Padding(
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: Text("My Tasks:",
                                        style: TextStyle(
                                          fontSize: ThemeInfo.font_title_size,
                                          // fontWeight: FontWeight.bold
                                        ))),

                                // Videos
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16),
                                      child: Icon(Icons.video_library,
                                          size: ThemeInfo.size_icon_small,
                                          color: ThemeInfo.color_primary),
                                    ),
                                    Text(
                                      ("Video:"),
                                    ),
                                    InkWell(
                                      onTap: _loadVideoPlayer,
                                      child: Text((" Getting Started"),
                                          style: TextStyle(
                                              color: ThemeInfo.color_accent)),
                                    ),
                                  ]),
                                ),

                                // Trackers
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16),
                                      child: Icon(Icons.edit_calendar,
                                          size: ThemeInfo.size_icon_small,
                                          color: ThemeInfo.color_primary),
                                    ),
                                    Text(
                                      ("Tracker:"),
                                    ),
                                    InkWell(
                                        child: Text(
                                          ("  Mood Tracker"),
                                          style: TextStyle(
                                              color: ThemeInfo.color_accent),
                                        ),
                                        onTap: _loadMoodTracker),
                                  ]),
                                ),

                                //Mental Hygiene
                                Wrap(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16),
                                    child: Icon(Icons.clean_hands,
                                        size: ThemeInfo.size_icon_small,
                                        color: ThemeInfo.color_primary),
                                  ),
                                  InkWell(
                                      onTap: () => showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                AlertDialog(
                                              title: Text(
                                                  (randomMentalHygienePrompt
                                                          ?.name ??
                                                      "")),
                                              content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.clean_hands,
                                                        color: ThemeInfo
                                                            .color_primary),
                                                    Text(
                                                      (randomMentalHygienePrompt
                                                              ?.description ??
                                                          ""),
                                                    )
                                                  ]),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, 'OK'),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          ),
                                      child: Text(
                                          (randomMentalHygienePrompt?.name ??
                                              ""),
                                          style: TextStyle(
                                              color: ThemeInfo.color_accent))),
                                  Padding(
                                      padding: EdgeInsets.only(left: 16),
                                      child: InkWell(
                                          child: Icon(Icons.refresh,
                                              size: 16,
                                              color: ThemeInfo.color_primary),
                                          onTap: _getMentalHealthData)),
                                ]),
                              ]))))),

          //Toolkit
          Padding(
              padding: EdgeInsets.only(
                  left: ThemeInfo.size_card_padding,
                  right: ThemeInfo.size_card_padding,
                  top: ThemeInfo.size_card_inter_padding),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Toolkit",
                        style: TextStyle(fontSize: ThemeInfo.font_title_size)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ToolkitIcon(
                            icon: Icons.edit_calendar,
                            title: "Mood\nTracker",
                            onTap: _loadMoodTracker),
                        ToolkitIcon(
                            icon: Icons.clean_hands,
                            title: "Mental\nHygiene",
                            onTap: _loadMentalHygienePage)
                      ],
                    )
                  ]))
        ])
      ]),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _loadMoodTracker,
        tooltip: 'Increment',
        child: Icon(Icons.chat_bubble),
      ),*/
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.area_chart),
              label: 'Performance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library),
              label: 'Videos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: 0,
          selectedItemColor: ThemeInfo.color_accent,
          unselectedItemColor: ThemeInfo.color_text_default,
          onTap: (index) {
            int a = 1;
          }),
    );
  }
}

class ToolkitIcon extends StatelessWidget {
  IconData icon;
  String title;
  VoidCallback onTap;
  ToolkitIcon({required this.icon, required this.title, required this.onTap});

  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: InkWell(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          color: ThemeInfo.color_primary,
                          shape: BoxShape.circle),
                      child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(icon, color: Colors.white))),
                  Text(this.title, textAlign: TextAlign.center)
                ]),
            onTap: this.onTap));
  }
}
