import 'package:flutter/material.dart';
import 'package:soil_ai_dashboard/CardData.dart';

class SoilMonitoringDashboard extends StatefulWidget {
  const SoilMonitoringDashboard({super.key});

  @override
  _SoilMonitoringDashboardState createState() =>
      _SoilMonitoringDashboardState();
}

class _SoilMonitoringDashboardState extends State<SoilMonitoringDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SOIL.AI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.blue[500],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const CustomCardApp(), // Panggil widget CustomCardApp di sini
          ],
        ),
      ),
    );
  }
}
