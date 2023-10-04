import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'conversation_page.dart';
import 'video_library_page .dart';
import 'progress_tracker_page.dart';
import 'mental_hygiene_page.dart';
import 'book_club_page.dart';
import 'models/mental_hygiene.dart';
import 'models/lecture.dart';
import 'models/prompt.dart';
import 'config/theme_configs.dart';
import 'config/api_configs.dart';
import 'models/sqlite_database.dart';
import 'dart:math';
import 'utils/logger.dart';
import 'video_player.dart';
import 'utils/api.dart';
import 'config/system_constants.dart';
import 'dart:io';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shake/shake.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:share_plus/share_plus.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await AndroidAlarmManager.initialize();
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
        debugShowCheckedModeBanner: false,
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
  String uid = "";
  bool dataSynced = false;
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  initState() {
    // ignore: avoid_print
    Log.debug("MyHomePage | initState()", "Starting initState...");
    ShakeDetector detector = ShakeDetector.autoStart(onPhoneShake: () {
      // Do stuff on phone shake
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Updating Data..."),
      ));
      initialization();
    });
    initialization();

    WidgetsFlutterBinding.ensureInitialized();
    localNotificationSetup();
  }

  void onSelectNotification(NotificationResponse nr) {
    Api api = new Api();
    api.logActivity("NOTIFICATION_MOODTRACKER_CLICK");
    _loadConversation(SystemConstants.conversation_tag_mood_tracker);
  }

  Future<void> localNotificationSetup() async {
    const androidInitializationSetting =
        AndroidInitializationSettings('@drawable/app_icon');
    const iosInitializationSetting = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
        android: androidInitializationSetting, iOS: iosInitializationSetting);
    await _flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: onSelectNotification);

    await AndroidAlarmManager.initialize();

    await AndroidAlarmManager.periodic(
        const Duration(seconds: 20), 0, showLocalNotification);
  }

  String showLocalNotification() {
    String title = "Wadada";
    String body = "Ras Wadada!";
    Log.debug("Main showLocalNotification | ", "Showing local Notification");
    return title;
    /*const androidNotificationDetail = AndroidNotificationDetails(
        '0', // channel Id
        'general' // channel Name
        );
    const iosNotificatonDetail = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      iOS: iosNotificatonDetail,
      android: androidNotificationDetail,
    );
    _flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);*/
  }

  void checkAppVersion() async {
    try {
      Api api = new Api();
      api.logActivity("LOGIN");
      String api_response =
          await api.postRequest(method: "getLatestVersion") ?? "";
      if (api_response == "") {
        //No App Version data returned
        Log.debug("Main | checkAppVersion()", "No data fetched.");
      } else {
        //Version Data Found
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String system_version =
            packageInfo.version + "+" + packageInfo.buildNumber;

        var json_response = jsonDecode(api_response);
        var jsonObject = jsonDecode(json_response["data"]);
        String api_version = jsonObject['version'];
        String api_data = jsonObject['data'];

        Log.debug(
            "Main | checkAppVersion()",
            "API Version is  " +
                api_version +
                " system version is " +
                system_version);

        if (api_version != system_version) {
          showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopupDialog(context,
                  title: 'New Version Available',
                  data: api_data,
                  icon: Icons.update,
                  action: InkWell(
                      onTap: () {
                        _launchUrl(APIConfigs.playStoreLink, external: true);
                        api.logActivity("POPUP_UPDATE_APP_CLICK");
                      },
                      child: const Text('Update'))));
        } else {
          SqliteDatabase db = new SqliteDatabase();
          await db.connect();
          int logins = int.parse(await db.getConfig("LOGINS"));
          Log.debug("Main | CheckAppVersion",
              "Number of logins is: " + logins.toString());
          switch (logins) {
            case 1:
              Log.debug("Main | Load Popup", "logins count is 1.");
              String _title = "Welcome to the CBT App!";
              String _body =
                  "Thanks for giving the app a try.\nTo begin, follow the prompts under the Getting Started Section.\n";
              showDialog(
                  context: context,
                  builder: (BuildContext context) => _buildPopupDialog(context,
                      title: _title, data: _body, icon: Icons.celebration));
              break;
            case 3:
              Log.debug("Main | Load Popup", "logins count is 3.");
              String _title = "Share this App With Someone You Care About.";
              String _body =
                  "Enjoying this app? Please share it with your friends and loved ones by selecting the share button.";

              showDialog(
                  context: context,
                  builder: (BuildContext context) => _buildPopupDialog(context,
                      title: _title,
                      data: _body,
                      icon: Icons.share,
                      action: InkWell(
                          onTap: () {
                            api.logActivity("POPUP_SHARE_LINK_CLICK");
                            Share.share(APIConfigs.shareLink);
                          },
                          child: const Text('Share'))));
              break;
            case 6:
              Log.debug("Main | Load Popup", "logins count is 3.");
              String _title = "Want to Support us?";
              String _body =
                  "Please rate and give your feedback on the Playstore. :)";

              showDialog(
                  context: context,
                  builder: (BuildContext context) => _buildPopupDialog(context,
                      title: _title,
                      data: _body,
                      icon: Icons.star_rate,
                      action: InkWell(
                          onTap: () {
                            api.logActivity("POPUP_RATE_APP_CLICK");
                            _launchUrl(APIConfigs.playStoreLink,
                                external: true);
                          },
                          child: const Text('Rate The App'))));
              break;
            default:
              Log.debug(
                  "Main | Load Popup", "logins count is " + logins.toString());

              if (logins % 10 == 0) {
                String _title = "Want to Support us?";
                String _body =
                    "Please rate and give your feedback on the Playstore. :)";
                showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildPopupDialog(context,
                            title: _title,
                            data: _body,
                            icon: Icons.star_rate,
                            action: InkWell(
                                onTap: () {
                                  api.logActivity("POPUP_RATE_APP_CLICK");
                                  _launchUrl(APIConfigs.playStoreLink,
                                      external: true);
                                },
                                child: const Text('Rate The App'))));
              } else if (logins % 7 == 0) {
                String _title = "Share this App With Someone You Care About.";
                String _body =
                    "Enjoying this app? Please share it with your friends and loved ones by selecting the share button.";

                showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildPopupDialog(context,
                            title: _title,
                            data: _body,
                            icon: Icons.share,
                            action: InkWell(
                                onTap: () {
                                  api.logActivity("POPUP_SHARE_LINK_CLICK");
                                  Share.share(APIConfigs.shareLink);
                                },
                                child: const Text('Share'))));
                break;
              }
          }
        }
      }
    } catch (Ex) {
      int a = 1;
    }
  }

  void initialization() async {
    dataSynced = false;
    //Check permissions
    if (!await Permission.storage.request().isGranted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      Log.debug("Permissions", statuses[Permission.location].toString());
    }

    //Shake event.

    //Get device ID
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      uid = androidInfo.serialNumber + "_" + androidInfo.id;
      Log.debug('Main | initialization()', 'Android Device');
      Log.debug('Main | initialization()', 'Unique ID is  $uid');
    } catch (ex) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      uid = iosInfo.utsname.version + "_" + iosInfo.identifierForVendor!;
      Log.debug('Main | initialization()', 'IOS Device');
      Log.debug('Main | initialization()', 'Unique ID is  $uid');
    }

    //Sync Server Data
    await _serverSync();
    dataSynced = true;

    //Configs
    SqliteDatabase db = new SqliteDatabase();
    await db.connect();
    //db.setConfig("LOGINS", "0");

    setState(() {});
  }

  Future<bool> _serverSync() async {
    SqliteDatabase db = new SqliteDatabase();
    await db.connect(); //reset: true);
    await db.serverSync(uid);
    int newCount = int.parse(await db.getConfig("LOGINS")) + 1;
    Log.debug("Main Login Count ", "New Count is " + newCount.toString());
    await db.setConfig("LOGINS", newCount.toString());
    await db.disconnect();
    checkAppVersion();
    _getMentalHealthData();
    _getLatestLecture();

    return true;
  }

  Future<void> _launchUrl(String url, {bool external = true}) async {
    if (external) {
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } else {
      if (!await launchUrl(Uri.parse(url))) {
        throw Exception('Could not launch $url');
      }
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

  void _loadProgressTracker() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProgressTrackerPage()),
    );
  }

  void _loadBookClubPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookClubPage()),
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

  Widget _buildPopupDialog(BuildContext context,
      {required String title,
      required String data,
      required IconData icon,
      Widget action = const SizedBox.shrink()}) {
    return new AlertDialog(
      icon: Icon(icon,
          color: ThemeConfigs.color_primary,
          size: ThemeConfigs.size_icon_large),
      title: Text(title),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(data),
        ],
      ),
      actions: <Widget>[
        new TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        new TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: action,
        ),
      ],
    );
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
                  margin: EdgeInsets.only(bottom: 16),
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: Text(""))),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: InkWell(
                          onTap: () {
                            showLocalNotification();
                            Log.debug("Main", "Showing Android Notification");
                          },
                          child: Row(children: [
                            Text("Start Here",
                                style: TextStyle(
                                    fontSize: ThemeConfigs.font_title_size)),
                            Expanded(child: Text("")),
                            Padding(
                              padding: const EdgeInsets.only(right: 24.0),
                              child: InkWell(
                                onTap: () {
                                  Api api = new Api();
                                  api.logActivity(
                                      "HOMESCREEN_SHARE_LINK_CLICK");
                                  String _title =
                                      "Share this App With Someone You Care About.";
                                  String _body =
                                      "Enjoying this app? Please share it with your friends and loved ones by selecting the share button.";

                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          _buildPopupDialog(context,
                                              title: _title,
                                              data: _body,
                                              icon: Icons.share,
                                              action: InkWell(
                                                  onTap: () {
                                                    Api api = new Api();
                                                    api.logActivity(
                                                        "HOMESCREEN_POPUP_SHARE_LINK_CLICK");
                                                    Share.share(
                                                        APIConfigs.shareLink);
                                                  },
                                                  child: const Text('Share'))));
                                },
                                child: Icon(Icons.share,
                                    size: ThemeConfigs.size_icon_small,
                                    color: ThemeConfigs.color_accent),
                              ),
                            ),
                          ]),
                        )),
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
                                  child: dataSynced
                                      ? Padding(
                                          padding: EdgeInsets.all(
                                              ThemeConfigs.size_card_padding),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                //My Tasks
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 20),
                                                    child: Text("My Tasks:",
                                                        style: TextStyle(
                                                          fontSize: ThemeConfigs
                                                              .font_title_size,
                                                          // fontWeight: FontWeight.bold
                                                        ))),

                                                // Videos
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 12.0),
                                                  child: Row(children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 16,
                                                              right: 16),
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
                                                        Api api = new Api();
                                                        api.logActivity(
                                                            "MYTASKS_VIDEO_CLICK");
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 12.0),
                                                  child: Row(children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 16,
                                                              right: 16),
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
                                                          Api api = new Api();
                                                          api.logActivity(
                                                              "MYTASKS_TRACKER_CLICK");
                                                          _loadConversation(
                                                              SystemConstants
                                                                  .conversation_tag_mood_tracker);
                                                        }),
                                                  ]),
                                                ),

                                                //Mental Hygiene
                                                Wrap(children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 16,
                                                            right: 16),
                                                    child: Icon(
                                                        Icons.clean_hands,
                                                        size: ThemeConfigs
                                                            .size_icon_default,
                                                        color: ThemeConfigs
                                                            .color_primary),
                                                  ),
                                                  InkWell(
                                                      onTap: () {
                                                        Api api = new Api();
                                                        api.logActivity(
                                                            "MYTASKS_MH_CLICK");
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
                                                                child:
                                                                    const Text(
                                                                        'OK'),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                      child: Text(
                                                          (randomMentalHygienePrompt
                                                                  ?.name ??
                                                              ""),
                                                          style: TextStyle(
                                                              color: ThemeConfigs
                                                                  .color_accent))),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 16),
                                                      child: InkWell(
                                                          child: Icon(
                                                              Icons.refresh,
                                                              size: ThemeConfigs
                                                                  .size_icon_default,
                                                              color: ThemeConfigs
                                                                  .color_primary),
                                                          onTap: () {
                                                            Api api = new Api();
                                                            api.logActivity(
                                                                "MYTASKS_MH_RELOAD");
                                                            _getMentalHealthData();
                                                          })),
                                                ]),
                                              ]))
                                      : Center(
                                          child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 32.0, bottom: 32),
                                          child: CircularProgressIndicator(
                                              color:
                                                  ThemeConfigs.color_primary),
                                        ))),
                            ))),

                    //Notices
                    Center(
                        child: Container(
                            margin: EdgeInsets.only(bottom: 0),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: ThemeConfigs.size_card_padding,
                                  right: ThemeConfigs.size_card_padding,
                                  bottom: ThemeConfigs.size_card_padding),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: FadeInImage(
                                      image: NetworkImage(
                                          'https://cbt.ovidware.com/files/ad1.jpg'),
                                      placeholder:
                                          AssetImage('assets/ad1.jpg'))),
                            ))),

                    //Toolkit
                    Padding(
                        padding: EdgeInsets.only(
                            left: ThemeConfigs.size_card_padding,
                            right: ThemeConfigs.size_card_padding,
                            top: ThemeConfigs.size_card_inter_padding,
                            bottom: ThemeConfigs.size_card_inter_padding * 2),
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
                                          Api api = new Api();
                                          api.logActivity("MOODTRACKER_CLICK");
                                          _loadConversation(SystemConstants
                                              .conversation_tag_mood_tracker);
                                        }),
                                  ),
                                  Expanded(
                                    child: ToolkitIcon(
                                        icon: Icons.clean_hands,
                                        title: "Mental\nHygiene",
                                        enabled: true,
                                        onTap: () {
                                          Api api = new Api();
                                          api.logActivity(
                                              "MENTALHYGIENE_CLICK");
                                          _loadMentalHygienePage();
                                        }),
                                  ),
                                  Expanded(
                                    child: ToolkitIcon(
                                        icon: Icons.emoji_food_beverage,
                                        title: "Gratitude\nJournal",
                                        enabled: true,
                                        onTap: () {
                                          Api api = new Api();
                                          api.logActivity(
                                              "GRATITUDEJOURNAL_CLICK");
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
                                            Api api = new Api();
                                            api.logActivity(
                                                "SPEAKTOAPRO_CLICK");
                                            _launchUrl(APIConfigs.speakToAPro,
                                                external: true);
                                          })),
                                ],
                              ),
                              Row(children: [
                                ToolkitIcon(
                                    icon: Icons.book_rounded,
                                    title: "Book Club",
                                    enabled: true,
                                    onTap: () {
                                      Api api = new Api();
                                      api.logActivity("BOOKCLUB_CLICK");
                                      _loadBookClubPage();
                                    }),
                              ]),
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
                              Api api = new Api();
                              api.logActivity("BMC_REDIRECT");
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
                            Api api = new Api();
                            api.logActivity("BMC_CANCEL");
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
              icon: Icon(Icons.area_chart),
              label: 'Progress',
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
                Api api = new Api();
                api.logActivity("VIDEOLIBRARY_CLICK");
                _loadVideoLibrary();
                break;
              case 2:
                Api api = new Api();
                api.logActivity("PROGRESS_TRACKER_CLICK");
                _loadProgressTracker();
                break;
              case 3:
                Api api = new Api();
                api.logActivity("ABOUTAPP_CLICK");
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
              case 4:
                Api api = new Api();
                api.logActivity("BMCMENU_CLICK");
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
