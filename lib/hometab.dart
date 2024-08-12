import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_diet_plan/Config.dart';

import 'WaterGlassIndicator.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int? _touchedIndex;

  Future<Map<String, dynamic>> fetchRecommendations() async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/api/v1/users/1/recommendations'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load recommendations');
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Home'),
      //   backgroundColor: Colors.blueAccent,
      // ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchRecommendations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!;
            final username = data['username'];
            final caloriesConsumed = data['caloriesConsumed'] / 1000;
            final caloriesNeeded = data['caloriesLeft'] / 1000;
            final waterConsumed = data['waterConsumed'];
            final waterLeft = data['waterLeft'];
            //final waterConsumedPercentage = waterConsumed / (waterConsumed + waterLeft);

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Greeting
                Text(
                  '${getGreeting()}, $username!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Title for the Pie Chart
                Text(
                  'Daily Caloric Breakdown',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),

                // Pie Chart for Calories
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: caloriesConsumed.toDouble(),
                                title: '${caloriesConsumed.toStringAsFixed(2)} kcal',
                                radius: 80,
                                titleStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                gradient: LinearGradient(
                                  colors: [Colors.blue, Colors.cyan],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              PieChartSectionData(
                                value: caloriesNeeded.toDouble(),
                                title: '${caloriesNeeded.toStringAsFixed(2)} kcal',
                                radius: 80,
                                titleStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                gradient: LinearGradient(
                                  colors: [Colors.red, Colors.orange],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ],
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 0,
                            centerSpaceRadius: 60,
                            startDegreeOffset: 270,
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                if (pieTouchResponse != null && pieTouchResponse.touchedSection != null) {
                                  setState(() {
                                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                  });
                                } else {
                                  setState(() {
                                    _touchedIndex = -1;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        if (_touchedIndex != null && _touchedIndex != -1)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: AnimatedOpacity(
                                opacity: 1.0,
                                duration: Duration(milliseconds: 200),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _touchedIndex == 0
                                        ? '${caloriesConsumed.toStringAsFixed(2)} kcal'
                                        : '${caloriesNeeded.toStringAsFixed(2)} kcal',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Legend for the Pie Chart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 5),
                        Text('Calories Consumed'),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          color: Colors.red,
                        ),
                        SizedBox(width: 5),
                        Text('Remaining Calories'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),

                WaterGlassIndicator(waterConsumedPercentage: waterConsumed / (waterConsumed + waterLeft)),
                //WaterGlassIndicator(waterConsumedPercentage: 0.52),

                SizedBox(height: 10),
                // Detailed Statistics
                Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Calories Consumed:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${caloriesConsumed.toStringAsFixed(2)} kcal', style: TextStyle(fontSize: 24)),
                        SizedBox(height: 10),
                        Text('Remaining Calories:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${caloriesNeeded.toStringAsFixed(2)} kcal', style: TextStyle(fontSize: 24)),
                        SizedBox(height: 10),
                        Text('Water Consumed:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${waterConsumed} liters', style: TextStyle(fontSize: 24)),
                        SizedBox(height: 10),
                        Text('Water Left:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${waterLeft} liters', style: TextStyle(fontSize: 24)),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Recommendations
                Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Today\'s Recommendations:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text(
                          'Eat more vegetables, drink 8 glasses of water, and walk for 30 minutes.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
