import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class BaseDrawer extends StatelessWidget {
  const BaseDrawer({
    super.key,
    required this.drawer,
    required this.user
  });
  final GoogleSignInAccount? user;
  final Drawer drawer;

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    if(user != null){
      return Drawer(
        child: ListView(
        padding: EdgeInsets.zero,
        children: [
            DrawerHeader(
              child: Column(
                children: [
                  GoogleUserCircleAvatar(identity: user),
                  Text(user.displayName ?? '',style: const TextStyle(fontSize: 30))
                ],
              ),
          ),
          ListTile(
            title: const Text("item 1"),
            onTap: (){
              Navigator.pop(context);
            },
          )
        ],
      )
      );
    }else{
      return const Drawer();
    }
  }

}
