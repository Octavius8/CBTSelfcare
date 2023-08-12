import 'dart:ffi';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'conversation_page.dart';
import 'video_library_page .dart';
import 'mental_hygiene_page.dart';
import 'models/mental_hygiene.dart';
import 'models/lecture.dart';
import 'models/prompt.dart';
import 'config/theme_configs.dart';
import 'models/sqlite_database.dart';
import 'dart:developer';
import 'dart:math';
import 'utils/logger.dart';
import 'video_player.dart';
import 'utils/api.dart';
import 'config/api_configs.dart';
import 'config/system_constants.dart';
import 'dart:io';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'CBT Selfcare';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    double splashscreenOpacity = 0;
    return MaterialApp(
        title: _title,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: ThemeConfigs.color_text_default, //<-- SEE HERE
                displayColor: ThemeConfigs.color_text_default, //<-- SEE HERE
              ),
        ),
        home: FlutterSplashScreen.fadeIn(
          duration: Duration(seconds: 4),
          backgroundColor: Colors.white,
          onInit: () {
            debugPrint("On Init");
          },
          onEnd: () {
            debugPrint("On End");
          },
          childWidget: SizedBox(
            height: 200,
            width: 200,
            child: AnimatedOpacity(
                duration: Duration(seconds: 5),
                opacity: 1,
                child: Image.asset("assets/logo_alt.png")),
          ),
          onAnimationEnd: () => debugPrint("On Fade In End"),
          defaultNextScreen: const MyHomePage(),
        ));
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
  Prompt? latest_lecture_prompt;
  bool adsEnabled = false;
  int randomNumber = 0;

  initState() {
    // ignore: avoid_print
    Log.debug("MyHomePage | initState()", "Starting initState...");

    initialization();
  }

  void initialization() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print
    await _serverSync();
  }

  Future<bool> _serverSync() async {
    SqliteDatabase db = new SqliteDatabase();
    await db.connect(reset: true);
    await db.serverSync();
    await db.disconnect();
    _getMentalHealthData();
    _getLatestLecture();
    return true;
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  void _loadConversation(conversation_tag) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ConversationPage(conversation_tag)),
    );
  }

  void _loadMentalHygienePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MentalHygienePage()),
    );
  }

  void _loadVideoPlayer(Prompt? prompt) {
    if (prompt != null)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VideoApp(prompt)),
      );
  }

  void _loadVideoLibrary() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => VideoLibraryPage()));
  }

  void _getMentalHealthData() async {
    Log.debug("MyHomePage | _getMentalHealthData", "Starting...");
    MentalHygiene mh = new MentalHygiene();
    mental_health_prompts = await mh.getList();
    _counter = mental_health_prompts.length;
    Random random = new Random();
    int randomNumber = random.nextInt(_counter);
    randomMentalHygienePrompt = mental_health_prompts[randomNumber];
    setState(() {});
  }

  void _getLatestLecture() async {
    Log.debug("MyHomePage | _getLatestLecture", "Starting...");
    Lecture lecture = new Lecture();
    latest_lecture_prompt = await lecture.getCurrentLecture();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        bottomOpacity: 0.0,
        backgroundColor: ThemeConfigs.color_secondary,
        foregroundColor: ThemeConfigs.color_text_default,
        centerTitle: true,
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset('assets/logo_alt.png', height: 24),
          ),
          Text("CBT Selfcare",
              style: TextStyle(color: ThemeConfigs.color_primary))
        ]),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        //title: Text('CBT Selfcare'),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
                child: Column(children: [
              Container(
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                      color: ThemeConfigs.color_secondary,
                      border: Border.all(
                        color: ThemeConfigs.color_secondary,
                      ),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  margin: EdgeInsets.only(bottom: 32),
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: Text(""))),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Text("Start Here",
                            style: TextStyle(
                                fontSize: ThemeConfigs.font_title_size))),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                            padding:
                                EdgeInsets.all(ThemeConfigs.size_card_padding),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 16,
                                    offset: Offset(
                                        0, 8), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                    side: BorderSide(
                                      color: Colors.white, //<-- SEE HERE
                                    ),
                                  ),
                                  child: Padding(
                                      padding: EdgeInsets.all(
                                          ThemeConfigs.size_card_padding),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            //My Tasks
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(bottom: 20),
                                                child: Text("My Tasks:",
                                                    style: TextStyle(
                                                      fontSize: ThemeConfigs
                                                          .font_title_size,
                                                      // fontWeight: FontWeight.bold
                                                    ))),

                                            // Videos
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 16.0),
                                              child: Row(children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16, right: 16),
                                                  child: Icon(
                                                      Icons.video_library,
                                                      size: ThemeConfigs
                                                          .size_icon_default,
                                                      color: ThemeConfigs
                                                          .color_primary),
                                                ),
                                                Text(
                                                  ("Video: "),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    _loadVideoPlayer(
                                                        latest_lecture_prompt);
                                                  },
                                                  child: Text(
                                                      (latest_lecture_prompt
                                                              ?.name ??
                                                          ""),
                                                      style: TextStyle(
                                                          color: ThemeConfigs
                                                              .color_accent)),
                                                ),
                                              ]),
                                            ),

                                            // Trackers
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 16.0),
                                              child: Row(children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16, right: 16),
                                                  child: Icon(
                                                      Icons.edit_calendar,
                                                      size: ThemeConfigs
                                                          .size_icon_default,
                                                      color: ThemeConfigs
                                                          .color_primary),
                                                ),
                                                Text(
                                                  ("Tracker:"),
                                                ),
                                                InkWell(
                                                    child: Text(
                                                      ("  Mood Tracker"),
                                                      style: TextStyle(
                                                          color: ThemeConfigs
                                                              .color_accent),
                                                    ),
                                                    onTap: () {
                                                      _loadConversation(
                                                          SystemConstants
                                                              .conversation_tag_mood_tracker);
                                                    }),
                                              ]),
                                            ),

                                            //Mental Hygiene
                                            Wrap(children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16, right: 16),
                                                child: Icon(Icons.clean_hands,
                                                    size: ThemeConfigs
                                                        .size_icon_default,
                                                    color: ThemeConfigs
                                                        .color_primary),
                                              ),
                                              InkWell(
                                                  onTap: () =>
                                                      showDialog<String>(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            AlertDialog(
                                                          title: Text(
                                                              (randomMentalHygienePrompt
                                                                      ?.name ??
                                                                  "")),
                                                          content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .clean_hands,
                                                                    color: ThemeConfigs
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
                                                                      context,
                                                                      'OK'),
                                                              child: const Text(
                                                                  'OK'),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                  child: Text(
                                                      (randomMentalHygienePrompt
                                                              ?.name ??
                                                          ""),
                                                      style: TextStyle(
                                                          color: ThemeConfigs
                                                              .color_accent))),
                                              Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 16),
                                                  child: InkWell(
                                                      child: Icon(Icons.refresh,
                                                          size: ThemeConfigs
                                                              .size_icon_default,
                                                          color: ThemeConfigs
                                                              .color_primary),
                                                      onTap:
                                                          _getMentalHealthData)),
                                            ]),
                                          ]))),
                            ))),

                    //Notices
                    Container(
                      margin: EdgeInsets.only(bottom: 0),
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: ThemeConfigs.size_card_padding,
                              right: ThemeConfigs.size_card_padding,
                              bottom: ThemeConfigs.size_card_padding),
                          child: Container(
                              child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            color: ThemeConfigs.color_primary,
                            child: Container(
                              height: 80,
                            ),
                          ))),
                    ),

                    //Toolkit
                    Padding(
                        padding: EdgeInsets.only(
                            left: ThemeConfigs.size_card_padding,
                            right: ThemeConfigs.size_card_padding,
                            top: ThemeConfigs.size_card_inter_padding),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Toolkit",
                                  style: TextStyle(
                                      fontSize: ThemeConfigs.font_title_size)),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ToolkitIcon(
                                        icon: Icons.edit_calendar,
                                        title: "Mood\nTracker",
                                        onTap: () {
                                          _loadConversation(SystemConstants
                                              .conversation_tag_mood_tracker);
                                        }),
                                  ),
                                  Expanded(
                                    child: ToolkitIcon(
                                        icon: Icons.clean_hands,
                                        title: "Mental\nHygiene",
                                        enabled: true,
                                        onTap: _loadMentalHygienePage),
                                  ),
                                  Expanded(
                                    child: ToolkitIcon(
                                        icon: Icons.emoji_food_beverage,
                                        title: "Gratitude\nJournal",
                                        enabled: true,
                                        onTap: () {
                                          _loadConversation(SystemConstants
                                              .conversation_tag_gratitude_journal);
                                        }),
                                  ),
                                  Expanded(
                                      child: ToolkitIcon(
                                          icon: Icons.chat,
                                          title: "Speak With A Pro",
                                          enabled: true,
                                          onTap: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Center(
                                                  child: Text(
                                                      "Currently not available in your area.",
                                                      textAlign:
                                                          TextAlign.center)),
                                            ));
                                          })),
                                ],
                              )
                            ]))
                  ]),
            ])),
          ),

          //Advert Container
          AnimatedPositioned(
              bottom: adsEnabled ? 0 : -50,
              duration: Duration(milliseconds: 300),
              child: Container(
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Text("Buy me a coffee?",
                            style: TextStyle(
                                fontSize: ThemeConfigs.font_title_size)),
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0, left: 16),
                          child: InkWell(
                            onTap: () {
                              _launchUrl(APIConfigs.bmc_url);
                              adsEnabled = false;
                              setState(() {});
                            },
                            child: Text("Yes",
                                style: TextStyle(
                                    color: ThemeConfigs.color_accent,
                                    fontSize: ThemeConfigs.font_title_size)),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            adsEnabled = false;
                            setState(() {});
                          },
                          child: Text("No",
                              style: TextStyle(
                                  fontSize: ThemeConfigs.font_title_size)),
                        )
                      ])),
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  )))
        ],
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _loadMoodTracker,
        tooltip: 'Increment',
        child: Icon(Icons.chat_bubble),
      ),*/
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          elevation: 0,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library),
              label: 'Videos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.help),
              label: 'About',
            ),
            BottomNavigationBarItem(
              icon: Image.asset("assets/buymeacoffee.png", height: 30),
              label: 'Buy Me A Coffee',
            ),
          ],
          currentIndex: 0,
          selectedItemColor: ThemeConfigs.color_accent,
          unselectedItemColor: ThemeConfigs.color_text_default,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          onTap: (index) {
            switch (index) {
              case 1:
                _loadVideoLibrary();
                break;
              case 2:
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text(("About this App")),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        "Author: John Lusumpa\n\n©Ovidware 2023\n",
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  _launchUrl(
                                      "https://www.linkedin.com/in/john-lusumpa-3b373662/");
                                },
                                child: Image(
                                    image: AssetImage('assets/linkedin.png'),
                                    width: 32),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  _launchUrl(APIConfigs.bmc_url);
                                },
                                child: Image(
                                    image: AssetImage(
                                        'assets/buymeacoffeeblack.png'),
                                    height: 32),
                              ),
                            )
                          ])
                    ]),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
                break;
              case 3:
                adsEnabled = adsEnabled ? false : true;
                setState(() {});
                break;
            }
          }),
    );
  }
}

class ToolkitIcon extends StatelessWidget {
  IconData icon;
  String title;
  VoidCallback onTap;
  bool enabled;

  ToolkitIcon(
      {required this.icon,
      required this.title,
      required this.onTap,
      this.enabled = true});

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
                          color: ThemeConfigs.color_primary,
                          shape: BoxShape.circle),
                      child: Padding(
                          padding: EdgeInsets.all(12),
                          child: enabled
                              ? Icon(icon, color: Colors.white)
                              : Icon(Icons.lock, color: Color(0xFF70c5d1)))),
                  Text(enabled ? this.title : "", textAlign: TextAlign.center)
                ]),
            onTap: enabled ? this.onTap : () {}));
  }
}
