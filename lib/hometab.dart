import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_diet_plan/Config.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis_auth/auth_io.dart';

import 'WaterGlassIndicator.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int? _touchedIndex;
  File? _breakfastImage;
  File? _lunchImage;
  File? _dinnerImage;
  File? _otherImage;

  double breakfastCalories = 0.0;
  double lunchCalories = 0.0;
  double dinnerCalories = 0.0;
  double otherCalories = 0.0;

  double waterConsumed = 0.0;

  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, String mealType) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      setState(() {
        switch (mealType) {
          case 'breakfast':
            _breakfastImage = image;
            break;
          case 'lunch':
            _lunchImage = image;
            break;
          case 'dinner':
            _dinnerImage = image;
            break;
          case 'other':
            _otherImage = image;
            break;
        }
      });
      await _analyzeImage(image, mealType);
    }
  }


  final _scopes = [vision.VisionApi.cloudPlatformScope];

// Function to recognize food items in an image using Google Vision API
  Future<List<String>> _recognizeFoodInImage(File imageFile) async {
    // Google Cloud Vision API key
    final apiKey = 'AIzaSyAC7mav0W3ZZgECB10G52cymi5C-5CBoEo';

    final authClient = await clientViaApiKey(apiKey);
    final visionApi = vision.VisionApi(authClient);

    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final request = vision.AnnotateImageRequest.fromJson({
      'image': {'content': base64Image},
      'features': [
        {'type': 'LABEL_DETECTION', 'maxResults': 10},
      ],
    });

    final response = await visionApi.images.annotate(
      vision.BatchAnnotateImagesRequest(requests: [request]),
    );

    final labels = response.responses?.first.labelAnnotations;

    if (labels != null && labels.isNotEmpty) {
      return labels
          .map((label) => label.description ?? 'Unknown')
          .where((description) => description != 'Unknown')
          .toList();
    } else if (labels == null) {
      print('Error: No label annotations found.');
      return [];
    } else {
      print('Error: No labels detected.');
      return [];
    }
  }


