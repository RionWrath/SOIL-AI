// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'dart:async';

// class ApiService {
//   final String baseUrl = "https://soilapi.hcorp.my.id/api";

//   Future<Map<String, dynamic>> fetchRealTimeData() async {
//     final url = Uri.parse("$baseUrl/get_latest_collect_data");
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final decodedResponse = json.decode(response.body);
//         if (decodedResponse.containsKey('data') &&
//             decodedResponse['data'] is Map<String, dynamic>) {
//           return decodedResponse['data']; // Return real-time data as a map
//         } else {
//           throw Exception("Invalid data format");
//         }
//       } else {
//         throw Exception("Failed to fetch real-time data");
//       }
//     } catch (e) {
//       throw Exception("Error fetching real-time data: $e");
//     }
//   }

//   Future<List<dynamic>> fetchAverageDailyData() async {
//     final url = Uri.parse("$baseUrl/get_all_average_daily");
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         return json.decode(response.body) as List<dynamic>;
//       } else {
//         throw Exception("Failed to fetch average daily data");
//       }
//     } catch (e) {
//       throw Exception("Error fetching average daily data: $e");
//     }
//   }

//   Future<String> fetchLatestMessage() async {
//     final url = Uri.parse("$baseUrl/get_message_latest");
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return data['data']['message'] ?? "No message available";
//       } else {
//         throw Exception("Failed to fetch latest message");
//       }
//     } catch (e) {
//       throw Exception("Error fetching latest message: $e");
//     }
//   }
// }
