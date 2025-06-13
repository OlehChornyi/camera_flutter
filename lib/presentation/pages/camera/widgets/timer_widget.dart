import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  const TimerWidget({super.key, required this.timerValue});

  final String timerValue;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      right: 40,
      child: Container(
        width: 64,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(50),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 2),
            Text(
              timerValue,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
