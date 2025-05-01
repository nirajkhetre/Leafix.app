import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'Screens/home_screen.dart'; // Ensure this path is correct
import 'Screens/saved_plants_screen.dart'; // Add this import

void main() {
  Gemini.init(apiKey: 'AIzaSyCFF4J-wwlcpyrYcxQTv6YfCG_nkFAZpc0', enableDebugging: true); // Update with your actual API key
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _savedPlants = [];

  void _onSavePlant(Map<String, dynamic> plant) {
    setState(() {
      _savedPlants.add(plant);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(onSave: _onSavePlant),
      SavedPlantsScreen(savedPlants: _savedPlants),
      const ProfileScreen(),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Leafix',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: Scaffold(
        body: screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF00A86B),
          unselectedItemColor: Colors.grey[500],
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Saved Plants"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Profile Screen (Not Implemented)')),
    );
  }
}