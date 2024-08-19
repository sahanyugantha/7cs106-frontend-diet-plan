import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class WaterGlassIndicator extends StatelessWidget {
  final double waterConsumedPercentage;

  WaterGlassIndicator({required this.waterConsumedPercentage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Water Consumption',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Container(
          width: 100.0,
          height: 200.0,
          child: LiquidLinearProgressIndicator(
            value: waterConsumedPercentage, // Set the water consumption percentage here
            valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
            backgroundColor: Colors.blueGrey[200]!,
            borderColor: Colors.black,
            borderWidth: 2.0,
            borderRadius: 12.0,
            direction: Axis.vertical,
            center: Text(
              '${(waterConsumedPercentage * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LegendItem(color: Colors.blueAccent, text: 'Consumed'),
            SizedBox(width: 20),
            LegendItem(color: Colors.blueGrey[200]!, text: 'Remaining'),
          ],
        ),
      ],
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}