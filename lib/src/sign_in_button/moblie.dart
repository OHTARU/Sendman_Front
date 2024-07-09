import 'package:flutter/material.dart';
import 'stub.dart';

Widget buildSignInButton({HandleSignInFn? onPressed}) {
  return IconButton(
    onPressed: onPressed,
    icon: ClipRRect(
      borderRadius: BorderRadius.circular(40.0),
      child: Image.asset(
        "assets/images/GoogleLoginLogo.jpg",
        width: 80,
      ),
    ),
    iconSize: 1,
  );
}
