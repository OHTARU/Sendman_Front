import 'package:flutter/material.dart';
import 'dart:async';

class StopWatchPage extends StatefulWidget {
  const StopWatchPage({super.key});

  @override
  StopWatchPageState createState() => StopWatchPageState();

  static StopWatchPageState? of(BuildContext context) {
    final StopWatchPageState? state =
        context.findAncestorStateOfType<StopWatchPageState>();
    return state;
  }
}

class StopWatchPageState extends State<StopWatchPage> {
  var _icon = Icons.play_arrow;
  var _color = Colors.amber;

  Timer? _timer;
  var _time = 0;
  var _isPlaying = false;
  final List<String> _saveTimes = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var sec = _time ~/ 100;
    var hundredth = '${_time % 100}'.padLeft(2, '0');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              '$sec',
              style: const TextStyle(fontSize: 80),
            ),
            Text(
              '.$hundredth',
              style: const TextStyle(fontSize: 30),
            )
          ],
        ),
        const SizedBox(height: 50),
        SizedBox(
          width: 200,
          height: 300,
          child: ListView(
            children: _saveTimes
                .map((time) => Text(time, style: const TextStyle(fontSize: 20)))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        FloatingActionButton(
          onPressed: () => setState(() {
            _click();
          }),
          backgroundColor: _color,
          child: Icon(_icon),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _reset();
                });
              },
              child: const Text('Clear Board'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _saveTime('$sec.$hundredth');
                });
              },
              child: const Text('Save Time!!'),
            ),
          ],
        ),
      ],
    );
  }

  void _click() {
    _isPlaying = !_isPlaying;

    if (_isPlaying) {
      _icon = Icons.pause;
      _color = Colors.grey;
      _start();
    } else {
      _icon = Icons.play_arrow;
      _color = Colors.amber;
      _pause();
    }
  }

  void _start() {
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _time++;
      });
    });
  }

  void _pause() {
    _timer?.cancel();
  }

  void _reset() {
    setState(() {
      _isPlaying = false;
      _timer?.cancel();
      _saveTimes.clear();
      _time = 0;
    });
  }

  void _saveTime(String time) {
    _saveTimes.insert(0, '${_saveTimes.length + 1}등 : $time');
  }

  // 외부에서 호출할 수 있는 메서드 추가
  void startStopwatch() {
    if (!_isPlaying) {
      _click();
    }
  }

  void stopStopwatch() {
    if (_isPlaying) {
      _click();
    }
  }

  void resetStopwatch() {
    _reset();
  }
}
