import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/colors.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class Swatch extends StatefulWidget {
  final StopWatchTimer stopWatchTimer;
  final bool isMinutes;

  const Swatch({
    super.key,
    required this.stopWatchTimer,
    required this.isMinutes,
  });

  @override
  State<Swatch> createState() => SwatchState();
}

class SwatchState extends State<Swatch> {
  @override
  void dispose() {
    super.dispose();
    widget.stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          StreamBuilder<int>(
              stream: widget.stopWatchTimer.rawTime,
              initialData: widget.stopWatchTimer.rawTime.value,
              builder: (context, snapshot) {
                final value = snapshot.data;
                final displayTime = StopWatchTimer.getDisplayTime(value!,
                    minute: widget.isMinutes);

                return Text(
                  displayTime,
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: mainBlueColor,
                    decoration: TextDecoration.none,
                  ),
                );
              }),
          const SizedBox(height: 150),
        ],
      ),
    );
  }
}
