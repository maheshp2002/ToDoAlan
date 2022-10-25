import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:todoalan/Animation/fadeAnimation.dart';
import 'package:todoalan/profile/deleteAccount.dart';
import 'package:todoalan/AI/AI.dart';
import 'package:todoalan/AI/AI/API.dart';
import 'package:todoalan/AI/AI/utils.dart';
import 'package:todoalan/homescreen/homescreen.dart';
import 'package:avatar_glow/avatar_glow.dart';

class profileUpdates extends StatefulWidget {
  profileUpdates({Key? key}) : super(key: key);

  @override
  _profileUpdatesState createState() => _profileUpdatesState();
}

class _profileUpdatesState extends State<profileUpdates> {

  TextEditingController unameController =  TextEditingController();
  TextEditingController aboutController =  TextEditingController();
  TextEditingController ageController =  TextEditingController();
  TextEditingController heightController =  TextEditingController();
  TextEditingController weightController =  TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  late String image;
  String text = '';
  bool isListening = false;
  
//..........................................................................................
Future<String> uploadFile(_image) async {

              FirebaseStorage storage = FirebaseStorage.instance;
              Reference ref = storage.ref().child(user!.email! + "/" + "profile" + "/" + user!.email! + "- profile -" + DateTime.now().toString());
              await ref.putFile(File(_image.path));
              String returnURL = await ref.getDownloadURL();
              return returnURL;
            }

//..........................................................................................

  Future<void> saveImages(File _image, String uname, about, age, height, weight) async {
               
              //_image.forEach((image) async {
              String imageURL = await uploadFile(_image);


              await FirebaseFirestore.instance.collection("Users").doc(user!.email!).update({
                'name': uname,
                'about': about,
                'img': imageURL,
                'email': user!.email!,
                'height': height,
                'weight': weight,
                'age': age,
              });
}
//..........................................................................................
// Image Picker
  File _image = File(''); // Used only if you need a single picture
  bool isloading = false;
  final collectionReference = FirebaseFirestore.instance;

  @override
  void initState(){
    super.initState();
    fileFromImageUrl();
  }
  
  
  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    // Let user select photo from gallery
    if(gallery) {
      pickedFile = (await picker.getImage(
          source: ImageSource.gallery,))!;
    } 
    // Otherwise open camera to get new photo
    else{
      pickedFile = (await picker.getImage(
          source: ImageSource.camera,))!;
    }

    setState(() {
      if (pickedFile != null) {
        //_images.add(File(pickedFile.path));
        _image= File(pickedFile.path); // Use if you only need a single picture
      } else {
        debugPrint('No image selected.');
      }
    });
  }

//........................................................................................



  @override
  Widget build(BuildContext context) {

  Future toggleRecording() => SpeechApi().toggleRecording(
    onResult: (text) => setState(() {
      setState(() {
        isListening = true;
      });
      this.text = text;
      Future.delayed(Duration(milliseconds: 1), () {
         Utils().scanText(text, context);
      });
      Future.delayed(Duration(milliseconds: 10), () {
      setState(() {
        isListening = false;
      });
      });
    }),
    onListening: (isListening) {
     // setState(() => this.isListening = isListening);
      },
  );

  return Scaffold(
       floatingActionButton: isEnable ? Container(
      padding: EdgeInsets.only(left: 20),
      alignment: Alignment.bottomLeft,
      height: 50,
      child:   Row(mainAxisAlignment: MainAxisAlignment.start,
    children: [
    AvatarGlow(
    animate: isListening,
    endRadius: 35,
    glowColor: Color.fromARGB(255, 255, 17, 1),
    child: FloatingActionButton(
    backgroundColor: isListening ? Colors.greenAccent : Colors.blue,
    child: Icon(isListening ? Icons.mic : Icons.mic_none, size: 20),
    onPressed: toggleRecording,
    ),
    ),  
    Container(
    width: 100,
    height: 300,
    child: SingleChildScrollView(
    reverse: true,  
    child:
    SubstringHighlight(
    text: text,
    terms: Command.all,
    textStyle: TextStyle(fontSize: 10.0, color: Theme.of(context).hintColor, fontFamily: 'BrandonLI'),
    textStyleHighlight: TextStyle( fontSize: 10.0, color: Colors.red, fontFamily: 'BrandonBI'),
    ))),
    ],),
      ) : null,   
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isloading ? Color(0Xff191f26) : Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(FontAwesomeIcons.arrowLeft, color: Theme.of(context).hintColor,)
        ),
      ),
      resizeToAvoidBottomInset: true,
      backgroundColor: isloading == true ? Color(0Xff191f26) : Theme.of(context).scaffoldBackgroundColor,
      body: isloading == true ? Center(child: Image.asset("assets/gif/loading1.gif"))
      : StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Users").doc(user!.email!).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              
      if (!snapshot.hasData) {  
        return Center(
        child:
        Image.asset('assets/nothing.png', height: 400, width: 400,)
        );
       
      }
      else { 
      return ListView(
      children: [

//..........................................................................................
SizedBox(height: 80,),
      Column(
        children:[
              Center(child: 
              GestureDetector(
              onTap: () {                
                getImage(true);
              },
              child: Container(
                //radius: 55,
              height: 150.0,
                width: 150.0,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: _image != File("")
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          _image,
                          width: 150,
                          height: 150,
                          fit: BoxFit.fill
                        ),
                      )
                : ClipRRect(borderRadius: BorderRadius.circular(20),
                        child: Container(
                        decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(50)),
                        width: 100,
                        height: 100,
                        child: Image.network(
                          snapshot.data['img'],
                          width: 100,
                          height: 100,
                        )),
                      ),
              ),
            
            )),
            SizedBox(height: 10,),

            Text("Tap this image to change profile pic...!", style: TextStyle(fontFamily: 'BrandonLI', color: Colors.blueGrey, fontSize: 10),)
      ]),


