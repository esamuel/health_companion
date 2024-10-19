// screens/fasting_timer_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';

class FastingTimerScreen extends StatefulWidget {
  const FastingTimerScreen({super.key});

  @override
  _FastingTimerScreenState createState() => _FastingTimerScreenState();
}

class _FastingTimerScreenState extends State<FastingTimerScreen> {
  DateTime? _startFastingTime;
  DateTime? _endFastingTime;
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  void _selectStartTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startFastingTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          picked.hour,
          picked.minute,
        );
        _endFastingTime = _startFastingTime!.add(Duration(hours: 16));
        _startCountdown();
      });
    }
  }

  void _startCountdown() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _remainingTime = _endFastingTime!.difference(DateTime.now());
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = _endFastingTime!.difference(DateTime.now());
        if (_remainingTime.isNegative) {
          _timer!.cancel();
          _remainingTime = Duration.zero;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fasting Timer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _selectStartTime,
              child: Text('Select Start Fasting Time'),
            ),
            SizedBox(height: 20),
            if (_startFastingTime != null && _endFastingTime != null) ...[
              Text(
                'Start Fasting: ${_startFastingTime!.hour.toString().padLeft(2, '0')}:${_startFastingTime!.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'End Fasting: ${_endFastingTime!.hour.toString().padLeft(2, '0')}:${_endFastingTime!.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                'Remaining Time: ${_remainingTime.inHours.toString().padLeft(2, '0')}:${(_remainingTime.inMinutes % 60).toString().padLeft(2, '0')}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}