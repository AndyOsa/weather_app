import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

// SPLASH SCREEN
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WeatherScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'K',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    TextSpan(
                      text: 'evych Solutions',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Weather App',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// WEATHER SCREEN
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _current;
  List<dynamic> _forecast = [];
  bool _loading = true;
  String _city = '';

  @override
  void initState() {
    super.initState();
    _loadByLocation();
  }

  Future<void> _loadByLocation() async {
    setState(() => _loading = true);
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      Position pos = await Geolocator.getCurrentPosition();
      await _fetchWeather('${pos.latitude},${pos.longitude}');
    } catch (e) {
      await _fetchWeather('Kyiv');
    }
  }

  Future<void> _fetchWeather(String query) async {
    setState(() => _loading = true);
    try {
      final currentRes = await http.get(
        Uri.parse('https://wttr.in/$query?format=j1'),
      );
      final data = json.decode(currentRes.body);
      setState(() {
        _current = data;
        _forecast = data['weather'];
        _city = data['nearest_area'][0]['areaName'][0]['value'];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  IconData _getWeatherIcon(String desc) {
    desc = desc.toLowerCase();
    if (desc.contains('sun') || desc.contains('clear')) return Icons.wb_sunny;
    if (desc.contains('cloud')) return Icons.cloud;
    if (desc.contains('rain')) return Icons.grain;
    if (desc.contains('snow')) return Icons.ac_unit;
    if (desc.contains('thunder')) return Icons.flash_on;
    if (desc.contains('fog') || desc.contains('mist')) return Icons.foggy;
    return Icons.wb_sunny;
  }

  String _getDayName(String dateStr) {
    final date = DateTime.parse(dateStr);
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final current = _current?['current_condition']?[0];
    final desc = current?['weatherDesc']?[0]?['value'] ?? '';
    final temp = current?['temp_C'] ?? '--';
    final humidity = current?['humidity'] ?? '--';
    final maxTemp = _forecast.isNotEmpty ? _forecast[0]['maxtempC'] : '--';
    final minTemp = _forecast.isNotEmpty ? _forecast[0]['mintempC'] : '--';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Input City',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          _fetchWeather(_controller.text);
                        }
                      },
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.isNotEmpty) _fetchWeather(val);
                  },
                ),
              ),

              if (_loading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else ...[
                // City name
                Text(
                  _city,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Weather icon
                Icon(
                  _getWeatherIcon(desc),
                  size: 80,
                  color: Colors.orange,
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 8),
                // Temperature
                Text(
                  '$temp°C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Max/Min/Humidity
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('↑$maxTemp°C',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16)),
                    const SizedBox(width: 16),
                    Text('↓$minTemp°C',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16)),
                    const SizedBox(width: 16),
                    Text('💧$humidity%',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 24),

                // Forecast list
                Expanded(
                  child: ListView.builder(
                    itemCount: _forecast.length,
                    itemBuilder: (context, index) {
                      final day = _forecast[index];
                      final dayDesc =
                          day['hourly'][4]['weatherDesc'][0]['value'];
                      final dayMax = day['maxtempC'];
                      final dayMin = day['mintempC'];
                      final dayHumidity = day['hourly'][4]['humidity'];
                      final dayName = _getDayName(day['date']);

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(dayName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            Icon(_getWeatherIcon(dayDesc),
                                color: Colors.orange, size: 28),
                            Text('↑$dayMax° ↓$dayMin°',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            Text('💧$dayHumidity%',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}