//gap btw borders
            const SizedBox(
              height: 16,
            ),

              FadeAnimationHorizontal(
              delay: 0.4,
              child: 
              Padding(padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
               child:
                TextFormField(
                cursorColor: Theme.of(context).hintColor,
                controller: unameController,
                keyboardType: TextInputType.text,
                style:  TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                  fontFamily: 'BrandonBI'
                ),
                decoration:  InputDecoration(
                  hintStyle: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                  fontFamily: 'BrandonLI'
                  ),
                  hintText: snapshot.data['name'],
                  prefixIcon: Icon(FontAwesomeIcons.user, color: Color.fromARGB(255, 255, 178, 89)),
                  border: UnderlineInputBorder(),
                ),
              ),
              )), 

              FadeAnimationHorizontal(
              delay: 0.4,
              child: 
              Padding(padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
               child:
                TextFormField(
                cursorColor: Theme.of(context).hintColor,
                controller: aboutController,
                keyboardType: TextInputType.text,
                style:  TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                  fontFamily: 'BrandonBI'
                ),
                decoration:  InputDecoration(
                  hintStyle: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                  fontFamily: 'BrandonLI'
                  ),
                  hintText: snapshot.data['about'],
                  prefixIcon: Icon(FontAwesomeIcons.penToSquare, color: Color.fromARGB(255, 255, 178, 89)),
                  border: UnderlineInputBorder(),
                ),
              ),
              
              )),   

              FadeAnimationHorizontal(
              delay: 0.4,
              child: 
              Padding(padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
               child:
                TextFormField(
                cursorColor: Theme.of(context).hintColor,
                controller: ageController,
                keyboardType: TextInputType.number,
                style:  TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                  fontFamily: 'BrandonBI'
                ),
                decoration:  InputDecoration(
                  hintStyle: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                  fontFamily: 'BrandonLI'
                  ),
                  hintText: snapshot.data['age'],
                  prefixIcon: Icon(FontAwesomeIcons.arrowUp91, color: Color.fromARGB(255, 255, 178, 89)),
                  border: UnderlineInputBorder(),
                ),
              ),
              )), 

            Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              SizedBox(width:20),

              FadeAnimationHorizontal(
              delay: 0.4,
              child: 
              Expanded(child: 
                TextFormField(
                cursorColor: Theme.of(context).hintColor,
                controller: heightController,
                keyboardType: TextInputType.text,
                style:  TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                  fontFamily: 'BrandonBI'
                ),
                decoration:  InputDecoration(
                  hintStyle: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                  fontFamily: 'BrandonLI'
                  ),
                  hintText: snapshot.data['height'],
                  prefixIcon: Icon(FontAwesomeIcons.person, color: Color.fromARGB(255, 255, 178, 89)),
                  border: UnderlineInputBorder(),
                ),
              ),
              )), 

              SizedBox(width: 10,),

              FadeAnimationHorizontal(
              delay: 0.4,
              child: 
              Expanded(child: 
                TextFormField(
                cursorColor: Theme.of(context).hintColor,
                controller: weightController,
                keyboardType: TextInputType.text,
                style:  TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                  fontFamily: 'BrandonBI'
                ),
                decoration:  InputDecoration(
                  hintStyle: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 16,
                  fontFamily: 'BrandonLI'
                  ),
                  hintText: snapshot.data['weight'],
                  prefixIcon: Icon(FontAwesomeIcons.weightScale, color: Color.fromARGB(255, 255, 178, 89)),
                  border: UnderlineInputBorder(),
                ),
              ),
              )), 
             
              SizedBox(width:20),

      ]),

      SizedBox(height: 30,),

      Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeAnimationHorizontal(
        delay: 0.4,
        child: 
        SizedBox(
        height: 44.0,
        width: 120,
        child:
          ElevatedButton(
          style: ElevatedButton.styleFrom(
          primary: Color.fromARGB(255, 255, 178, 89)
          ),
          onPressed: () async{
              String uname = "";
              String about = "";
              String height = "";
              String weight = "";
              String age = "";
              String imgUrl = "";

              if (unameController.text.trim().isEmpty)
              {
                uname = snapshot.data['name'];
              } else {
                uname = unameController.text.trim();
              }

              if (aboutController.text.trim().isEmpty)
              {
                about = snapshot.data['about'];
              } else {
                about = aboutController.text.trim();
              }

              if (ageController.text.trim().isEmpty)
              {
                age = snapshot.data['age'];
              } else {
                if (int.parse(weightController.text.trim()) <= 10 ||  int.parse(weightController.text.trim()) > 100){
                  Fluttertoast.showToast(  
                  msg: 'weight should be between 10 and 100..!',  
                  toastLength: Toast.LENGTH_LONG,  
                  gravity: ToastGravity.BOTTOM,  
                  backgroundColor: Colors.red,  
                  textColor: Colors.white);     

                } else {
                  age = ageController.text.trim();
                }
                
              }

              if (heightController.text.trim().isEmpty)
              {
                height = snapshot.data['height'];
              } else {
                if (int.parse(heightController.text.trim()) <= 100 ||  int.parse(heightController.text.trim()) > 200){
                  Fluttertoast.showToast(  
                  msg: 'Height should be between 100 and 200..!',  
                  toastLength: Toast.LENGTH_LONG,  
                  gravity: ToastGravity.BOTTOM,  
                  backgroundColor: Colors.red,  
                  textColor: Colors.white);     

                } else {
                  height = heightController.text.trim();
                }               
               
              }

              if (weightController.text.trim().isEmpty)
              {
                weight = snapshot.data['weight'];
              } else {
                if (int.parse(ageController.text.trim()) < 10 ||  int.parse(ageController.text.trim()) > 100){
                  Fluttertoast.showToast(  
                  msg: 'Age should be between 10 and 100..!',  
                  toastLength: Toast.LENGTH_LONG,  
                  gravity: ToastGravity.BOTTOM,  
                  backgroundColor: Colors.red,  
                  textColor: Colors.white);     

                }
                else {                
                weight = weightController.text.trim();
                }
              }

              setState(() {
              isloading = true;
              });

              try{
                await collectionReference.collection("Users").doc(user!.email!).get()
                .then((snapshot) {
                  setState(() {
                  imgUrl = snapshot.get('img');                
                  });
                });  

              deleteFile(imgUrl);
            
            } catch (e){
                  debugPrint("error");
            } 

              
              await saveImages(_image, uname, about, age, height, weight);     

              setState(() {
              isloading = false;
              }); 

              Navigator.of(context).pop();  
              Fluttertoast.showToast(  
              msg: 'Profile updates..!',  
              toastLength: Toast.LENGTH_LONG,  
              gravity: ToastGravity.BOTTOM,  
              backgroundColor: Color.fromARGB(255, 255, 178, 89),  
              textColor: Colors.white  
              ); 

              unameController.clear();
              aboutController.clear();
              ageController.clear();
              heightController.clear();
              weightController.clear();             
              
          },
          child: Text("UPDATE", style: TextStyle(fontFamily: 'BrandonLI', color: Colors.white, fontSize: 20),)
          ))),

        SizedBox(width: 20,),

        FadeAnimationHorizontal(
        delay: 0.4,
        child: 
        SizedBox(
        height: 44.0,
        width: 120,
        child:
          ElevatedButton(
          style: ElevatedButton.styleFrom(
          primary: Color.fromARGB(255, 255, 89, 89)
          ),
          onPressed: () async{
            await Navigator.push(
              context,  MaterialPageRoute(
              builder: (context) => deleteAccount(email: user!.email!, name: snapshot.data['name'])));
          },
          child: Text("DELETE", style: TextStyle(fontFamily: 'BrandonLI', color: Colors.white, fontSize: 20),)
          )))
        ],),
      ],);
      }}),
    );
  }
  
  Future<void> deleteFile(String url) async {
  try {
    await FirebaseStorage.instance.refFromURL(url).delete();
  } catch (e) {
    debugPrint("Error deleting db from cloud: $e");
  }
}
Future<File> fileFromImageUrl() async {
    try{
    await collectionReference.collection("Users").doc(user!.email!).get().then((snapshot) {
    image = snapshot.get('img');
     });    
    } catch(e){
      image = 'https://firebasestorage.googleapis.com/v0/b/macsapp-f2a0f.appspot.com/o/App%20file%2Fdefault%2Fdownload.png?alt=media&token=ae634acf-dc30-4228-a071-587d9007773e';
    }
    
    if ( image == "")
    {
     image = 'https://firebasestorage.googleapis.com/v0/b/macsapp-f2a0f.appspot.com/o/App%20file%2Fdefault%2Fdownload.png?alt=media&token=ae634acf-dc30-4228-a071-587d9007773e';
    }

    final response = await http.get(Uri.parse(image));

    final documentDirectory = await getApplicationDocumentsDirectory();
    setState(() {
      
    _image = File(join(documentDirectory.path, 'defaultProfile.png'));

    _image.writeAsBytesSync(response.bodyBytes);
    });

    return _image;
  }

}
