import 'package:flutter/material.dart';
import 'models/mental_hygiene.dart';
import 'models/prompt.dart';
import 'utils/logger.dart';
import 'dart:async';

class MentalHygienePage extends StatefulWidget {
  @override
  MentalHygienePageState createState() => new MentalHygienePageState();
}

class MentalHygienePageState extends State<MentalHygienePage> {
  Future<bool>? status;
  String user_message = "";
  List<Widget> mental_health_list = [];

  @override
  void initState() {
    super.initState();
    _getMentalHealthData();
  }

  void _getMentalHealthData() async {
    Log.debug("MentalHygienePage | _getMentalHealthData", "Starting...");
    MentalHygiene mh = new MentalHygiene();
    List<Prompt> mental_health_prompts = await mh.getList();
    Log.debug("MentalHygienePage | _getMentalHealthData",
        "Received list. Count is " + mental_health_prompts.length.toString());
    mental_health_prompts.forEach((prompt) {
      Log.debug("MentalHygienePage | _getMentalHealthData",
          "Processing prompt: " + prompt.name);
      mental_health_list.add(ListTile(
          leading: Icon(Icons.psychology),
          title: Text(prompt.name),
          subtitle: Text(prompt.description)));
      mental_health_list.add(Divider(height: 0));
      Log.debug(
          "MentalHygienePage | _getMentalHealthData",
          "mental_health_list lenggth is: " +
              this.mental_health_list.length.toString());
    });

    Log.debug(
        "MentalHygienePage | _getMentalHealthData",
        "Setting state: mental_health_list length is: " +
            mental_health_list.length.toString());
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
              child: Text('Mental Hygiene')),
        ),
        body: ListView.builder(
            itemCount: mental_health_list.length,
            padding: EdgeInsets.all(8),
            itemBuilder: (BuildContext context, int Itemindex) {
              return mental_health_list[Itemindex]; // return your widget
            }));
  }
}
