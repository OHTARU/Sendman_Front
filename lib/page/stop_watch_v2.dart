import 'package:flutter/material.dart';
//import 'package:flutter_application_1/page/app_bar.dart';
//import 'package:flutter_application_1/page/app_bar.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class StopWatchV2 extends StatefulWidget {
  const StopWatchV2({super.key});

  @override
  State<StopWatchV2> createState() => StopWatchV2State();
}

class StopWatchV2State extends State<StopWatchV2> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Swatch(),
    );
  }
}

class Swatch extends StatefulWidget {
  const Swatch({super.key});

  @override
  State<Swatch> createState() => SwatchState();
}

class SwatchState extends State<Swatch> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  final _isHours = true;

  @override
  void dispose() {
    super.dispose();
    _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: _stopWatchTimer.rawTime.value,
                builder: (context, snapshot) {
                  final value = snapshot.data;
                  final displayTime =
                      StopWatchTimer.getDisplayTime(value!, hours: _isHours);

                  return Text(
                    displayTime,
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  );
                }),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  startButton(),
                  const SizedBox(
                    width: 10,
                  ),
                  stopButton(),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            resetButton(),
          ],
        ),
      ),
    );
  }

  ElevatedButton startButton() {
    return ElevatedButton(
      onPressed: () {
        _stopWatchTimer.onExecute.add(StopWatchExecute.start);
        print('타이머시작');
      },
      style: ElevatedButton.styleFrom(
          textStyle:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      child: const Text('Start'),
    );
  }

  ElevatedButton stopButton() {
    return ElevatedButton(
      onPressed: () {
        _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
        print('타이머중지');
      },
      style: ElevatedButton.styleFrom(
          textStyle:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      child: const Text('Stop'),
    );
  }

  ElevatedButton resetButton() {
    return ElevatedButton(
      onPressed: () {
        _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
        print('타이머 리셋');
      },
      style: ElevatedButton.styleFrom(
          textStyle:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      child: const Text('Reset'),
    );
  }
}
