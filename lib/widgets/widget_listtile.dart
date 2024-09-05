import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/colors.dart';

GestureDetector buildListTile(BuildContext context, IconData icon, String title,
    Widget? destinationPage, Color backTileColor) {
  return GestureDetector(
    onTap: () {
      if (destinationPage != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      }
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.topRight,
          colors: [backTileColor, gradientColor2],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
