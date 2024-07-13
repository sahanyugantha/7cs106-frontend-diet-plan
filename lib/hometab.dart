import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome back, [User Name]!'),
            SizedBox(height: 20),
            Column(
              children: [
                Text('Today\'s Recommendations:'),
              ],
            ),
            // Display recommendations here
            Text('Eat more vegetables, drink 8 glasses of water, and walk for 30 minutes.'),
          ],
        ),
      ),
    );
  }
}