// Function to analyze image, recognize food, and calculate total calories
  Future<void> _analyzeImage(File imageFile, String mealType) async {
    // CalorieNinjas API key
    final apiKey = 'mnRkiZnzVH2GKmaZTT8hFA==0QfebIbWAJuTGIR9';

    // CalorieNinjas API endpoint
    final apiUrl = 'https://api.calorieninjas.com/v1/nutrition?query=';

    try {
      // Recognize food items in the image using Google Vision API
      final recognizedFoods = await _recognizeFoodInImage(imageFile);

      double totalCalories = 0;

      for (String food in recognizedFoods) {
        // Send a request to CalorieNinjas API for each recognized food item
        final response = await http.get(
          Uri.parse('$apiUrl$food'),
          headers: {'X-Api-Key': apiKey},
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          final foodInfo = jsonResponse['items'].isNotEmpty
              ? jsonResponse['items'][0]
              : null;

          if (foodInfo != null && foodInfo['calories'] != null) {
            totalCalories += foodInfo['calories'];
          }
        } else {
          throw Exception('Failed to get nutrition info for $food');
        }
      }

      // Update the state with the total calories
      setState(() {
        switch (mealType) {
          case 'breakfast':
            breakfastCalories = totalCalories;
            break;
          case 'lunch':
            lunchCalories = totalCalories;
            break;
          case 'dinner':
            dinnerCalories = totalCalories;
            break;
          case 'other':
            otherCalories = totalCalories;
            break;
        }
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      imageFile.delete();
    }
  }


  void _showPhotoSourceDialog(String mealType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Photo Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera, mealType);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery, mealType);
                },
              ),
            ],
          ),
        );
      },
    );
  }

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

  double calculateBMI(double weight, double height) {
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String determineBMICategory(double bmi) {
    if (bmi < 18.5) {
      return "Underweight";
    } else if (bmi < 25) {
      return "Normal weight";
    } else if (bmi < 30) {
      return "Overweight";
    } else {
      return "Obesity";
    }
  }


  Future<void> _saveDailyIntake() async {
    final apiUrl = '${Config.baseUrl}/api/v1/daily-consumption/1/meal-calories';

    final requestBody = json.encode({
      'breakfastCalories': breakfastCalories,
      'lunchCalories': lunchCalories,
      'dinnerCalories': dinnerCalories,
      'otherCalories': otherCalories,
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      print('CODE : ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Handle successful response
        print('Daily intake saved successfully: $responseData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Daily intake saved successfully!')),
        );
      } else {
        throw Exception('Code : ${response.statusCode.toString()}. Failed to save daily intake');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save daily intake.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    double totalCalories = breakfastCalories + lunchCalories + dinnerCalories + otherCalories;

    return Scaffold(
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
            final caloriesGoal = data['caloriesGoal'] / 1000;
            final waterGoal = data['waterGoal'];
            final caloriesConsumed = data['caloriesConsumed'] / 1000;
            final caloriesNeeded = data['caloriesLeft'] / 1000;
            waterConsumed = data['waterConsumed']?.toDouble() ?? 0.0;
            final waterLeft = data['waterLeft']?.toDouble() ?? 0.0;
            final weight = data['weight']?.toDouble() ?? 0.0;
            final height = data['height']?.toDouble() ?? 0.0;

            double bmi = calculateBMI(weight, height);
            String bmiCategory = determineBMICategory(bmi);

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Text(
                          '${getGreeting()}, $username!',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),

                        // Food Intake Section
                        Text(
                          'Daily Food Intake',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),

                        // Breakfast Slider
                        _buildCustomSlider(
                          context,
                          label: 'Breakfast',
                          unit: ' kcal',
                          value: breakfastCalories,
                          max: caloriesGoal,
                          gradientColors: [Colors.green, Colors.teal],
                          onChanged: (value) {
                            setState(() {
                              breakfastCalories = value;
                            });
                          },
                        ),
                        ElevatedButton(
                          onPressed: () => _showPhotoSourceDialog('breakfast'),
                          child: Text('Add Breakfast Photo'),
                        ),

                        // Lunch Slider
                        _buildCustomSlider(
                          context,
                          label: 'Lunch',
                          unit: ' kcal',
                          value: lunchCalories,
                          max: caloriesGoal,
                          gradientColors: [Colors.orange, Colors.red],
                          onChanged: (value) {
                            setState(() {
                              lunchCalories = value;
                            });
                          },
                        ),
                        ElevatedButton(
                          onPressed: () => _showPhotoSourceDialog('lunch'),
                          child: Text('Add Lunch Photo'),
                        ),

                        // Dinner Slider
                        _buildCustomSlider(
                          context,
                          label: 'Dinner',
                          unit: ' kcal',
                          value: dinnerCalories,
                          max: caloriesGoal,
                          gradientColors: [Colors.purple, Colors.pink],
                          onChanged: (value) {
                            setState(() {
                              dinnerCalories = value;
                            });
                          },
                        ),
                        ElevatedButton(
                          onPressed: () => _showPhotoSourceDialog('dinner'),
                          child: Text('Add Dinner Photo'),
                        ),

                        // Other Food Intake Slider
                        _buildCustomSlider(
                          context,
                          label: 'Other',
                          unit: ' kcal',
                          value: otherCalories,
                          max: caloriesGoal,
                          gradientColors: [Colors.blue, Colors.indigo],
                          onChanged: (value) {
                            setState(() {
                              otherCalories = value;
                            });
                          },
                        ),
                        ElevatedButton(
                          onPressed: () => _showPhotoSourceDialog('other'),
                          child: Text('Add Other Photo'),
                        ),

                        SizedBox(height: 10),
                        // Save Button
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: _saveDailyIntake,
                              child: Text('Save Daily Intake'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue, // Text color
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Water Intake Section
                        Text(
                          'Daily Water Intake',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),

                        // Water Intake Slider
                        _buildCustomSlider(
                          context,
                          label: 'Water Intake (Liters)',
                          unit: ' L',
                          value: waterConsumed,
                          max: waterGoal,
                          gradientColors: [Colors.lightBlue, Colors.blue],
                          onChanged: (value) {
                            setState(() {
                              waterConsumed = value;
                            });
                          },
                        ),

                        SizedBox(height: 20),

                        // Title for the Pie Chart
                        Text(
                          'Calorie Distribution',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),

                        // Calorie Goal and Remaining Calories
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Calorie Goal: ${caloriesGoal.toStringAsFixed(1)} kcal',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Total Calories Consumed: ${(breakfastCalories + lunchCalories + dinnerCalories + otherCalories).toStringAsFixed(1)} kcal',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Calories Remaining: ${(caloriesGoal - (breakfastCalories + lunchCalories + dinnerCalories + otherCalories)).toStringAsFixed(1)} kcal',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: (caloriesGoal - (breakfastCalories + lunchCalories + dinnerCalories + otherCalories)) < 0
                                      ? Colors.red
                                      : Colors.green,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (caloriesGoal - (breakfastCalories + lunchCalories + dinnerCalories + otherCalories) < 0)
                                Text(
                                  'You have exceeded your calorie goal by ${((breakfastCalories + lunchCalories + dinnerCalories + otherCalories) - caloriesGoal).toStringAsFixed(1)} kcal',
                                  style: TextStyle(fontSize: 16, color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),


                        // Pie Chart
                        Container(
                          height: 300,
                          child: Card(
                            elevation: 5,
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: breakfastCalories,
                                    color: Colors.green,
                                    title: '${_calculatePercentage(breakfastCalories, totalCalories)}%',
                                    titleStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: lunchCalories,
                                    color: Colors.orange,
                                    title: '${_calculatePercentage(lunchCalories, totalCalories)}%',
                                    titleStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: dinnerCalories,
                                    color: Colors.purple,
                                    title: '${_calculatePercentage(dinnerCalories, totalCalories)}%',
                                    titleStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: otherCalories,
                                    color: Colors.blue,
                                    title: '${_calculatePercentage(otherCalories, totalCalories)}%',
                                    titleStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 0,
                                centerSpaceRadius: 80,
                                startDegreeOffset: 270,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Legend Below Pie Chart
                        _buildLegend(
                          label: 'Breakfast',
                          color: Colors.green,
                          value: breakfastCalories,
                        ),
                        _buildLegend(
                          label: 'Lunch',
                          color: Colors.orange,
                          value: lunchCalories,
                        ),
                        _buildLegend(
                          label: 'Dinner',
                          color: Colors.purple,
                          value: dinnerCalories,
                        ),
                        _buildLegend(
                          label: 'Other',
                          color: Colors.blue,
                          value: otherCalories,
                        ),


                        SizedBox(height: 20),

                        WaterGlassIndicator(waterConsumedPercentage: waterConsumed / (waterConsumed + waterLeft)),

                        SizedBox(height: 20),
                        // BMI Gauge
                        Text(
                          'BMI: ${bmi.toStringAsFixed(1)} ($bmiCategory)',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 200,
                          child: SfRadialGauge(
                            axes: <RadialAxis>[
                              RadialAxis(
                                minimum: 0,
                                maximum: 40,
                                pointers: <GaugePointer>[
                                  NeedlePointer(
                                    value: bmi,
                                    enableAnimation: true,
                                    animationType: AnimationType.ease,
                                    needleColor: Colors.blue,
                                  ),
                                ],
                                ranges: <GaugeRange>[
                                  GaugeRange(
                                    startValue: 0,
                                    endValue: 18.5,
                                    color: Colors.blue.withOpacity(0.5),
                                    startWidth: 10,
                                    endWidth: 10,
                                  ),
                                  GaugeRange(
                                    startValue: 18.5,
                                    endValue: 25,
                                    color: Colors.green.withOpacity(0.5),
                                    startWidth: 10,
                                    endWidth: 10,
                                  ),
                                  GaugeRange(
                                    startValue: 25,
                                    endValue: 30,
                                    color: Colors.yellow.withOpacity(0.5),
                                    startWidth: 10,
                                    endWidth: 10,
                                  ),
                                  GaugeRange(
                                    startValue: 30,
                                    endValue: 40,
                                    color: Colors.red.withOpacity(0.5),
                                    startWidth: 10,
                                    endWidth: 10,
                                  ),
                                ],
                                axisLabelStyle: GaugeTextStyle(fontSize: 12),
                                annotations: <GaugeAnnotation>[
                                  GaugeAnnotation(
                                    widget: Container(
                                      child: Text(
                                        '${bmi.toStringAsFixed(1)}',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    angle: 90,
                                    positionFactor: 0.5,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Recommendations Section
                        Text(
                          'Recommendations',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '1. Maintain a balanced diet and avoid excessive intake of calories.',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '2. Regular exercise is essential for maintaining a healthy BMI.',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '3. Drink at least 2 liters of water daily to stay hydrated.',
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


  Widget _buildCustomSlider(
      BuildContext context, {
        required String label,
        required String unit,
        required double value,
        required double max,
        required List<Color> gradientColors,
        required ValueChanged<double> onChanged,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        FlutterSlider(
          values: [value],
          max: max,
          min: 0,
          onDragCompleted: (handlerIndex, lowerValue, upperValue) {
            onChanged(lowerValue);
          },
          trackBar: FlutterSliderTrackBar(
            activeTrackBarHeight: 8,
            inactiveTrackBarHeight: 8,
            activeTrackBar: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            inactiveTrackBar: BoxDecoration(
              color: Colors.grey[300],
            ),
          ),
          handler: FlutterSliderHandler(
            child: Icon(Icons.adjust),
          ),
          tooltip: FlutterSliderTooltip(
            alwaysShowTooltip: true,
            rightSuffix: Text(unit, style: TextStyle(fontSize: 12, color: Colors.black)),
            textStyle: TextStyle(fontSize: 12, color: Colors.black),
            boxStyle: FlutterSliderTooltipBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          //values: [intValue],

        ),
      ],
    );
  }

  String _calculatePercentage(double value, double total) {
    return (value / total * 100).toStringAsFixed(1);
  }

  Widget _buildLegend({required String label, required Color color, required double value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            height: 20,
            width: 20,
            color: color,
          ),
          SizedBox(width: 10),
          Text(
            '$label: ${value.toStringAsFixed(1)} kcal',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
