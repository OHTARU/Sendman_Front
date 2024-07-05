import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors/colors.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BaseAppBar({
    super.key,
    required this.appBar,
    required this.title,
    this.center = false,
  });

  final AppBar appBar;
  final String title;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: mainBlueColor,
      // leading: IconButton(
      //   icon: Image.asset(
      //     "assets/images/ic_chevron_30_back.png",
      //     width: 24,
      //     height: 24,
      //   ),
      //   onPressed: () => Navigator.of(context).pop(),
      // ),
      centerTitle: center,
      title: Text(
        title,
        style: const TextStyle(
          color: appBarTextColor,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
