import 'package:flutter/foundation.dart';

class Prompt {
  int prompt_id;
  String category;
  String name;
  String description;
  String extra_data1;
  String extra_data2;
  String extra_data3;
  String extra_data4;

  Prompt(
      {required this.prompt_id,
      required this.category,
      required this.name,
      required this.description,
      required this.extra_data1,
      required this.extra_data2,
      required this.extra_data3,
      required this.extra_data4});

  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      prompt_id: json["prompt_id"],
      category: json["category"],
      name: json["name"],
      description: json["description"],
      extra_data1: json["extra_data1"],
      extra_data2: json["extra_data2"],
      extra_data3: json["extra_data3"],
      extra_data4: json["extra_data4"],
    );
  }
}
