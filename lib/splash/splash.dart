import 'package:todoalan/homescreen/Drawerhiden/hidendrawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:todoalan/homescreen/homescreen.dart';
import 'package:todoalan/login/services/googlesignin.dart';
import 'package:todoalan/main.dart';


class Splash extends StatefulWidget {

  _SplashState createState() => _SplashState();
}

  class _SplashState extends State<Splash>{
    bool? isValidation; 

  @override
  void initState(){
  super.initState();
  Future.delayed(Duration(milliseconds: 100), () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isValidation = await prefs.getBool("validation") ?? false;
  });
  getTheme();
  _navigatetoHome();
  }

  _navigatetoHome()async{
    await Future.delayed(const Duration(milliseconds: 3000), () {});
    getUserEmail == "notSigned" ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp2()))
    : isValidation == false ? 
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Userdetails()))
    : Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HidenDrawer(animationtime: 0.8,)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //color: Colors.blueGrey.shade900,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

        children: [
           Container(

        child: //Icon(Icons.radio, size: 250, color: Colors.white,),
        Image.asset('assets/logo2.png', width:150,height:150),
        ),
          Padding(
             padding: EdgeInsets.only(top: 10),
           child: Text('Evoke',
               textAlign: TextAlign.center,
               overflow: TextOverflow.ellipsis,
               style: TextStyle(
               fontFamily: "BrandonBI",
               fontSize: 35,
               color: Theme.of(context).hintColor,
             ),)
           ),
      ],
        ),
      ),
      ),
      // bottomSheet: Container(color: Theme.of(context).scaffoldBackgroundColor,
      //   child: 

      // Row(mainAxisAlignment: MainAxisAlignment.center,
      //   children:  [ 
      //   Text("from - \n ", textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor,fontFamily: 'BrandonL'))]),

      //   ),
    );
}
  getTheme() {
    if (NavBartheme == 1) {
      setState(() {
        navColor = [Color(0xFFED7B8A), Color(0xFF04123F)];
      });
      
    }
    else if (NavBartheme == 2) {
      setState(() {
        navColor = [Color(0xFFED7B8A), Color(0xFF9055FF)];
      });
      
    } 
    else if (NavBartheme == 3) {
      setState(() {
        navColor = [Color(0xFF8C04DB), Color(0xFF04123F)];
      });
      
    } 
    else if (NavBartheme == 4) {
      setState(() {
        navColor = [Color(0xFF8C04DB), Color(0xFF2EAAFA)];
      });
      
    } 
    else if (NavBartheme == 5) {
      setState(() {
        navColor = [Color(0xFF8C04DB), Color(0xFFFFCAC9)];
      });
      
    } 
    else if (NavBartheme == 6) {
      setState(() {
        navColor = [Color(0xFF737DEF), Color(0xFFFFCAC9)];
      });
      
    } 
    else if (NavBartheme == 7) {
      setState(() {
        navColor = [Color(0xFF737DEF), Color(0xFF2EAAFA)];
      });
      
    } 
    else if (NavBartheme == 8) {
      setState(() {
        navColor = [Color(0xFF8C04DB), Color(0xFF2EAAFA)];
      });
     
    } 
    else if (NavBartheme == 9) {
      setState(() {
        navColor = [Color(0xFF8C04DB), Color(0xFF04123F)];
      });
      
    } 
    else if (NavBartheme == 10) {
      setState(() {
        navColor = [Color(0xFFEC00BC), Color(0xFFFC6767)];
      });
      
    } 
    else if (NavBartheme == 11) {
      setState(() {
        navColor = [Color(0xFFEC00BC), Color(0xFF04123F)];
      });
      
    } 
    else if (NavBartheme == 12) {
      setState(() {
        navColor = [Color(0xFFECBC), Color(0xFFC9F0E4)];
      });
      
    } 
    else if (NavBartheme == 13) {
      setState(() {
        navColor = [Color(0xFFA0B5EB), Color(0xFF3957ED)];
      });
      
    } 
    else {
      setState(() {
        navColor = [Color(0xFF04123F), Color(0xFF04123F)];
      });
      
    }

  }


}