import 'package:flutter/material.dart';

class DietPlanTab extends StatefulWidget {
  @override
  _DietPlanTabState createState() => _DietPlanTabState();
}

class _DietPlanTabState extends State<DietPlanTab> {
  final _formKey = GlobalKey<FormState>();

  double breakfastCalories = 0;
  double lunchCalories = 0;
  double dinnerCalories = 0;
  double otherCalories = 0;
  double waterGoal = 0;

  double get bmrSuggestion {
    // Placeholder calculation for BMR suggestion
    return (breakfastCalories + lunchCalories + dinnerCalories + otherCalories) * 1.2;
  }

  double get totalCalories {
    return breakfastCalories + lunchCalories + dinnerCalories + otherCalories;
  }

  void _saveDietPlan() {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Diet plan saved successfully!'),
      ),
    );
  }

  void _showBmrInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('What is BMR?'),
          content: Text(
            'BMR (Basal Metabolic Rate) is the number of calories your body needs to maintain basic physiological functions at rest. It represents the minimum amount of energy required to keep your body functioning, including breathing, circulation, and cell production.',
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Your Personalized Diet Plan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Calorie Goals Section
            _buildCalorieGoalsSection(),

            SizedBox(height: 20),

            // BMR Suggestion
            _buildBmrSuggestion(),

            SizedBox(height: 20),

            // Total Calories Section
            _buildTotalCaloriesSection(),

            SizedBox(height: 20),

            // Water Goal Section
            _buildWaterGoalSection(),

            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: ElevatedButton(
                  onPressed: _saveDietPlan,
                  child: Text('Save Diet Plan'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            _buildScoreText(2700),

            SizedBox(height: 20),
            // Summary
            _buildSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieGoalsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Your Calorie Goals',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
          ),
          SizedBox(height: 10),
          _buildCalorieInputField('Breakfast', breakfastCalories, (value) {
            setState(() {
              breakfastCalories = value;
            });
          }),
          _buildCalorieInputField('Lunch', lunchCalories, (value) {
            setState(() {
              lunchCalories = value;
            });
          }),
          _buildCalorieInputField('Dinner', dinnerCalories, (value) {
            setState(() {
              dinnerCalories = value;
            });
          }),
          _buildCalorieInputField('Other', otherCalories, (value) {
            setState(() {
              otherCalories = value;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildCalorieInputField(String label, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        initialValue: value.toString(),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: '$label Calories',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (text) {
          final newValue = double.tryParse(text) ?? 0;
          onChanged(newValue);
        },
      ),
    );
  }

  Widget _buildBmrSuggestion() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'BMR Suggestion',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline, color: Colors.blueGrey[600]),
                onPressed: _showBmrInfoDialog,
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Suggested BMR: ${bmrSuggestion.toStringAsFixed(1)} kcal',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey[600],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTotalCaloriesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Calories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
          ),
          SizedBox(height: 10),
          Text(
            'Total Calories Set: ${totalCalories.toStringAsFixed(1)} kcal',
            style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterGoalSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Your Water Goal',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
          ),
          SizedBox(height: 10),
          TextFormField(
            initialValue: waterGoal.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Water Goal (liters)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (text) {
              final newValue = double.tryParse(text) ?? 0;
              setState(() {
                waterGoal = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScoreText(caloriesGoal) {
    double totalCaloriesConsumed = breakfastCalories + lunchCalories + dinnerCalories + otherCalories;
    double score = totalCaloriesConsumed / caloriesGoal * 100;

    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center, // Center the text
      child: Text(
        'Score: ${score.toStringAsFixed(1)}%',
        style: TextStyle(
          fontSize: 28, // Larger font size
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey[800],
        ),
      ),
    );
  }




  Widget _buildSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
          ),
          SizedBox(height: 10),
          Text(
            'Total Calories Goal: ${totalCalories.toStringAsFixed(1)} kcal',
            style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
          ),
          Text(
            'Water Goal: ${waterGoal.toStringAsFixed(1)} liters',
            style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
          ),
        ],
      ),
    );
  }
}
