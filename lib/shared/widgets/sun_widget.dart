// weather_state.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_animation/weather_animation.dart';

class WeatherState extends ChangeNotifier {
  WeatherState() {
    _startTimer();
  }

  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (final Timer timer) {
      _currentTime = DateTime.now();
      notifyListeners();
    });
  }

  List<Color> get timeBasedColors {
    final int hour = _currentTime.hour;

    // Early morning (4-6 AM)
    if (hour >= 4 && hour < 6) {
      return <Color>[
        const Color(0xFF1A237E), // Deep blue
        const Color(0xFFFF7043), // Light orange
      ];
    }
    // Morning (6-11 AM)
    else if (hour >= 6 && hour < 11) {
      return <Color>[
        const Color(0xFF283593), // Indigo
        const Color(0xFFFF8A65), // Coral
      ];
    }
    // Noon (11 AM-3 PM)
    else if (hour >= 11 && hour < 15) {
      return <Color>[
        const Color(0xFF1E88E5), // Blue
        const Color(0xFFFFB74D), // Orange
      ];
    }
    // Afternoon (3-6 PM)
    else if (hour >= 15 && hour < 18) {
      return <Color>[
        const Color(0xFF0277BD), // Light blue
        const Color(0xFFFFB74D), // Orange
      ];
    }
    // Evening (6-8 PM)
    else if (hour >= 18 && hour < 20) {
      return <Color>[
        const Color(0xFF0D47A1), // Dark blue
        const Color(0xFFFF7043), // Deep orange
      ];
    }
    // Night (8 PM-4 AM)
    else {
      return <Color>[
        const Color(0xFF1A237E), // Midnight blue
        const Color(0xFF424242), // Dark grey
      ];
    }
  }

  SunConfig get timeBasedSunConfig {
    final int hour = _currentTime.hour;

    // Adjust sun properties based on time
    double width = 262;
    double blurSigma = 10;

    // Night time - smaller, dimmer sun
    if (hour < 6 || hour >= 19) {
      width = 200;
      blurSigma = 15;
    }
    // Mid-day - larger, brighter sun
    else if (hour >= 10 && hour <= 14) {
      width = 300;
      blurSigma = 8;
    }

    return SunConfig(
      width: width,
      blurSigma: blurSigma,
      coreColor: const Color.fromRGBO(255, 167, 38, 1),
      midColor: const Color.fromRGBO(255, 238, 88, 0.84),
      outColor: const Color.fromRGBO(255, 152, 0, 1),
      animMidMill: 2000,
      animOutMill: 2000,
    );
  }

  CloudConfig get timeBasedCloudConfig {
    final int hour = _currentTime.hour;

    // Adjust cloud opacity based on time
    double opacity = 0.4;
    if (hour < 6 || hour >= 19) {
      opacity = 0.6; // More visible at night
    } else if (hour >= 10 && hour <= 14) {
      opacity = 0.3; // Less visible during bright daylight
    }

    return CloudConfig(
      size: 172,
      color: Color.fromRGBO(33, 33, 33, opacity),
      x: 20,
      y: 35,
      scaleEnd: 1.08,
      slideX: 20,
      slideY: 0,
      slideDurMill: 3000,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// dynamic_weather_scene.dart
class DynamicWeatherScene extends StatelessWidget {
  const DynamicWeatherScene({super.key});

  @override
  Widget build(final BuildContext context) =>
      ChangeNotifierProvider<WeatherState>(
        create: (final _) => WeatherState(),
        child: Consumer<WeatherState>(
          builder: (
            final BuildContext context,
            final WeatherState weatherState,
            final _,
          ) =>
              WrapperScene(
            sizeCanvas: const Size(442, 219),
            isLeftCornerGradient: true,
            colors: weatherState.timeBasedColors,
            children: <Widget>[
              SunWidget(sunConfig: weatherState.timeBasedSunConfig),
              const WindWidget(
                windConfig: WindConfig(
                  width: 5,
                  y: 208,
                  windGap: 10,
                  blurSigma: 6,
                  slideXEnd: 350,
                ),
              ),
              CloudWidget(cloudConfig: weatherState.timeBasedCloudConfig),
              // Add more widgets as needed
            ],
          ),
        ),
      );
}
