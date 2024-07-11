import 'package:flutter/material.dart';
import 'package:flutter_application_1/page/app_bar.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class StopWatchV2 extends StatefulWidget {
  const StopWatchV2({super.key});

  @override
  State<StopWatchV2> createState() => StopWatchV2State();
}

class StopWatchV2State extends State<StopWatchV2> {
  
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
  Widget build 
  }
}
