import 'package:flutter/material.dart';
import 'models/book_club.dart';
import 'models/prompt.dart';
import 'utils/logger.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'utils/api.dart';
import 'config/system_constants.dart';
import 'config/theme_configs.dart';

class BookClubPage extends StatefulWidget {
  @override
  BookClubPageState createState() => new BookClubPageState();
}

class BookClubPageState extends State<BookClubPage> {
  Future<bool>? status;
  String user_message = "";
  List<Widget> mental_health_list = [];

  @override
  void initState() {
    super.initState();
    _getMentalHealthData();
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _getMentalHealthData() async {
    Log.debug(" BookClubPage | _getMentalHealthData", "Starting...");
    BookClub mh = new BookClub();
    List<Prompt> mental_health_prompts = await mh.getList();
    Log.debug(" BookClubPage | _getMentalHealthData",
        "Received list. Count is " + mental_health_prompts.length.toString());
    mental_health_prompts.forEach((prompt) {
      Log.debug(" BookClubPage | _getMentalHealthData",
          "Processing prompt: " + prompt.name);
      mental_health_list.add(InkWell(
          onTap: () {
            Api api = new Api();
            api.logActivity("BOOK_CLICK_" + prompt.prompt_id.toString());
            _launchUrl(prompt.extra_data1);
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
                leading: Container(
                    width: 80, child: Image.network(prompt.extra_data2)),
                title: Text(prompt.name,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(prompt.description)),
          )));
      mental_health_list.add(Divider(height: 0));
      Log.debug(
          " BookClubPage | _getMentalHealthData",
          "mental_health_list lenggth is: " +
              this.mental_health_list.length.toString());
    });

    Log.debug(
        " BookClubPage | _getMentalHealthData",
        "Setting state: mental_health_list length is: " +
            mental_health_list.length.toString());
    showDialog(
        context: context,
        builder: (BuildContext context) => _buildPopupDialog(context));
    setState(() {});
  }

  Widget _buildPopupDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Book Club'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
              child: Padding(
                  padding: EdgeInsets.all(ThemeConfigs.size_card_padding),
                  child: Icon(Icons.book_rounded,
                      color: ThemeConfigs.color_primary,
                      size: ThemeConfigs.size_icon_large))),
          Center(child: Text(SystemConstants.popup_bookclub_narration)),
        ],
      ),
      actions: <Widget>[
        new TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
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
              child: Text('Book Club')),
        ),
        body: ListView.builder(
            itemCount: mental_health_list.length,
            padding: EdgeInsets.all(8),
            itemBuilder: (BuildContext context, int Itemindex) {
              return mental_health_list[Itemindex]; // return your widget
            }));
  }
}
