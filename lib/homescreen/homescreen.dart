import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todoalan/Animation/fadeAnimation.dart';

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
    floatingActionButton: FloatingActionButton(onPressed: (){

    },
    backgroundColor: Colors.lightGreenAccent,
    child: Icon(FontAwesomeIcons.plus, color: Colors.white, ),
    ),
  appBar: AppBar(

        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
              icon:  Icon(
                FontAwesomeIcons.bars,size: 25,
                color: Theme.of(context).hintColor, // Change Custom Drawer Icon Color
              ),
              onPressed: widget.opendrawer
              ),
        title:  Text(
          "ToDo",
          style: TextStyle(
            color: Theme.of(context).hintColor, fontFamily: 'BrandonBI',
            fontSize: 30,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
  ),
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        child:  FadeAnimation(
                      delay: widget.animationtime,
                      child:Text("hi"),
        )),
    );
  }
} 