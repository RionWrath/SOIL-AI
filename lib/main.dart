import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(SoilMonitoringApp());

class SoilMonitoringApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SoilMonitoringDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SoilMonitoringDashboard extends StatefulWidget {
  @override
  _SoilMonitoringDashboardState createState() =>
      _SoilMonitoringDashboardState();
}

class _SoilMonitoringDashboardState extends State<SoilMonitoringDashboard> {
  Map<String, dynamic> data = {
    "temperature": "Loading...",
    "air_humidity": "Loading...",
    "soil_humidity": "Loading..."
  };

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    const url = 'https://soilapi.hcorp.my.id/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          data = {
            "temperature": responseData['temperature'].toString(),
            "air_humidity": responseData['air_humidity'].toString(),
            "soil_humidity": responseData['soil_humidity'].toString(),
          };
        });
      } else {
        setState(() {
          data = {
            "temperature": "Error",
            "air_humidity": "Error",
            "soil_humidity": "Error"
          };
        });
      }
    } catch (e) {
      setState(() {
        data = {
          "temperature": "Failed",
          "air_humidity": "Failed",
          "soil_humidity": "Failed"
        };
      });
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
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2,
                      children: [
                        // Temperature Card
                        buildCard(
                          'Temperature',
                          data['temperature'] + '°C',
                          Colors.blue,
                        ),
                        // Air Humidity Card
                        buildCard(
                          'Air Humidity',
                          data['air_humidity'] + '%',
                          Colors.green,
                        ),
                        // Soil Humidity Card
                        buildCard(
                          'Soil Humidity',
                          data['soil_humidity'] + '%',
                          Colors.brown,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Next Watering Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Watering Schedule',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your plant should be watered in 3 days.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // History Section
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'History',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: ListView(
                          children: [
                            ListTile(
                              leading: Icon(Icons.calendar_today),
                              title: Text('18 Dec 2024'),
                              subtitle: Text(
                                  'Temperature: 22°C | Air Humidity: 45% | Soil Humidity: 30%'),
                            ),
                            ListTile(
                              leading: Icon(Icons.calendar_today),
                              title: Text('17 Dec 2024'),
                              subtitle: Text(
                                  'Temperature: 20°C | Air Humidity: 50% | Soil Humidity: 35%'),
                            ),
                            // Add more history entries as needed
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(String title, String value, Color color) {
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
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
