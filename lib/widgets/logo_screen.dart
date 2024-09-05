import 'package:flutter/material.dart';

Widget buildLogoScreen() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Image.asset(
        'assets/images/SendManText.png',
      ),
      const SizedBox(
        height: 40,
      ),
      Image.asset(
        'assets/images/Icon.png',
        width: 190,
      ),
      const SizedBox(
        height: 55,
      ),
    ],
  );
}
