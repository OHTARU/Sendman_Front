import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/colors.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => InitScreenState();
}

class InitScreenState extends State<InitScreen> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => false,
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1.0)),
        child: Scaffold(
          backgroundColor: footerMainColor,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: screenHeight * 0.384375),
              const Expanded(child: SizedBox()),
              Align(
                child: Text("© Copyright 2020, 내방니방(MRYR)",
                    style: TextStyle(
                      fontSize: screenWidth * (14 / 360),
                      color: const Color.fromRGBO(255, 255, 255, 0.6),
                    )),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.0625,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
