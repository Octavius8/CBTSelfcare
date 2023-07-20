import 'package:flutter/material.dart';
import 'moodtracker.dart';
import 'config/theme_info.dart';

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

  void _loadMoodTracker() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MoodTracker()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        bottomOpacity: 0.0,
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black38,
        centerTitle: true,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('CBT Selfcare'),
      ),
      body: Column(children: [
        Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(
                  color: Colors.grey[100]!,
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
                      elevation: 1,
                      clipBehavior: Clip.hardEdge,
                      child: Center(
                          child: Text("Start Here",
                              textAlign: TextAlign.center))))),

          //Toolkit
          Padding(
              padding: EdgeInsets.all(ThemeInfo.size_card_padding),
              child: Row(
                children: [
                  ToolkitIcon(
                      icon: Icons.edit_calendar,
                      title: "Mood\nTracker",
                      onTap: _loadMoodTracker)
                ],
              ))
        ])
      ]),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _loadMoodTracker,
        tooltip: 'Increment',
        child: Icon(Icons.chat_bubble),
      ),*/
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          color: ThemeInfo.primary_color,
                          shape: BoxShape.circle),
                      child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(icon, color: Colors.white))),
                  Text(this.title, textAlign: TextAlign.center)
                ]),
            onTap: this.onTap));
  }
}
