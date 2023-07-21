import 'package:flutter/material.dart';
import 'config/messages.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class MoodTracker extends StatefulWidget {
  @override
  MoodTrackerState createState() => new MoodTrackerState();
}

class MoodTrackerState extends State<MoodTracker> {
  Future<bool>? status;
  String user_message = "";
  int count = 0;
  List<types.Message> _messages = [];
  List<types.Message> _questionMessages = [];
  List<String> _questions = [
    "What's the situation?",
    "Who is present?",
    "What are you doing?",
    "Where is it happening?",
    "What dominant emotion are you feeling?",
    "Rate how strong it is from 0-100",
    "What are the unhelpful thoughts going through your mind?*", //Link to description
    "What evidence is there in support of this thought?",
    "What evidence is there against the unhelpful thought?",
    "Whats a more balanced or alternative thought?",
    "How much do you believe this alternative thought from 0-100?",
    "How strong are your feelings now from 0-100?",
    "Thank you for sharing. That is all for this session."
  ];

  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

  final _BotUser = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ad',
  );

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    var textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);

    //bot feedback
    count++;
    textMessage = types.TextMessage(
      author: _BotUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: _questions[count],
    );
    _addMessage(textMessage);
  }

  void _loadMessages() {
    //Initial Message
    final textMessage = types.TextMessage(
      author: _BotUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: Messages.CHAT_INITIAL_MESSAGE,
    );

    _addMessage(textMessage);
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
        title: Text('Mood Tracker'),
      ),
      body: Chat(
        messages: _messages,
        /*onAttachmentPressed: _handleAttachmentPressed,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,*/
        onSendPressed: _handleSendPressed,
        showUserAvatars: true,
        showUserNames: true,
        user: _user,
      ),
    );
  }
}
