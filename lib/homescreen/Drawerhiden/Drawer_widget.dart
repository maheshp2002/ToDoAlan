import 'package:flutter/material.dart';
import 'package:todoalan/addTask/backupTask.dart';
import 'package:todoalan/homescreen/avatarProgress.dart';
import 'package:todoalan/login/services/googlesignin.dart';
import 'package:todoalan/main.dart';
import 'package:todoalan/profile/profile.dart';
import 'drawer_items.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DrawerWidget extends StatefulWidget {
  VoidCallback closdDrawer;
  DrawerWidget({required this.closdDrawer});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget>
    with SingleTickerProviderStateMixin {

  User? user = FirebaseAuth.instance.currentUser;
  final double runanim = 0.4;

  @override
  Widget build(BuildContext context) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
        child: Column(
      children: [
        _buildButton(context),
        Progerss_Avater(),
        SizedBox(
          height: he * 0.02,
        ),
        _buidText(context),
        SizedBox(
          height: he * 0.02,
        ),
        buildDrawerItem(context),
        SizedBox(
          height: he * 0.02,
        ),
        //Chart()
      ],
    ));
  }

  Widget buildDrawerItem(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: DrawerItems.all
              .map((item) => ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                    leading: Icon(
                      item.icon,
                      color: Colors.white.withOpacity(0.2),
                      size: 35,
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(color: Colors.white, fontFamily: 'BrandonLI'),
                    ),
                    onTap: () async{
                      if (item.title == 'Logout') {
                        await _logout();
                      } else if (item.title == 'Profile') {
                        Navigator.push(context, MaterialPageRoute(builder: (context)
                        => profileUpdates()));
                      } else if (item.title == 'Backup'){
                        Navigator.push(context, MaterialPageRoute(builder: (context)
                        => backupTask()));
                      } else {
                        Fluttertoast.showToast(  
                        msg: 'Maintenance',  
                        toastLength: Toast.LENGTH_LONG,  
                        gravity: ToastGravity.BOTTOM,  
                        backgroundColor: Color.fromARGB(255, 255, 178, 89),  
                        textColor: Colors.white);                         
                      }
                
                    },
                  ))
              .toList(),
        ),
      );
  Widget _buildButton(contex) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(top: he * 0.09, left: we * 0.15),
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration:
          const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
      child: Container(
          width: 47,
          height: 47,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF04123F),
          ),
          child: IconButton(
              onPressed: widget.closdDrawer,
              icon: const Icon(
                Icons.arrow_back_ios_outlined,
                color: Colors.white,
                size: 20,
              ))),
    );
  }
  
  //logout......................................................................................................
   _logout()  async{ 
     await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor ,
          title:  Text("Do you want to logout?", textAlign: TextAlign.center,
          style:  TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor,fontWeight: FontWeight.bold)),
          actions: <Widget>[
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).scaffoldBackgroundColor 
             ),               
            child:  Text('Cancel',style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),  
            onPressed: () {  
              Navigator.of(context).pop();  
            },  
          ),  
          ElevatedButton(  
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).scaffoldBackgroundColor 
             ),               
            child:  Text('Logout',style: TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor)),  
            onPressed: () async { 

            FirebaseService service = new FirebaseService();
            await service.signOutFromGoogle();
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('validation', false); 
            await  prefs.setBool('isDark', false);   


            RestartWidget.restartApp(context);

            Navigator.of(context).pop();  
            Fluttertoast.showToast(  
            msg: 'Signed out!',  
            toastLength: Toast.LENGTH_LONG,  
            gravity: ToastGravity.BOTTOM,  
            backgroundColor: Color.fromARGB(255, 255, 178, 89),  
            textColor: Colors.white  
            );  

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MyApp()));

            }, 
            ),

          ],
        ));
  } 

  Widget _buidText(context) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;

    return  StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Users").doc(user!.email!).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      
  if (!snapshot.hasData) {   
    return Container(
      margin: EdgeInsets.only(right: we * 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ToDo",
            style: TextStyle(fontFamily: 'BrandonBI', fontSize: 35, color: Colors.white),
          ),
          Text(
            "Settings",
            style: TextStyle(fontFamily: 'BrandonLI', fontSize: 20, color: Colors.white)
          ),
        ],
      ),
    );
  } else {   
    return Container(
      margin: EdgeInsets.only(right: we * 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            snapshot.data["name"],
            style: TextStyle(fontFamily: 'BrandonBI', fontSize: 35, color: Colors.white),
          ),
          Text("about: " + 
            snapshot.data["about"],
            style: TextStyle(fontFamily: 'BrandonLI', fontSize: 20, color: Colors.white)
          ),
        ],
      ),
    );
  }
      });
  }
}
