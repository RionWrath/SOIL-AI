import 'package:flutter/material.dart';
import 'package:soil_ai_dashboard/SoilMonitoringDashboard.dart';

void main() => runApp(const SoilMonitoringApp());

class SoilMonitoringApp extends StatelessWidget {
  const SoilMonitoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SoilMonitoringDashboard(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.blue[100],
      ),
    );
    
  }
}
