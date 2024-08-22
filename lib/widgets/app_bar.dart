import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BaseAppBar({
    super.key,
    required this.appBar,
    this.center = false,
  });
  final AppBar appBar;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.white,
        centerTitle: center,
        title: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SendManDemo()),
                (route) => false);
          },
          icon: Image.asset(
            'assets/images/SendManLogo.png',
            fit: BoxFit.contain,
            width: 200,
          ),
          padding: const EdgeInsets.fromLTRB(36, 5, 36, 5),
        ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
