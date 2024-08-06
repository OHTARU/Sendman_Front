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
      backgroundColor: mainBlueColor,
      centerTitle: center,
      title: const Text(
        "메인 앱바",
        style: TextStyle(
          color: appBarTextColor,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
