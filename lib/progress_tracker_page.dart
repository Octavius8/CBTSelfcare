import 'package:cbt/config/api_configs.dart';
import 'package:cbt/config/theme_configs.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'models/conversation.dart';
import 'models/mooddata.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'utils/api.dart';
import 'conversation_page.dart';
import 'config/system_constants.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ProgressTrackerPage extends StatefulWidget {
  @override
  ProgressTrackerPageState createState() => new ProgressTrackerPageState();
}

class ProgressTrackerPageState extends State<ProgressTrackerPage> {
  Future<bool>? status;
  String user_message = "";
  Map<String, List> map = new Map();
  List lineSeriesList = <ChartSeries<MoodData, String>>[];
  List<ChartSeries<MoodData, String>> dataList = [];
  String adUnitId = APIConfigs.adUnitID;
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    getMoodData();
    loadAd();
    super.initState();
  }

  void getMoodData() async {
    Conversation conv = new Conversation();
    map = await conv.getMoodData();

    map.forEach((key, value) {
      List<MoodData> temp = value as List<MoodData>;
      print("Temp is" + temp[0].toString());
      lineSeriesList.add(LineSeries<MoodData, String>(
          dataSource: temp,
          xValueMapper: (MoodData mood, _) {
            var parsedDate = DateTime.parse(mood.year);
            return DateFormat.MMMd().format(parsedDate);
          },
          yValueMapper: (MoodData mood, _) => mood.sales,
          name: key,
          // Enable data label
          dataLabelSettings: DataLabelSettings(isVisible: true)));
    });

    print("Length is:" + lineSeriesList.length.toString());
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
            title: Text('CBT Selfcare'),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/logo_alt.png',
                    width: ThemeConfigs.size_icon_default),
              )
            ]),
        body: Column(children: [
          Container(
            child: SizedBox(
              width: 300,
              height: 100,
              child: Center(
                  child: Column(children: [
                lineSeriesList.length == 0
                    ? Text(
                        'You have no Mood Tracker entries, click the link below to go to the mood tracker.\n',
                        textAlign: TextAlign.center)
                    : Text("Click the link below to go to the mood tracker.\n",
                        textAlign: TextAlign.center),
                InkWell(
                    onTap: () {
                      Api api = new Api();
                      api.logActivity("CHART_MOODTRACKER_CLICK");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ConversationPage(
                                SystemConstants.conversation_tag_mood_tracker)),
                      ).then((value) {
                        getMoodData();
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_calendar,
                              color: ThemeConfigs.color_accent),
                          Text(" Mood Tracker",
                              style:
                                  TextStyle(color: ThemeConfigs.color_accent))
                        ]))
              ])),
            ),
          ),
          //Initialize the chart widget
          SfCartesianChart(
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
            ),
            primaryXAxis: CategoryAxis(),

            // Chart title
            title: ChartTitle(text: 'Your Progress'),
            // Enable tooltip
            tooltipBehavior: TooltipBehavior(enable: true),
            series: lineSeriesList,
          ),

          //Advert
          Container(
            width: _bannerAd!.size.width.toDouble(),
            height: 72.0,
            alignment: Alignment.center,
            child: AdWidget(ad: _bannerAd!),
          ),
        ]));
  }

  @override
  void dispose() {
    // TODO: Dispose a BannerAd object
    _bannerAd?.dispose();

    super.dispose();
  }

  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          _bannerAd = ad as BannerAd;
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }
}
