import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class CustomCardApp extends StatefulWidget {
  const CustomCardApp({super.key});

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCardApp> {
  final String baseUrl = "https://soilapi.hcorp.my.id/api";
  Map<String, dynamic> realTimeData = {};
  List<dynamic> averageDailyData = [];
  String latestMessage = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    await Future.wait([
      fetchRealTimeData(),
      fetchAverageDailyData(),
      fetchLatestMessage(),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchRealTimeData() async {
    final url = Uri.parse("$baseUrl/get_latest_collect_data");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        // Check if 'data' exists and is a map
        if (decodedResponse.containsKey('data') &&
            decodedResponse['data'] is Map<String, dynamic>) {
          setState(() {
            realTimeData = decodedResponse[
                'data']; // Directly assign the map to realTimeData
          });
        } else {
          print("No 'data' field or it's not a map.");
        }
      } else {
        print("Failed to fetch real-time data. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching real-time data: $e");
    }
  }

  Future<void> fetchAverageDailyData() async {
    final url = Uri.parse("$baseUrl/get_range_average_daily");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          averageDailyData = data;
        });
      } else {
        print(
            "Failed to fetch average daily data. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching average daily data: $e");
    }
  }

  Future<void> fetchLatestMessage() async {
    final url = Uri.parse("$baseUrl/get_message_latest");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          latestMessage = data['data']['message'] ?? "No message available";
        });
        
      } 
      else {
        print("Failed to fetch latest message. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching latest message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // color: const Color.fromARGB(255, 38, 100, 188),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4A90E2),
                    Color.fromARGB(255, 74, 147, 204)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Realtime Database",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            "${realTimeData['created_at']}",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Data Section
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildInfoCard(
                            title: "Temperature",
                            value: "${realTimeData['temperature']}°",
                            unit: "Celcius",
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                          buildInfoCard(
                            title: "Air Humid",
                            value: "${realTimeData['air_humidity']}%",
                            unit: "",
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildInfoCard(
                            title: "Soil Humidity",
                            value: "${realTimeData['soil_humidity']}%",
                            unit: "",
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),

          //Message
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 25, 100, 200),
                    Color(0xFF4A90E2),
                    Color.fromARGB(255, 80, 92, 227)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Message",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Data Section
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildInfoCard(
                            title: "Status",
                            value: latestMessage.isNotEmpty
                                ? latestMessage
                                : "No data",
                            unit: "",
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

//history
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 25, 100, 200),
                    Color(0xFF4A90E2),
                    Color.fromARGB(255, 139, 144, 194)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Average Daily",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Data Section
                  Column(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          
                        ]
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard({
    required String title,
    required dynamic value,
    required String unit,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(217, 33, 33, 33),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 12,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
