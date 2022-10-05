import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DrawerItem {
  String title;
  IconData icon;

  DrawerItem({required this.title, required this.icon});
}

class DrawerItems {
  static final backup =
      DrawerItem(title: "Backup", icon: FontAwesomeIcons.cloudArrowUp);
  static final notification =
      DrawerItem(title: "Notification  sound", icon: Icons.notifications_paused,);
  static final profile =
      DrawerItem(title: "Profile", icon: Icons.person);
  static final theme =
      DrawerItem(title: "Theme", icon: FontAwesomeIcons.brush);
  static final logout =
      DrawerItem(title: "Logout", icon: Icons.logout);

  static final List<DrawerItem> all = [backup, notification, profile, theme, logout];
}
