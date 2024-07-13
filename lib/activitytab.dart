import 'package:flutter/material.dart';

class ActivityTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Track your activities'),
            // Display activity data here
            // You can replace the following line with dynamic data
            Text('Steps: 5000\nCalories burned: 200\nWorkouts: 2'),
          ],
        ),
      ),
    );
  }
}
