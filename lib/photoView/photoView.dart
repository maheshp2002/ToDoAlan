import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class photoView extends StatefulWidget {

  final name;
  final url; 
  final about; 
  photoView({Key? key,this.name,this.url,this.about}) : super(key: key);

  @override
  photoViewState createState() => photoViewState();
}

class photoViewState extends State<photoView>{


  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(

        backgroundColor: Colors.black,    
        leading: IconButton(
              icon:  Icon(
                Icons.arrow_back,
                color: Colors.white, // Change Custom Drawer Icon Color
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },),
        title:  Column(children:[
        Text(
          widget.name,
          style: TextStyle(
            color: Colors.white,fontFamily: 'BrandonBI',
            fontSize: 18,
          ),
        ),
        Text("about: " + 
          widget.about,
          style: TextStyle(
            color: Colors.white,fontFamily: 'BrandonLI',
            fontSize: 15,
          ),
        )
        ]),
        elevation: 5.0,
        centerTitle: true,
      ),

      backgroundColor: Colors.black,

      body: Container(
        color: Colors.black,
        child: Center(child: PhotoView(
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: PhotoViewComputedScale.covered * 2,
        imageProvider:
        NetworkImage(widget.url,))),
        ),
  ); 
      
  }


}