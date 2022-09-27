import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class homepage extends StatefulWidget {

  VoidCallback opendrawer;
  double animationtime;
  homepage({required this.opendrawer, required this.animationtime});

  @override
  homepageState createState() => homepageState();
}
class homepageState extends State<homepage> {


  @override
  @override
  Widget build(BuildContext context) {

  return Scaffold(

  appBar: AppBar(

        backgroundColor: Colors.blueGrey,
        leading: IconButton(
              icon:  Icon(
                FontAwesomeIcons.bars,
                color: Colors.white24, // Change Custom Drawer Icon Color
              ),
              onPressed: widget.opendrawer
              ),
        title:  Text(
          "ToDo",
          style: TextStyle(
            color: Colors.white60,fontFamily: 'BrandonBI',
            fontSize: 18,
          ),
        ),
        elevation: 5.0,
        centerTitle: true,
  ),
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        child: Text("hi"),
        ),
    );
  }
} 