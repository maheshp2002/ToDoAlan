import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todoalan/photoView/photoView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Progerss_Avater extends StatefulWidget {
  @override
  State<Progerss_Avater> createState() => _Progerss_AvaterState();
}

class _Progerss_AvaterState extends State<Progerss_Avater>
    with SingleTickerProviderStateMixin {

  Animation<double>? _animation;
  AnimationController? _controller;
  User? user = FirebaseAuth.instance.currentUser;
  String defaultUrl = "https://firebasestorage.googleapis.com/v0/b/macsapp-f2a0f.appspot.com/o/App%20file%2Fdefault%2Fdownload.png?alt=media&token=ae634acf-dc30-4228-a071-587d9007773e";

  @override
  void initState() {
    // TODO: implement initState  auto play animation
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween(begin: 0.0, end: 0.4).animate(_controller!)
      ..addListener(() {
        setState(() {});
      });

    _controller!.forward();

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller!.reverse();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 150),
      width: 110,
      height: 110,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: _animation!.value,
            strokeWidth: 4,
            valueColor: const AlwaysStoppedAnimation(Color(0xFFFF00FF)),
            backgroundColor: Colors.grey.withOpacity(0.2),
          ),
         Center(
              child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("Users").doc(user!.email!).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              
              if (!snapshot.hasData) {   
              return GestureDetector(
              onTap: ()=> Navigator.push(context, 
              MaterialPageRoute(builder: (contet) => photoView(name: "name", url: defaultUrl, about: "about",),)),
              
              child: CircleAvatar(
                  radius: 45.0,
                  backgroundImage: NetworkImage(defaultUrl)));
              } else {   
              return GestureDetector(
              onTap: ()=> Navigator.push(context, 
              MaterialPageRoute(builder: (contet) => photoView(name: snapshot.data["name"], url: snapshot.data["img"], about: snapshot.data["about"],))),
              child: CircleAvatar(
                  radius: 45.0,
                  backgroundImage: NetworkImage(snapshot.data["img"])));
              }
              })
                  ),
        ],
      ),
    );
  }
}

