import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'models/conversation.dart';
import 'models/mooddata.dart';

class ProgressTrackerPage extends StatefulWidget {
  @override
  ProgressTrackerPageState createState() => new ProgressTrackerPageState();
}

class ProgressTrackerPageState extends State<ProgressTrackerPage> {
  Future<bool>? status;
  String user_message = "";
  Map<String, List> map = new Map();
  List<_SalesData> data = [
    _SalesData('Jan', 35),
    _SalesData('Feb', 28),
    _SalesData('Mar', 34),
    _SalesData('Apr', 32),
    _SalesData('May', 40)
  ];

  List lineSeriesList = [];

  @override
  void initState() {
    getMoodData();
    super.initState();
  }

  void getMoodData() async {
    Conversation conv = new Conversation();
    map = await conv.getMoodData();

    List lineSeriesList = [];
    map.forEach((key, value) {
      lineSeriesList.add(LineSeries<MoodData, String>(
          dataSource: value,
          xValueMapper: (_SalesData sales, _) => sales.year,
          yValueMapper: (_SalesData sales, _) => sales.sales,
          name: 'Sales',
          // Enable data label
          dataLabelSettings: DataLabelSettings(isVisible: true)));
    });
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
              series: <ChartSeries<_SalesData, String>>[
                LineSeries<_SalesData, String>(
                    dataSource: data,
                    xValueMapper: (_SalesData sales, _) => sales.year,
                    yValueMapper: (_SalesData sales, _) => sales.sales,
                    name: 'Sales',
                    // Enable data label
                    dataLabelSettings: DataLabelSettings(isVisible: true)),
              ]),
        ]));
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
