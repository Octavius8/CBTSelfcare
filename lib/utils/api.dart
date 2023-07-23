import 'package:http/http.dart' as http;
import "../models/sqlite_database.dart";
import "../models/prompt.dart";
import "../utils/logger.dart";
import "../config/api_configs.dart";
import 'dart:convert';

class Api {
  Future<String?> postRequest({required String method, String? data}) async {
    var url = Uri.parse(APIConfigs.api_url);
    var body = jsonEncode(
        {'apikey': APIConfigs.api_key, 'method': method, 'data': data ?? ""});

    Log.debug("Api | postRequest()", "Body: " + body);
    http.Response? finalResponse;
    await http
        .post(url, headers: {"Content-Type": "application/json"}, body: body)
        .then((http.Response response) {
      finalResponse = response;

      Log.debug(
          "Api | postRequest()", "Response status: ${response.statusCode}");

      Log.debug("Api | postRequest()", "Response body: ${response.body}");
    });

    Log.debug("Api | postRequest()",
        "returning response:" + (finalResponse?.body ?? ""));
    return finalResponse?.body;
  }
}
