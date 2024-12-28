import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';

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
  String? latestProbSiram;
  String? latestProbTidakSiram;
  bool isLoading = false;
  String startDate = '';
  String endDate = '';

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
    final url = Uri.parse(
        "https://soilapi.hcorp.my.id/api/get_range_average_daily?start_date=$startDate&end_date=$endDate");

    // Reset data dan tampilkan loading
    setState(() {
      averageDailyData = []; // Reset data ke list kosong
      isLoading = true;
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          averageDailyData = data['data'];
          isLoading = false;
        });
      } else {
        print("Failed to fetch data. Status: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk mengonversi data menjadi data untuk LineChart
  List<LineChartBarData> getLineChartData() {
    List<FlSpot> spotsTemperature = [];
    List<FlSpot> spotsHumidity = [];
    List<FlSpot> spotsSoilHumidity = [];

    for (int i = 0; i < averageDailyData.length; i++) {
      final data = averageDailyData[i];
      final temp = double.tryParse(data['avg_temperature'].toString()) ?? 0.0;
      final humidity =
          double.tryParse(data['avg_air_humidity'].toString()) ?? 0.0;
      final soilHumidity =
          double.tryParse(data['avg_soil_humidity'].toString()) ?? 0.0;

      spotsTemperature.add(FlSpot(i.toDouble(), temp));
      spotsHumidity.add(FlSpot(i.toDouble(), humidity));
      spotsSoilHumidity.add(FlSpot(i.toDouble(), soilHumidity));
    }

    return [
      LineChartBarData(
        spots: spotsTemperature,
        isCurved: true,
        color: const Color.fromARGB(255, 234, 255, 0),
        barWidth: 4,
        isStrokeCapRound: false,
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: spotsHumidity,
        isCurved: true,
        color: const Color.fromARGB(255, 150, 181, 248),
        barWidth: 4,
        isStrokeCapRound: false,
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: spotsSoilHumidity,
        isCurved: true,
        color: const Color.fromARGB(255, 6, 131, 27),
        barWidth: 4,
        isStrokeCapRound: false,
        belowBarData: BarAreaData(show: false),
      ),
    ];
  }

  // Menampilkan DatePicker
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null && pickedDate != initialDate) {
      final formattedDate =
          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      setState(() {
        if (isStartDate) {
          startDate = formattedDate;
        } else {
          endDate = formattedDate;
        }
      });
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
          latestProbSiram =
              data['data']['prob_siram'] ?? "No message available";
          latestProbTidakSiram =
              data['data']['prob_tidak_siram'] ?? "No message available";
        });
      } else {
        print("Failed to fetch latest message. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching latest message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final hp = MediaQuery.of(context).size.height;
    final wp = MediaQuery.of(context).size.width;
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
                    Color.fromARGB(255, 41, 133, 238),
                    Color.fromARGB(255, 57, 118, 225)
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Message",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.info,
                                size: wp * 0.06,
                                color:
                                    const Color.fromARGB(255, 255, 255, 255)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      "Probability",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                    content: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: wp * 0.01),
                                      height: hp * 0.08,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                "Tidak Siram",
                                                style: TextStyle(
                                                    fontSize: wp * 0.04),
                                              ),
                                              Text(
                                                "$latestProbSiram",
                                                style: TextStyle(
                                                    fontSize: wp * 0.07,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                "Siram",
                                                style: TextStyle(
                                                    fontSize: wp * 0.04),
                                              ),
                                              Text(
                                                "$latestProbTidakSiram",
                                                style: TextStyle(
                                                    fontSize: wp * 0.07,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Tutup'),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Menutup modal
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Data Section
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Icon
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4A90E2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      latestMessage == "siram"
                                          ? Icons.warning_amber_rounded
                                          : Icons.check_circle,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Text Section
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Status",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          latestMessage.isNotEmpty
                                              ? (latestMessage == "siram"
                                                  ? "Butuh Disiram"
                                                  : "Sudah Disiram")
                                              : "No data",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                  Text(
                    "Average Daily Data",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    height: hp * 0.5,
                    child: Column(
                      children: [
                        // Grafik di atas input tanggal
                        if (averageDailyData.isNotEmpty && !isLoading)
                          Expanded(
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(show: true),
                                borderData: FlBorderData(show: true),
                                lineBarsData: getLineChartData(),
                              ),
                            ),
                          ),
                        if (isLoading) CircularProgressIndicator(),
                        // If no data is available
                        if (!isLoading && averageDailyData.isEmpty)
                          Center(
                            child: Text(
                              "No data available",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: const Color.fromARGB(
                                    255, 255, 255, 255), // Warna teks
                              ),
                            ),
                          ),

                        SizedBox(height: 16),

                        //   averageDailyData.isEmpty
                        // ? Center(child: CircularProgressIndicator())
                        // ?:Column(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildLegendItem(Colors.yellow, "Temperature"),
                            _buildLegendItem(Colors.blue, "Air Humidity"),
                            _buildLegendItem(Colors.green, "Soil Humidity"),
                          ],
                        ),

                        SizedBox(height: 8),
    
                        // Input Start Date
                        GestureDetector(
                          onTap: () => _selectDate(context, true),
                          child: AbsorbPointer(
                            child: TextField(
                              controller:
                                  TextEditingController(text: startDate),
                              decoration: InputDecoration(
                                labelText: 'Start Date (YYYY-MM-DD)',
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Input End Date
                        GestureDetector(
                          onTap: () => _selectDate(context, false),
                          child: AbsorbPointer(
                            child: TextField(
                              controller: TextEditingController(text: endDate),
                              decoration: InputDecoration(
                                labelText: 'End Date (YYYY-MM-DD)',
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Button to fetch data
                        GestureDetector(
                          onTap: fetchAverageDailyData,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(0, 255, 255, 255),
                            ),
                            child: const Text(
                              'Show Graph',
                              style: TextStyle(
                                color: Color.fromARGB(255, 247, 247, 247),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        // Loading Indicator
                      ],
                    ),
                  ),

                  // Data Section
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
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
                fontSize: 20,
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
