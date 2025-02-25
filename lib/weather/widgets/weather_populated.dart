import 'package:flutter/material.dart';
import 'package:weather_repository/weather_repository.dart' as repo; // Use prefix to avoid conflicts
import 'package:weather_repository/weather_repository.dart';
import '../models/weather.dart'; // Ensure this is correct

class WeatherPopulated extends StatelessWidget {
  const WeatherPopulated({
    required this.weather,
    required this.units,
    required this.onRefresh,
    super.key,
  });

  final repo.Weather weather; // Using the prefixed Weather class
  final TemperatureUnits units;
  final ValueGetter<Future<void>> onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        const _WeatherBackground(),
        RefreshIndicator(
          onRefresh: onRefresh,
          child: Align(
            alignment: const Alignment(0, -1 / 3),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              clipBehavior: Clip.none,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 48),
                  _WeatherIcon(condition: weather.condition),
                  Text(
                    weather.location,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  Text(
                    weather.formattedTemperature(units),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Text(
                  //   // Fixing 'lastUpdated' issue
                  //   '''Last Updated at ${TimeOfDay.fromDateTime(weather.dateTime).format(context)}''',
                  // ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon({required this.condition});

  static const _iconSize = 75.0;

  final WeatherCondition condition;

  @override
  Widget build(BuildContext context) {
    return Text(
      condition.toEmoji,
      style: const TextStyle(fontSize: _iconSize),
    );
  }
}

extension on WeatherCondition {
  String get toEmoji {
    switch (this) {
      case WeatherCondition.clear:
        return '☀️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.cloudy:
        return '☁️';
      case WeatherCondition.snowy:
        return '🌨️';
      case WeatherCondition.unknown:
        return '❓';
    }
  }
}

class _WeatherBackground extends StatelessWidget {
  const _WeatherBackground();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primaryContainer;
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.25, 0.75, 0.90, 1.0],
            colors: [
              // color,
              // color.brighten(),
              // color.brighten(33),
              // color.brighten(50),
            ],
          ),
        ),
      ),
    );
  }
}

// Adding the missing brighten() method
/*
extension ColorBrightness on Color {
  Color brighten([int percent = 10]) {
    assert(
    1 <= percent && percent <= 100,
    'Percentage must be between 1 and 100',
    );
    final p = percent / 100;
    return Color.fromARGB(
      a,
      (r + ((255 - r) * p)).round(),
      (g + ((255 - g) * p)).round(),
      (b + ((255 - b) * p)).round(),
    );
  }
}
*/

// Ensure we use the correct Weather class
extension WeatherFormatting on repo.Weather {
  String formattedTemperature(TemperatureUnits units) {
    // Fixing 'value' issue
    return '${temperature.toStringAsPrecision(2)}°${units.isCelsius ? 'C' : 'F'}';
  }
}

