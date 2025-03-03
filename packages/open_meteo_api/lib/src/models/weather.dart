import 'package:json_annotation/json_annotation.dart';

part 'weather.g.dart';

@JsonSerializable()
class Weather {
  const Weather({
    required this.temperature,
    required this.weatherCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
    temperature: (json['temperature'] is num)
        ? (json['temperature'] as num).toDouble()
        : (json['temperature'] as Map<String, dynamic>)['value'].toDouble(),
    weatherCode: (json['weathercode'] as num).toDouble(),
  );

  final double temperature;

  @JsonKey(name: 'weathercode')
  final double weatherCode;
}
