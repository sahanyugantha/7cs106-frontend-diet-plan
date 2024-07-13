import 'package:flutter/material.dart';

class DietPlanTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text('Your Personalized Diet Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          // Display diet plan here
          // You can replace the following line with dynamic data
          Text('Breakfast: Oatmeal with fruits\nLunch: Grilled chicken salad\nDinner: Steamed vegetables and fish'),
        ],
      ),
    );
  }
}
