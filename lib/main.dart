import 'package:flutter/material.dart';
import 'package:my_diet_plan/profiletab.dart';
import 'package:my_diet_plan/activitytab.dart';
import 'package:my_diet_plan/dietplantab.dart';
import 'package:my_diet_plan/hometab.dart';
import 'package:my_diet_plan/custom_drawer.dart'; // Import the custom drawer

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personalized Diet Planner'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.home), text: 'Home'),
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Diet Plan'),
            Tab(icon: Icon(Icons.fitness_center), text: 'Activity'),
          ],
        ),
      ),
      drawer: CustomDrawer(), // Add the custom drawer here
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeTab(),
          ProfileTab(),
          DietPlanTab(),
          ActivityTab(),
        ],
      ),
    );
  }
}
