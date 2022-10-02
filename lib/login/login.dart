import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todoalan/login/constants/constants.dart';
import 'package:todoalan/login/services/googlesignin.dart';

class GoogleSignIn extends StatefulWidget {
  GoogleSignIn({Key? key}) : super(key: key);

  @override
  _GoogleSignInState createState() => _GoogleSignInState();
}

class _GoogleSignInState extends State<GoogleSignIn> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return  isLoading == false ? SizedBox(
      width: size.width * 0.8,
      child: OutlinedButton.icon(
        icon: FaIcon(FontAwesomeIcons.google,color: Colors.blueGrey,),
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          FirebaseService service = new FirebaseService();
          try {
           await service.signInwithGoogle();
          } catch(e){
            if(e is FirebaseAuthException){
              showMessage(e.message.toString());
            }         

          }
          Navigator.pushReplacement(context, 
          MaterialPageRoute(builder: (BuildContext context) => Userdetails(),)); 
          setState(() {
            isLoading = false;
          });
        },
        label: Text(
          Constants.textSignInGoogle,
          style: TextStyle(
              color: Colors.blueGrey, fontWeight: FontWeight.bold),
        ),
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(Constants.kGreyColor),
            side: MaterialStateProperty.all<BorderSide>(BorderSide.none)),
      ),
    ) : CircularProgressIndicator(color: Colors.blueGrey,);
  }

  void showMessage(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error", style: TextStyle(
                color: Colors.white60,
                fontFamily: 'BrandonBI',
                fontSize: 20,
              ),),
            content: Text(message),
            actions: [
              TextButton(
                child: Text("Ok", style: TextStyle(
                color: Colors.white60,
                fontFamily: 'BrandonLI',
                fontSize: 18,
              ),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
// Future<void> ValidationPage() async {
//           try{
//            SharedPreferences prefs = await SharedPreferences.getInstance();
//            bool? Validation = prefs.getBool('validation');
//            if (Validation == true){
//                 Navigator.pushReplacement(context, 
//                 MaterialPageRoute(builder: (BuildContext context) => homeScreen(),)); 
//            }else if (Validation == false){
//                 Navigator.pushReplacement(context, 
//                 MaterialPageRoute(builder: (BuildContext context) => Userdetails(),)); 
//           }  
//           } 
//           catch(e){
//                 Navigator.pushReplacement(context, 
//                 MaterialPageRoute(builder: (BuildContext context) => Userdetails(),));             
//           }   
// }
}
