import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'models/conversation.dart';
import 'models/mooddata.dart';
import 'dart:convert';

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

  @override
  void initState() {
    getMoodData();
    super.initState();
  }

  void getMoodData() async {
    Conversation conv = new Conversation();
    map = await conv.getMoodData();

    map.forEach((key, value) {
      List<MoodData> temp = value as List<MoodData>;

      lineSeriesList.add(LineSeries<MoodData, String>(
          dataSource: temp,
          xValueMapper: (MoodData mood, _) => mood.year,
          yValueMapper: (MoodData mood, _) => mood.sales,
          name: key,
          // Enable data label
          dataLabelSettings: DataLabelSettings(isVisible: true)));
    });

    print("Length is:" + lineSeriesList.length.toString());
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
          title: Text(''),
        ),
        body: Column(children: [
          //Initialize the chart widget
          SfCartesianChart(
            primaryXAxis: CategoryAxis(),

            // Chart title
            title: ChartTitle(text: 'Your Progress'),
            // Enable legend
            legend: Legend(isVisible: true),
            // Enable tooltip
            tooltipBehavior: TooltipBehavior(enable: true),
            series: lineSeriesList,
          ),
        ]));
  }
}
