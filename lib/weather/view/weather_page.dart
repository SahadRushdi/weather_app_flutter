import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app_flutter/weather/models/weather.dart';

import '../../search/view/search_page.dart';
import '../../settings/view/settings_page.dart';
import '../cubit/weather_cubit.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push<void>(
              SettingsPage.route(),
            ),
          ),
        ],
      ),
      body: Center(
        child: BlocBuilder<WeatherCubit, WeatherState>(
          builder: (context, state) {
            return switch (state.status) {
              WeatherStatus.initial => const Center(child: Text('Please select a city')),
              WeatherStatus.loading => const Center(child: CircularProgressIndicator()),
              WeatherStatus.failure => const Center(child: Text('Something went wrong!')),
              WeatherStatus.success => WeatherPopulated(
                weather: state.weather,
                units: state.temperatureUnits,
                onRefresh: () {
                  return context.read<WeatherCubit>().refreshWeather();
                },
              ),
            };
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search, semanticLabel: 'Search'),
        onPressed: () async {
          final city = await Navigator.of(context).push(SearchPage.route());
          if (!context.mounted) return;
          await context.read<WeatherCubit>().fetchWeather(city);
        },
      ),
    );
  }
}

// WeatherPopulated widget to display the weather when successfully fetched
class WeatherPopulated extends StatelessWidget {
  final Weather weather;
  final TemperatureUnits units;
  final Future<void> Function() onRefresh;

  const WeatherPopulated({
    super.key,
    required this.weather,
    required this.units,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weather.location,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${_formattedTemperature(weather.temperature as double, units)}°',
                style: const TextStyle(
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                weather.condition as String,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              // Add more weather information as needed
            ],
          ),
        ),
      ),
    );
  }

  String _formattedTemperature(double temperature, TemperatureUnits units) {
    return switch (units) {
      TemperatureUnits.celsius => temperature.toStringAsFixed(0),
      TemperatureUnits.fahrenheit => ((temperature * 9 / 5) + 32).toStringAsFixed(0),
    };
  }
}