import 'dart:async';

import 'package:flutter/services.dart';

class AccelerometerReading {
  final double x;
  final double y;
  final double z;

  const AccelerometerReading({
    required this.x,
    required this.y,
    required this.z,
  });
}

class SensorTools {
  static const EventChannel _accelerometerChannel = EventChannel(
    'gongke/sensors/accelerometer',
  );

  static Stream<AccelerometerReading> accelerometerEvents() {
    return _accelerometerChannel.receiveBroadcastStream().map((dynamic event) {
      final values = (event as List).cast<num>();
      return AccelerometerReading(
        x: values[0].toDouble(),
        y: values[1].toDouble(),
        z: values[2].toDouble(),
      );
    });
  }
}
