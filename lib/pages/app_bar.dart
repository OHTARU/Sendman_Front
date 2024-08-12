import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/colors.dart';

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
        backgroundColor: mainWhiteColor,
        centerTitle: center,
        title: Image.asset(
          'assets/images/SendManLogo.png',
          width: 200,
        ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
