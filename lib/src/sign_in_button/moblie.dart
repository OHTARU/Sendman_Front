import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/colors.dart';

typedef HandleSignInFn = void Function();

Widget buildSignInButton({HandleSignInFn? onPressed}) {
  double fontSize = 20;
  double iconSize = fontSize * 1.25;

  return Material(
    color: Colors.transparent,
    child: Ink(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black, width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        splashColor: footerMainColor,
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(iconSize / 2),
                child: Image.asset(
                  "assets/images/GoogleLoginLogo.png",
                  width: iconSize,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '구글 아이디로 시작',
                style:
                    TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
