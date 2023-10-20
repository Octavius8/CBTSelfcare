import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'config/theme_configs.dart';
import 'utils/api.dart';
import 'conversation_page.dart';
import 'video_library_page .dart';
import 'progress_tracker_page.dart';
import 'config/system_constants.dart';
import "models/sqlite_database.dart";
import 'utils/logger.dart';

class MoodTrackerPage extends StatefulWidget {
  @override
  MoodTrackerPageState createState() => new MoodTrackerPageState();
}

class MoodTrackerPageState extends State<MoodTrackerPage> {
  Future<bool>? status;
  String user_message = "";
  int _current_emoji = 0;
  bool _saved = false;

  _setCurrentEmoji(int a) {
    _current_emoji = a;
    _saved = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  void _saveMood() async {
    SqliteDatabase db = new SqliteDatabase();
    await db.connect();
    var row = {'mood_value': (_current_emoji * 20).toString()};
    try {
      await db.database.insert('mood_data', row);
    } catch (ex) {
      //Table doesn't exist yet.
      await db.create_mood_tracker_table();
      await db.database.insert('mood_data', row);
    }

    var data = db.query("Select count(*) from mood_data");
    Log.debug("MoodTrackerPage | _saveMood", "Data is :" + data.toString());

    _saved = true;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Mood Saved!"),
    ));
    setState(() {});
  }

  void _loadConversation(conversation_tag) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ConversationPage(conversation_tag)),
    );
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
              child: Text('Mood Tracker')),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(height: 100),
            Text(
                DateFormat('EEE, MMM d, yyyy  \n kk:mm').format(DateTime.now()),
                textAlign: TextAlign.center),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _saved
                  ? Text("Mood Has Been Saved !",
                      style: TextStyle(fontSize: ThemeConfigs.font_title_size))
                  : Text("How are you feeling today?",
                      style: TextStyle(fontSize: ThemeConfigs.font_title_size)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                children: [
                  _current_emoji == 5
                      ? Image.asset("assets/emoji5-alt.png", width: 50)
                      : InkWell(
                          onTap: () {
                            _setCurrentEmoji(5);
                          },
                          child: Image.asset("assets/emoji5.png", width: 50)),
                  _current_emoji == 4
                      ? Image.asset("assets/emoji4-alt.png", width: 50)
                      : InkWell(
                          onTap: () {
                            _setCurrentEmoji(4);
                          },
                          child: Image.asset("assets/emoji4.png", width: 50)),
                  _current_emoji == 3
                      ? Image.asset("assets/emoji3-alt.png", width: 50)
                      : InkWell(
                          onTap: () {
                            _setCurrentEmoji(3);
                          },
                          child: Image.asset("assets/emoji3.png", width: 50)),
                  _current_emoji == 2
                      ? Image.asset("assets/emoji2-alt.png", width: 50)
                      : InkWell(
                          onTap: () {
                            _setCurrentEmoji(2);
                          },
                          child: Image.asset("assets/emoji2.png", width: 50)),
                  _current_emoji == 1
                      ? Image.asset("assets/emoji1-alt.png", width: 50)
                      : InkWell(
                          onTap: () {
                            _setCurrentEmoji(1);
                          },
                          child: Image.asset("assets/emoji1.png", width: 50)),
                ],
              ),
            ),
            _saved
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble, color: ThemeConfigs.color_accent),
                      TextButton(
                          onPressed: () {
                            Api api = new Api();
                            api.logActivity("MOODTRACKER_CHAT_CLICK");
                            _loadConversation(
                                SystemConstants.conversation_tag_mood_tracker);
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 12.0, bottom: 24),
                            child: Text("Want to Talk About IT?",
                                style: TextStyle(
                                    color: ThemeConfigs.color_primary)),
                          )),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 24.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: ThemeConfigs.color_primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(88, 36),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                      ),
                      onPressed: () {
                        _saveMood();
                      },
                      child: Text('Save'),
                    ),
                  ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.area_chart, color: ThemeConfigs.color_accent),
                TextButton(
                    onPressed: () {
                      Api api = new Api();
                      api.logActivity("PROGRESS_TRACKER_CLICK");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProgressTrackerPage()),
                      );
                    },
                    child: Text("Progress Chart",
                        style: TextStyle(color: ThemeConfigs.color_primary))),
              ],
            )
          ],
        ));
  }
}
