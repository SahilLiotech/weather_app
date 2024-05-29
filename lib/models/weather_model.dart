import 'package:weather_app/models/temeprature_model.dart';

class WeatherModel {
  final int? id;
  final DateTime date;
  final String? weatherDescription;
  final String? weatherIcon;
  final String areaName;
  final MyTemperature temperature;
  final MyTemperature tempMin;
  final MyTemperature tempMax;
  final double windSpeed;
  final int humidity;

  WeatherModel({
    this.id,
    required this.date,
    required this.areaName,
    this.weatherDescription,
    this.weatherIcon,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.windSpeed,
    required this.humidity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'areaName': areaName,
      'weatherDescription': weatherDescription,
      'weatherIcon': weatherIcon,
      'temperature': temperature.celsius,
      'tempMin': tempMin.celsius,
      'tempMax': tempMax.celsius,
      'windSpeed': windSpeed,
      'humidity': humidity,
    };
  }

  static WeatherModel fromMap(Map<String, dynamic> map) {
    return WeatherModel(
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      areaName: map['areaName'],
      weatherDescription: map['weatherDescription'],
      weatherIcon: map['weatherIcon'],
      temperature: MyTemperature(celsius: map['temperature']),
      tempMin: MyTemperature(celsius: map['tempMin']),
      tempMax: MyTemperature(celsius: map['tempMax']),
      windSpeed: map['windSpeed'],
      humidity: map['humidity'],
    );
  }
}
