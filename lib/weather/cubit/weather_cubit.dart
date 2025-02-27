import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart' show WeatherRepository;

import '../models/weather.dart';

part 'weather_cubit.g.dart';
part 'weather_state.dart';

class WeatherCubit extends HydratedCubit<WeatherState> {
  WeatherCubit(this._weatherRepository) : super(WeatherState());

  final WeatherRepository _weatherRepository;

  /// Fetch weather data for a given city
  Future<void> fetchWeather(String? city) async {
    if (city == null || city.isEmpty) return;

    emit(state.copyWith(status: WeatherStatus.loading));

    try {
      final weather = Weather.fromRepository(
        await _weatherRepository.getWeather(city),
      );
      final value = state.temperatureUnits.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      emit(state.copyWith(
        status: WeatherStatus.success,
        weather: weather.copyWith(temperature: Temperature(value: value)),
      ));
    } on Exception {
      emit(state.copyWith(status: WeatherStatus.failure));
    }
  }

  /// Refresh weather data if already loaded
  Future<void> refreshWeather() async {
    if (!state.status.isSuccess || state.weather == Weather.empty) return;

    try {
      final weather = Weather.fromRepository(
        await _weatherRepository.getWeather(state.weather.location),
      );
      final value = state.temperatureUnits.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      emit(state.copyWith(
        status: WeatherStatus.success,
        weather: weather.copyWith(temperature: Temperature(value: value)),
      ));
    } on Exception {
      emit(state); // Retains previous state if refresh fails
    }
  }

  /// Toggle temperature units (Celsius ↔ Fahrenheit)
  void toggleUnits() {
    final newUnits = state.temperatureUnits.isFahrenheit
        ? TemperatureUnits.celsius
        : TemperatureUnits.fahrenheit;

    if (!state.status.isSuccess) {
      emit(state.copyWith(temperatureUnits: newUnits));
      return;
    }

    final value = newUnits.isCelsius
        ? state.weather.temperature.value.toCelsius()
        : state.weather.temperature.value.toFahrenheit();

    emit(state.copyWith(
      temperatureUnits: newUnits,
      weather: state.weather.copyWith(temperature: Temperature(value: value)),
    ));
  }

  /// Persist state using HydratedBloc
  @override
  WeatherState fromJson(Map<String, dynamic> json) => WeatherState.fromJson(json);

  @override
  Map<String, dynamic> toJson(WeatherState state) => state.toJson();
}

/// Extension for Temperature Conversion
extension TemperatureConversion on double {
  double toFahrenheit() => (this * 9 / 5) + 32;
  double toCelsius() => (this - 32) * 5 / 9;
}
