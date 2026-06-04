import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/user_session.dart';
import '../config/api_config.dart';

Future<bool> saveTrip(List<String> items) async {
  if (UserSession.userId == null) {
    print("❌ ERROR: userId NULL");
    return false;
  }

  try {
    final url = Uri.parse("${ApiConfig.baseUrl}/trip");

    print("🚀 SEND TO API:");
    print("USER ID: ${UserSession.userId}");
    print("ITEMS: $items");
    print("URL: $url");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": UserSession.userId, "items": items}),
    );

    print("📦 STATUS CODE: ${response.statusCode}");
    print("📦 RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        print("✅ SUCCESS SAVE TRIP");
        return true;
      } else {
        print("❌ FAILED SAVE: ${data["message"]}");
        return false;
      }
    } else {
      print("❌ HTTP ERROR: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("❌ ERROR SAVE TRIP: $e");
    return false;
  }
}

Future<List<dynamic>> fetchTrip() async {
  if (UserSession.userId == null) {
    print("❌ ERROR: userId NULL");
    return [];
  }

  try {
    final url = "${ApiConfig.baseUrl}/trip/${UserSession.userId}";
    print("📥 FETCH: $url");

    final response = await http.get(Uri.parse(url));

    print("📦 FETCH STATUS: ${response.statusCode}");
    print("📦 FETCH BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      return data["data"];
    } else {
      return [];
    }
  } catch (e) {
    print("❌ ERROR FETCH: $e");
    return [];
  }
}
