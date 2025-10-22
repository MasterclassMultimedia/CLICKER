import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'services/aws_service.dart';
import 'models/clicker_data.dart';

void main() {
  runApp(const ColorClickerApp());
}

class ColorClickerApp extends StatelessWidget {
  const ColorClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Clicker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ClickerScreen(),
    );
  }
}

class ClickerScreen extends StatefulWidget {
  const ClickerScreen({super.key});

  @override
  State<ClickerScreen> createState() => _ClickerScreenState();
}

class _ClickerScreenState extends State<ClickerScreen> {
  int _counter = 0;
  Color _backgroundColor = Colors.blue;
  final Random _random = Random();
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  
  // AWS and sync related
  final Uuid _uuid = const Uuid();
  String _deviceId = '';
  bool _isSyncing = false;
  bool _awsAvailable = false;
  String _syncStatus = 'Ready';

  // List of vibrant colors for background changes
  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  void _incrementCounter() {
    setState(() {
      _counter++;
      // Change background color to a random color from the list
      _backgroundColor = _colors[_random.nextInt(_colors.length)];
    });
    // Auto-save to AWS after each increment
    _saveToAWS();
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
      _backgroundColor = Colors.blue;
    });
    // Save reset to AWS
    _saveToAWS();
  }

  // Helper methods for AWS integration
  Future<void> _saveToAWS() async {
    if (!_awsAvailable) return;
    
    final data = ClickerData(
      id: _deviceId,
      counter: _counter,
      backgroundColor: _colorToString(_backgroundColor),
      lastUpdated: DateTime.now(),
      deviceId: _deviceId,
    );
    
    await AWSService.saveToAWS(data);
  }

  Future<void> _syncWithAWS() async {
    if (!_awsAvailable) {
      setState(() {
        _syncStatus = 'AWS not available';
      });
      return;
    }

    setState(() {
      _isSyncing = true;
      _syncStatus = 'Syncing...';
    });

    try {
      final currentData = ClickerData(
        id: _deviceId,
        counter: _counter,
        backgroundColor: _colorToString(_backgroundColor),
        lastUpdated: DateTime.now(),
        deviceId: _deviceId,
      );

      final syncedData = await AWSService.syncData(currentData);
      
      setState(() {
        _counter = syncedData.counter;
        _backgroundColor = _parseColor(syncedData.backgroundColor);
        _syncStatus = 'Synced successfully';
      });
    } catch (e) {
      setState(() {
        _syncStatus = 'Sync failed: $e';
      });
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  String _colorToString(Color color) {
    return color.value.toRadixString(16);
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  void initState() {
    super.initState();
    _deviceId = _uuid.v4();
    _initializeApp();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  Future<void> _initializeApp() async {
    // Check AWS availability
    _awsAvailable = await AWSService.isAWSAvailable();
    
    // Try to load existing data
    final existingData = await AWSService.loadFromAWS(_deviceId);
    if (existingData != null) {
      setState(() {
        _counter = existingData.counter;
        _backgroundColor = _parseColor(existingData.backgroundColor);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: _incrementCounter,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clock at the top
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                  ),
                  child: Text(
                    '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}:${_currentTime.second.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'monospace',
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Color Clicker',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '$_counter',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Tap anywhere to count!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // AWS Sync Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _awsAvailable ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _awsAvailable ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _awsAvailable ? 'AWS Connected' : 'AWS Offline',
                    style: TextStyle(
                      color: _awsAvailable ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Sync Status
                Text(
                  _syncStatus,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _resetCounter,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isSyncing ? null : _syncWithAWS,
                      icon: _isSyncing 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_sync),
                      label: Text(_isSyncing ? 'Syncing...' : 'Sync'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _awsAvailable 
                          ? Colors.blue.withOpacity(0.9)
                          : Colors.grey.withOpacity(0.9),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
