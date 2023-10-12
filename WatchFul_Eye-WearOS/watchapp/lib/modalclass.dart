import 'dart:convert';

import 'package:flutter/services.dart';

class HealthData {
  final double noise;
  final double hrv;
  final double heartRate;
  final double spo2;

  HealthData(
      {required this.noise,
      required this.hrv,
      required this.heartRate,
      required this.spo2});

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      noise: json['audio_level'].toDouble(),
      hrv: json['hrv'].toDouble(),
      heartRate: json['heart_rate'].toDouble(),
      spo2: json['oxygen_saturation'].toDouble(),
    );
  }
}