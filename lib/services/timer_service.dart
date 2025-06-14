import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerService {
  Timer? _timer;
  int _recordDuration = 0;

  final ValueNotifier<String> timerValue = ValueNotifier('00:00');

  void start() {
    _recordDuration = 0;
    _updateTimerValue();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _recordDuration++;
      _updateTimerValue();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _updateTimerValue() {
    final minutes = (_recordDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordDuration % 60).toString().padLeft(2, '0');
    timerValue.value = '$minutes:$seconds';
  }

  void dispose() {
    stop();
    timerValue.dispose();
  }
}