import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DrawerItem {
  String title;
  IconData icon;

  DrawerItem({required this.title, required this.icon});
}

class DrawerItems {
  static final categorise =
      DrawerItem(title: "Backup", icon: FontAwesomeIcons.cloudArrowUp);
  static final analytics =
      DrawerItem(title: "Notification  sound", icon: Icons.notifications_paused,);
  static final about =
      DrawerItem(title: "Logout", icon: Icons.logout);

  static final List<DrawerItem> all = [categorise, analytics,about];
}
