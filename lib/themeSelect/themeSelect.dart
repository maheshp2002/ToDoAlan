import 'package:todoalan/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todoalan/homescreen/homescreen.dart';
import 'package:todoalan/Animation/fadeAnimation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class themeSelect extends StatefulWidget {
  themeSelect({Key? key}) : super(key: key);

  @override
  _themeSelectState createState() => _themeSelectState();
}


class _themeSelectState extends State<themeSelect> {

  int selectedNo = 0;
  String text = '';
  bool isListening = false;

  List<Themes> themeColors = [
    Themes(url: 'assets/todoAlanTheme/colors1.png', id: 1),
    Themes(url: 'assets/todoAlanTheme/colors2.png', id: 2),
    Themes(url: 'assets/todoAlanTheme/colors3.png', id: 3),
    Themes(url: 'assets/todoAlanTheme/colors4.png', id: 4),
    Themes(url: 'assets/todoAlanTheme/colors5.png', id: 5),
    Themes(url: 'assets/todoAlanTheme/colors6.png', id: 6),
    Themes(url: 'assets/todoAlanTheme/colors7.png', id: 7),
    Themes(url: 'assets/todoAlanTheme/colors8.png', id: 8),
    Themes(url: 'assets/todoAlanTheme/colors9.png', id: 9),
    Themes(url: 'assets/todoAlanTheme/colors10.png', id: 10),
    Themes(url: 'assets/todoAlanTheme/colors11.png', id: 11),
    Themes(url: 'assets/todoAlanTheme/colors12.png', id: 12),
    Themes(url: 'assets/todoAlanTheme/colors13.png', id: 13),
    Themes(url: 'assets/todoAlanTheme/colors14.png', id: 14),
  ];

  @override
  Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:  Text(
          "Themes",
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontFamily: 'BrandonBI',
            fontSize: 25,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(FontAwesomeIcons.arrowLeft, color: Theme.of(context).hintColor,)
        ),
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: 
      
      GridView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(10),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: themeColors.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
      childAspectRatio: MediaQuery.of(context).size.width /
      (MediaQuery.of(context).size.height / 1.2),
      ),         
      itemBuilder: (BuildContext context, int index) {
      return FadeAnimation(
      delay: 0.8, 
      child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

      Padding(padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Card(
        color: Color.fromARGB(255, 255, 178, 89),
        shape: selectedNo != int.parse(themeColors[index].id.toString()) ?  
        RoundedRectangleBorder(
        borderRadius: 
        BorderRadius.circular(20))
        : RoundedRectangleBorder(
        side:  BorderSide(color: Color.fromARGB(255, 0, 217, 255), width: 2.0),
        borderRadius: BorderRadius.circular(20)),
        elevation: selectedNo == int.parse(themeColors[index].id.toString()) ? 18 : 0,
       // borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: GestureDetector(
        onDoubleTap: () {
          setState(() {
            selectedNo = 0;           
          });   
        },
        onTap: () async{
          if (selectedNo == int.parse(themeColors[index].id.toString())){
           changeTheme(themeColors[index].id);  
          } else {
          Fluttertoast.showToast(  
          msg: 'Tap again to set this theme as navTheme..!',  
          toastLength: Toast.LENGTH_LONG,  
          gravity: ToastGravity.BOTTOM,  
          backgroundColor: Color.fromARGB(255, 255, 178, 89),  
          textColor: Colors.white);   
          setState(() {
            selectedNo = int.parse(themeColors[index].id.toString());           
          });         
          }         
        },
        child:
        Image.asset(themeColors[index].url.toString(), /*height: 150, width: 150,*/),

       ),
       ),
       ),
      ]));
      })
  );
  }
//change theme.......................................................................................................
  changeTheme(int? id) {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Do you want to set this theme as your navbar theme?",
              style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonBI')),
              content: Text("This will restart your app",
              style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonLI')),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: Text("No",
                    style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonLI'))),
                FlatButton(
                    onPressed: () async{
                      Navigator.of(ctx).pop();             
                      
                      SharedPreferences prefs = await SharedPreferences.getInstance(); 
                      
                      prefs.setInt('NavBartheme', int.parse(id.toString()));

                      NavBartheme = id;

                      RestartWidget.restartApp(context);

                      Fluttertoast.showToast(  
                      msg: 'New theme set..!',  
                      toastLength: Toast.LENGTH_LONG,  
                      gravity: ToastGravity.BOTTOM,  
                      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
                      textColor: Colors.white);   

                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => MyApp()));

                    },
                    child: Text("Yes",
                    style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonLI')))
              ],
            ));
            
  }
 
}

//LIST OF theme
class Themes{
  String? url;
  int? id;


// added '?'
  
  Themes({this.url, this.id,});
  // can also add 'required' keyword
}