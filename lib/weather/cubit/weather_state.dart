part of 'weather_cubit.dart';

enum WeatherStatus { initial, loading, success, failure }

extension WeatherStatusX on WeatherStatus {
  bool get isInitial => this == WeatherStatus.initial;
  bool get isLoading => this == WeatherStatus.loading;
  bool get isSuccess => this == WeatherStatus.success;
  bool get isFailure => this == WeatherStatus.failure;
}

@JsonSerializable()
final class WeatherState extends Equatable {
  WeatherState({
    this.status = WeatherStatus.initial,
    this.temperatureUnits = TemperatureUnits.celsius,
    Weather? weather,
  }) : weather = weather ?? Weather.empty;

  factory WeatherState.fromJson(Map<String, dynamic> json) =>
      _$WeatherStateFromJson(json);

  final WeatherStatus status;

  @JsonKey(fromJson: _weatherFromJson, toJson: _weatherToJson)
  final Weather weather;

  @JsonKey(fromJson: _temperatureUnitsFromJson, toJson: _temperatureUnitsToJson)
  final TemperatureUnits temperatureUnits;

  WeatherState copyWith({
    WeatherStatus? status,
    TemperatureUnits? temperatureUnits,
    Weather? weather,
  }) {
    return WeatherState(
      status: status ?? this.status,
      temperatureUnits: temperatureUnits ?? this.temperatureUnits,
      weather: weather ?? this.weather,
    );
  }

  Map<String, dynamic> toJson() => _$WeatherStateToJson(this);

  @override
  List<Object?> get props => [status, temperatureUnits, weather];
}

// Helper functions for TemperatureUnits serialization
TemperatureUnits _temperatureUnitsFromJson(String json) =>
    TemperatureUnits.values.firstWhere((e) => e.name == json);

String _temperatureUnitsToJson(TemperatureUnits units) => units.name;

// Helper functions for Weather serialization
Weather _weatherFromJson(Map<String, dynamic> json) => Weather.fromJson(json);

Map<String, dynamic> _weatherToJson(Weather weather) => weather.toJson();
