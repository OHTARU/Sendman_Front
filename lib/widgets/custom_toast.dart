import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomToast {
  static DateTime? _lastBackPressTime;

  static bool showExitToast() {
    final currentTime = DateTime.now();
    final isSecondBackPress = _lastBackPressTime != null && 
        currentTime.difference(_lastBackPressTime!) <= Duration(seconds: 2);

    if (isSecondBackPress) {
      return true; // 앱 종료 신호
    } else {
      _lastBackPressTime = currentTime;
      Fluttertoast.showToast(
        msg: "'뒤로'버튼을 한 번 더 누르면 종료됩니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black.withOpacity(0.8),
        textColor: Colors.white,
        fontSize: 30.0,
      );
      return false; // 앱 유지
    }
  }
}