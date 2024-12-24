import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(SoilMonitoringApp());

class SoilMonitoringApp extends StatelessWidget {
  const SoilMonitoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SoilMonitoringDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SoilMonitoringDashboard extends StatefulWidget {
  const SoilMonitoringDashboard({super.key});

  @override
  _SoilMonitoringDashboardState createState() =>
      _SoilMonitoringDashboardState();
}

class _SoilMonitoringDashboardState extends State<SoilMonitoringDashboard> {
  final String baseUrl = "https://soilapi.hcorp.my.id/api/";
  Map<String, dynamic> realTimeData = {};
  List<dynamic> averageDailyData = [];
  String latestMessage = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await fetchRealTimeData();
    await fetchAverageDailyData();
    await fetchLatestMessage();
  }

  Future<void> fetchRealTimeData() async {
    final url = Uri.parse("$baseUrl/get_collect_data");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          realTimeData = data.isNotEmpty ? data.first : {};
        });
      }
    } catch (e) {
      print("Error fetching real-time data: $e");
    }
  }

  Future<void> fetchAverageDailyData() async {
    final url = Uri.parse("$baseUrl/get_average_daily");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          averageDailyData = data;
        });
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
    } catch (e) {
      print("Error fetching latest message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SOIL.AI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.blue[500],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Real-time Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Real-Time Data',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 16),
                    realTimeData.isNotEmpty
                        ? GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 2,
                            children: [
                              buildDataCard('Temperature', '${realTimeData['temperature']}°C', Colors.orange),
                              buildDataCard('Air Humidity', '${realTimeData['air_humidity']}%', Colors.blue),
                              buildDataCard('Soil Humidity', '${realTimeData['soil_humidity']}%', Colors.green),
                            ],
                          )
                        : Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Average Daily Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average Daily Data',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    averageDailyData.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: averageDailyData.length,
                            itemBuilder: (context, index) {
                              final item = averageDailyData[index];
                              return ListTile(
                                title: Text(item['date']),
                                subtitle: Text(
                                    'Temp: ${item['average_temperature']}°C, Air Hum: ${item['average_air_humidity']}%, Soil Hum: ${item['average_soil_humidity']}%'),
                              );
                            },
                          )
                        : Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Latest Message Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Message',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      latestMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDataCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
