import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'plant_details_screen.dart';
import 'saved_plants_screen.dart';

// Initialize Gemini API with your API key
void initializeGemini() {
  Gemini.init(apiKey: 'YOUR_API_KEY'); // Replace with your actual API key
}

void main() {
  initializeGemini(); // Initialize Gemini API
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

class HomeScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const HomeScreen({super.key, required this.onSave});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List to store recent plants
  final List<Map<String, String>> recentPlants = [];

  // Function to show a themed error dialog
  void _showThemedErrorDialog(BuildContext context, String errorMessage) {
    final themeGreen = const Color(0xFF00A86B);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5F9FA),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: themeGreen, size: 24),
            const SizedBox(width: 8),
            Text(
              "Error",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
        content: Text(
          errorMessage,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: themeGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeGreen = const Color(0xFF00A86B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.eco_outlined, color: themeGreen),
            const SizedBox(width: 8),
            Text(
              'PlantPal',
              style: GoogleFonts.poppins(
                color: themeGreen,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.notifications_none, color: Colors.black87),
            const SizedBox(width: 16),
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, Sarah!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Let's identify and care for your plants",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),

            // Upload Card
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade100),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  Icon(Icons.photo_camera_outlined, size: 36, color: themeGreen),
                  const SizedBox(height: 8),
                  Text(
                    'Take a photo or upload\nto identify your plant',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Take Photo Tapped (Not Implemented)')),
                          );
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Take Photo"),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          log("Upload button tapped");

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening gallery...')),
                          );

                          final permissionStatus = await Permission.photos.request();
                          if (!permissionStatus.isGranted) {
                            _showThemedErrorDialog(
                              context,
                              "Please grant gallery access to upload images.",
                            );
                            return;
                          }

                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(source: ImageSource.gallery);

                          if (pickedFile != null) {
                            final file = File(pickedFile.path);

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(child: CircularProgressIndicator()),
                            );

                            try {
                              // Send request to Gemini with a clear, structured prompt
                              final result = await Gemini.instance.textAndImage(
                                text: """
                                Identify this plant and provide the following details in a structured format with each field on a new line:
                                - Plant Name: [name]
                                - Plant Type: [type]
                                - Care Level: [care level]
                                - Temperature: [temperature range]
                                - Humidity: [humidity range]
                                - Light: [light requirement]
                                - Water: [water requirement]
                                - Native Region: [region]
                                - Soil Type: [soil type]
                                Example format:
                                Plant Name: Mango Tree
                                Plant Type: Tropical Tree
                                Care Level: Moderate Care
                                Temperature: 20-35°C
                                Humidity: 50-70%
                                Light: Full Sun
                                Water: Moderate
                                Native Region: South Asia, India
                                Soil Type: Well-drained, loamy soil
                                """,
                                images: [file.readAsBytesSync()],
                              );

                              Navigator.pop(context); // Close loading dialog

                              // Extract and validate the Gemini response
                              final contentParts = result?.content?.parts;
                              if (contentParts != null && contentParts.isNotEmpty) {
                                final lastPart = contentParts.last;
                                if (lastPart is TextPart && lastPart.text != null) {
                                  final responseText = lastPart.text!;
                                  log("Gemini Response: $responseText"); // Log for debugging

                                  // Parse the Gemini response
                                  String plantName = "Unknown Plant";
                                  String plantType = "Unknown Type";
                                  String careLevel = "Unknown Care Level";
                                  String temperature = "Unknown";
                                  String humidity = "Unknown";
                                  String light = "Unknown";
                                  String water = "Unknown";
                                  String nativeRegion = "Unknown";
                                  String soilType = "Unknown";
                                  bool isValidResponse = true;

                                  // Split the response into lines and parse
                                  final lines = responseText.split('\n');
                                  for (var line in lines) {
                                    line = line.trim();
                                    if (line.startsWith('Plant Name:')) {
                                      plantName = line.replaceFirst('Plant Name:', '').trim();
                                    } else if (line.startsWith('Plant Type:')) {
                                      plantType = line.replaceFirst('Plant Type:', '').trim();
                                    } else if (line.startsWith('Care Level:')) {
                                      careLevel = line.replaceFirst('Care Level:', '').trim();
                                    } else if (line.startsWith('Temperature:')) {
                                      temperature = line.replaceFirst('Temperature:', '').trim();
                                    } else if (line.startsWith('Humidity:')) {
                                      humidity = line.replaceFirst('Humidity:', '').trim();
                                    } else if (line.startsWith('Light:')) {
                                      light = line.replaceFirst('Light:', '').trim();
                                    } else if (line.startsWith('Water:')) {
                                      water = line.replaceFirst('Water:', '').trim();
                                    } else if (line.startsWith('Native Region:')) {
                                      nativeRegion = line.replaceFirst('Native Region:', '').trim();
                                    } else if (line.startsWith('Soil Type:')) {
                                      soilType = line.replaceFirst('Soil Type:', '').trim();
                                    }
                                  }

                                  // Validate that key fields are not "Unknown"
                                  if (plantName == "Unknown Plant" || plantType == "Unknown Type") {
                                    isValidResponse = false;
                                  }

                                  if (isValidResponse) {
                                    // Add the identified plant to recent plants list
                                    setState(() {
                                      recentPlants.insert(0, {
                                        'name': plantName,
                                        'imageUrl': pickedFile.path,
                                        'addedTime': 'Just now',
                                      });
                                      // Optionally limit the list to the last 5 plants
                                      if (recentPlants.length > 5) {
                                        recentPlants.removeLast();
                                      }
                                    });

                                    // Navigate to PlantDetailsScreen with the uploaded file and parsed data
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PlantDetailsScreen(
                                          plantName: plantName,
                                          plantType: plantType,
                                          careLevel: careLevel,
                                          temperature: temperature,
                                          humidity: humidity,
                                          light: light,
                                          water: water,
                                          nativeRegion: nativeRegion,
                                          imageFile: file,
                                          onSave: widget.onSave, // Pass the onSave callback
                                        ),
                                      ),
                                    );
                                  } else {
                                    _showThemedErrorDialog(
                                      context,
                                      "Sorry, I couldn't identify the plant. The response format was not as expected.",
                                    );
                                  }
                                } else {
                                  _showThemedErrorDialog(
                                    context,
                                    "Sorry, I couldn't identify the plant. No valid response received.",
                                  );
                                }
                              } else {
                                _showThemedErrorDialog(
                                  context,
                                  "Sorry, I couldn't identify the plant. No response received.",
                                );
                              }
                            } catch (e) {
                              Navigator.pop(context); // Close loading dialog
                              _showThemedErrorDialog(
                                context,
                                "Failed to identify the plant.\n\nError: $e",
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No image selected')),
                            );
                          }
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Upload"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: themeGreen,
                          side: BorderSide(color: themeGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Recent Plants',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            recentPlants.isEmpty
                ? Text(
                    'No recent plants yet. Upload an image to identify a plant!',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                  )
                : SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: recentPlants.map((plant) => _buildPlantCard(plant['name']!, plant['imageUrl']!, plant['addedTime']!)).toList(),
                    ),
                  ),

            const SizedBox(height: 28),

            Text(
              'Care Reminders',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildReminderCard("💧", "Water Monstera", "Today"),
            const SizedBox(height: 12),
            _buildReminderCard("☀️", "Move Snake Plant (Low Light)", "Tomorrow"),
            const SizedBox(height: 12),
            _buildReminderCard("🌿", "Fertilize Fiddle Leaf", "In 3 days"),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantCard(String name, String imageUrl, String addedTime) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 80,
            width: 80,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: FileImage(File(imageUrl)),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Text(
            "Added $addedTime",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(String emoji, String task, String when) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
                const SizedBox(height: 2),
                Text(when, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              log("Tapped more options for reminder: $task");
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F9FA),
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const Center(
        child: Text('Profile Screen (Not Implemented)'),
      ),
    );
  }
}