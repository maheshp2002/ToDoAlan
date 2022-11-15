import 'Drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todoalan/homescreen/homescreen.dart';

class HidenDrawer extends StatefulWidget {
  double animationtime;
  HidenDrawer({Key? key, required this.animationtime}) : super(key: key);

  @override
  State<HidenDrawer> createState() => _HidenDrawerState();
}
class _HidenDrawerState extends State<HidenDrawer> {
  late double xOffset;
  late double yOffset;
  late double scaleFactor;
  late bool isDrawingOpen;
  // int dely = 300;
  bool isDragging = false;

  void onpenDrawer() {
    setState(() {
      xOffset = 300;
      yOffset = 70;
      scaleFactor = 0.85;
      isDrawingOpen = true;
    });
  }

  void closeDrawer() {
    setState(() {
      xOffset = 0;
      yOffset = 0;
      scaleFactor = 1;
      isDrawingOpen = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    closeDrawer();
  }

  @override
  Widget build(BuildContext context) => Container(
  decoration: BoxDecoration(
  gradient:  LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  //colors: [Color(0xFFED7B8A), Color(0xFF04123F)]
  colors: navColor
  )),
  child: Scaffold(
      backgroundColor: Colors.transparent,
     // backgroundColor: const Color(0xFF04123F),
      body: Stack(children: [
        DrawerWidget(
          closdDrawer: closeDrawer,
        ),
        buildpage()
      ])));

  Widget buildpage() {
    return GestureDetector(
      onHorizontalDragStart: (details) => isDragging = true,
      onHorizontalDragUpdate: (details) {
        if (!isDragging) return;
        const delta = 1;
        if (details.delta.dx > delta) {
          onpenDrawer();
        } else if (details.delta.dx < -delta) {
          closeDrawer();
        }
      },
      onTap: closeDrawer,
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: Matrix4.translationValues(xOffset, yOffset, 0)
            ..scale(scaleFactor),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isDrawingOpen ? 30 : 0),
            child: homepage(
              opendrawer: onpenDrawer,
              animationtime: widget.animationtime,
            ),
          )),
    );
  }
}
