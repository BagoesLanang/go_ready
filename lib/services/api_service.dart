import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/user_session.dart';
import '../config/api_config.dart';

// SAVE TRIP
Future<void> saveTrip(List<String> items) async {
  if (UserSession.userId == null) {
    print("ERROR: userId NULL");
    return;
  }

  await http.post(
    Uri.parse("${ApiConfig.baseUrl}/trip"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "user_id": UserSession.userId,
      "items": items,
    }),
  );
}

// FETCH TRIP
Future<List<dynamic>> fetchTrip() async {
  if (UserSession.userId == null) {
    print("ERROR: userId NULL");
    return [];
  }

  final url = "${ApiConfig.baseUrl}/trip/${UserSession.userId}";
  print("FETCH: $url");

  final response = await http.get(Uri.parse(url));

  final data = jsonDecode(response.body);

  if (data["success"] == true) {
    return data["data"];
  } else {
    return [];
  }
}