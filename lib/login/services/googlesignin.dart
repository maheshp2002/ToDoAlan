import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todoalan/addTask/ToDo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todoalan/Animation/fadeAnimation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todoalan/homescreen/Drawerhiden/hidendrawer.dart';
import 'package:todoalan/NotificationClass/notificationClass.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? user;

  Future<User?> signInwithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
        final UserCredential userCredential = await _auth.signInWithCredential(credential);

        user = userCredential.user;
      
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      throw e;
    }
    return user;
  }

  Future<void> signOutFromGoogle() async{
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}


//add details.................................................................................................

class Userdetails extends StatefulWidget {
  Userdetails({Key? key}) : super(key: key);

  @override
  _UserdetailsState createState() => _UserdetailsState();
}

class _UserdetailsState extends State<Userdetails> {

  TextEditingController unameController =  TextEditingController();
  TextEditingController aboutController =  TextEditingController();
  TextEditingController ageController =  TextEditingController();
  TextEditingController heightController =  TextEditingController();
  TextEditingController weightController =  TextEditingController();
  final collectionReference = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  SharedPreferences? prefs;
  bool status = false;
  List todos = [];
  
//..........................................................................................
Future<String> uploadFile(_image) async {

              FirebaseStorage storage = FirebaseStorage.instance;
              Reference ref = storage.ref().child(user!.email! + "/" + "profile" + "/" + user!.email! + "- profile -" + DateTime.now().toString());
              await ref.putFile(File(_image.path));
              String returnURL = await ref.getDownloadURL();
              return returnURL;
            }

//..........................................................................................

  Future<void> saveImages(File _image) async {
               
              bool isEdited = false;
              String imageURL = await uploadFile(_image);


              await FirebaseFirestore.instance.collection("Users").doc(user!.email!).set({
                'name': unameController.text.trim(),
                'about': aboutController.text.trim(),
                'img': imageURL,
                'email': user!.email!,
                'height': heightController.text.trim(),
                'weight': weightController.text.trim(),
                'age': ageController.text.trim(),
              });

              // tasklengths default value
              try{
                await collectionReference.collection("Users").doc(user!.email!)
                .collection("taskLength").doc('task').get()
                .then((snapshot) {
                  setState(() {
                    isEdited = snapshot.get('isEdited');                
                  });
                });
              } catch(e) {
                debugPrint("error");
              }

              try{
                if (isEdited == true) {
                  try{
                    if (status == true) {
                      //no of task
                      FirebaseFirestore.instance.collection("Users").doc(user!.email!)
                      .collection("taskLength").doc('task').update({
                        "Personal": FieldValue.increment(1),
                        "Sports": FieldValue.increment(2),
                      });
                    } else {
                      debugPrint("status false");
                    }
                  }catch(e){
                    debugPrint(e.toString());
                  }
                } else {
                  FirebaseFirestore.instance.collection("Users").doc(user!.email!)
                  .collection("taskLength").doc("task").set({
                      'Work': 0,
                      'Personal': 0,
                      'Sports': 0,
                      'Education': 0,
                      'Medical': 0,
                      'Others': 0,
                      'isEdited': true,
                    }).then((value) => {updateTaskLength});
                }
              } catch(e) {
                Fluttertoast.showToast(  
                msg: 'No network..!',  
                toastLength: Toast.LENGTH_LONG,  
                gravity: ToastGravity.BOTTOM,  
                backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                textColor: Colors.white); 
              }
}

updateTaskLength() async{
  try{               
    if (status == true) {
      //no of task
      await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
      .collection("taskLength").doc('task').update({
        "Personal": FieldValue.increment(1),
        "Sports": FieldValue.increment(2),
      });
    } else {
      debugPrint("status false");
    }
  }catch(e){
    debugPrint(e.toString());
  }
}
//..........................................................................................
// Image Picker
  File _image = File(''); // Used only if you need a single picture
  late bool? Validation;
  bool isloading = false;

  @override
  void initState(){
    super.initState();
    NotificationApi.init(initScheduled: true);
    tz.initializeTimeZones();
    fileFromImageUrl();
    setupTodo();
  }
  
  //initializing todo.................................................................................................
  setupTodo() async {
    prefs = await SharedPreferences.getInstance();
    String? stringTodo = prefs!.getString(user!.email!);
    List todoList = jsonDecode(stringTodo!);

    for (var todo in todoList) {
      setState(() {
        todos.add(Todo(description: '', id: 1, isCompleted: false, time: '', title: '', days: '', date1: '', date2: '', category: '').fromJson(todo));
      });
    }
  }


  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    try{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {      
    Validation = prefs.getBool('validation');
    });
    } catch(e){
    setState(() {      
    Validation = false;
    });
    }

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
  return Validation == true ? HidenDrawer(animationtime: 0.8,)
   : Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isloading == true ? Colors.black : Colors.white,
      body: isloading == true ? Center(child: Image.asset("assets/gif/loading.gif"))
      : ListView(
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
                color: Colors.grey[200],
                child: _image != null
                    ? ClipRRect(
                        //borderRadius: BorderRadius.circular(50),
                        child: Image.file(
                          _image,
                          width: 150,
                          height: 150,
                          fit: BoxFit.fill
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(50)),
                        width: 100,
                        height: 100,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      ),
              ),
            
            )),
            SizedBox(height: 10,),

            Text("Tap this image to change your profile picture", style: TextStyle(fontFamily: 'BrandonLI', color: Colors.blueGrey, fontSize: 10),)
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
              Container(
                width: 350,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xfff3f3f3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: unameController,
                  maxLines: 1,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.sentences,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'BrandonLI',
                    color: Colors.blueGrey
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      suffixIcon: Icon(FontAwesomeIcons.user, color: Color.fromARGB(255, 255, 178, 89)),
                      hintText: "Name",
                      hintStyle: TextStyle(
                        fontSize: 18,
                        fontFamily: 'BrandonLI',
                        color: Colors.blueGrey
                      ),
                      ),
                ),
              ),
              )), 

              FadeAnimationHorizontal(
              delay: 0.4,
              child: 
              Padding(padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
               child:
              Container(
                width: 350,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xfff3f3f3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: aboutController,
                  maxLines: 1,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.sentences,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'BrandonLI',
                    color: Colors.blueGrey
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      suffixIcon: Icon(FontAwesomeIcons.penToSquare, color: Color.fromARGB(255, 255, 178, 89)),
                      hintText: "Bio",
                      hintStyle: TextStyle(
                        fontSize: 18,
                        fontFamily: 'BrandonLI',
                        color: Colors.blueGrey
                      ),
                      ),
                ),
              ),
              )),   

              FadeAnimationHorizontal(
              delay: 0.4,
              child: 
              Padding(padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
               child:
              Container(
                width: 350,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xfff3f3f3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: ageController,
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  textCapitalization: TextCapitalization.sentences,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'BrandonLI',
                    color: Colors.blueGrey
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      suffixIcon: Icon(FontAwesomeIcons.arrowUp91, color: Color.fromARGB(255, 255, 178, 89)),
                      hintText: "Age",
                      hintStyle: TextStyle(
                        fontSize: 18,
                        fontFamily: 'BrandonLI',
                        color: Colors.blueGrey
                      ),
                      ),
                ),
              ),
              )), 

            Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              SizedBox(width:20),

              Expanded(child: 
              FadeAnimationHorizontal(
              delay: 0.4,
              child: 
              Container(
                width: 150,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xfff3f3f3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: heightController,
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  textCapitalization: TextCapitalization.sentences,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'BrandonLI',
                    color: Colors.blueGrey
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      suffixIcon: Icon(FontAwesomeIcons.person, color: Color.fromARGB(255, 255, 178, 89)),
                      hintText: "Height (cm)",
                      hintStyle: TextStyle(
                        fontSize: 18,
                        fontFamily: 'BrandonLI',
                        color: Colors.blueGrey
                      ),
                      ),
                ),
              )),
              ), 

              SizedBox(width: 10,),
              Expanded(child: 
              FadeAnimationHorizontal(
              delay: 0.4,
              child: 
              Container(
                width: 150,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xfff3f3f3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: weightController,
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  textCapitalization: TextCapitalization.sentences,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'BrandonLI',
                    color: Colors.blueGrey
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      suffixIcon: Icon(FontAwesomeIcons.weightScale, color: Color.fromARGB(255, 255, 178, 89)),
                      hintText: "Weight (kg)",
                      hintStyle: TextStyle(
                        fontSize: 18,
                        fontFamily: 'BrandonLI',
                        color: Colors.blueGrey
                      ),
                      ),
                ),
              ))), 
             
              SizedBox(width:20),

      ]),

      SizedBox(height: 10,),

      Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Suggest task", style: TextStyle(fontFamily: 'BrandonBI', color: Colors.blueGrey, fontSize: 20),),

        SizedBox(width: 10,),

          Container(
          child: FlutterSwitch(
            activeText: "Yes",
            inactiveText: "No",
            activeColor: Color.fromARGB(255, 255, 178, 89),
            width: 100.0,
            height: 44.0,
            valueFontSize: 25.0,
            toggleSize: 45.0,
            value: status,
            borderRadius: 30.0,
            padding: 8.0,
            showOnOff: true,
            onToggle: (val) {
              setState(() {
                status = val;
              });
            },
          ),
        ),
      ],),

      SizedBox(height: 20,),

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
              String imgUrl = "";

              if (unameController.text.trim().isEmpty && aboutController.text.trim().isEmpty && ageController.text.trim().isEmpty 
              && heightController.text.trim().isEmpty && weightController.text.trim().isEmpty){

                  Fluttertoast.showToast(  
                  msg: 'Please make sure all fields are filled',  
                  toastLength: Toast.LENGTH_LONG,  
                  gravity: ToastGravity.BOTTOM,  
                  backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                  textColor: Colors.white); 

                }

              else if (unameController.text.trim().isEmpty)
              { 
                Fluttertoast.showToast(  
                msg: 'Please enter your name',  
                toastLength: Toast.LENGTH_LONG,  
                gravity: ToastGravity.BOTTOM,  
                backgroundColor: Colors.red,  
                textColor: Colors.white); 
              } 
              
              else if (aboutController.text.trim().isEmpty)
              { 
                Fluttertoast.showToast(  
                msg: 'Please enter about',  
                toastLength: Toast.LENGTH_LONG,  
                gravity: ToastGravity.BOTTOM,  
                backgroundColor: Colors.red,  
                textColor: Colors.white); 

              } 
              else if (ageController.text.trim().isEmpty)
              { 

                Fluttertoast.showToast(  
                msg: 'Please enter your age',  
                toastLength: Toast.LENGTH_LONG,  
                gravity: ToastGravity.BOTTOM,  
                backgroundColor: Colors.red,  
                textColor: Colors.white); 

                
              } 
              
              else if (heightController.text.trim().isEmpty)
              { 
                Fluttertoast.showToast(  
                msg: 'Please enter your height',  
                toastLength: Toast.LENGTH_LONG,  
                gravity: ToastGravity.BOTTOM,  
                backgroundColor: Colors.red,  
                textColor: Colors.white); 
                
              }
              else if (weightController.text.trim().isEmpty)
              { 
                Fluttertoast.showToast(  
                msg: 'Please enter your weight',  
                toastLength: Toast.LENGTH_LONG,  
                gravity: ToastGravity.BOTTOM,  
                backgroundColor: Colors.red,  
                textColor: Colors.white); 
                
              } else{
                if (int.parse(weightController.text.trim()) <= 10 ||  int.parse(weightController.text.trim()) > 130){
                Fluttertoast.showToast(  
                msg: 'Weight should be between 10 and 130kg',  
                toastLength: Toast.LENGTH_LONG,  
                gravity: ToastGravity.BOTTOM,  
                backgroundColor: Colors.red,  
                textColor: Colors.white);     

              } else if (int.parse(heightController.text.trim()) <= 50 ||  int.parse(heightController.text.trim()) > 250){
                Fluttertoast.showToast(  
                msg: 'Height should be between 50 and 250cm',  
                toastLength: Toast.LENGTH_LONG,  
                gravity: ToastGravity.BOTTOM,  
                backgroundColor: Colors.red,  
                textColor: Colors.white);     

              } else if (int.parse(ageController.text.trim()) < 10 ||  int.parse(ageController.text.trim()) > 120){
                Fluttertoast.showToast(  
                msg: 'Age should be between 10 and 120',  
                toastLength: Toast.LENGTH_LONG,  
                gravity: ToastGravity.BOTTOM,  
                backgroundColor: Colors.red,  
                textColor: Colors.white);     

              }
              else {
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

              
              await saveImages(_image);

              //if status is true, we create a demo task
              status 
              ? createTask(int.parse(heightController.text.trim()), 
              int.parse(weightController.text.trim()), int.parse(ageController.text.trim()),)
              : !status;

              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('validation', true);                

              setState(() {
              isloading = false;
              }); 

              await Navigator.pushReplacement(context, 
              MaterialPageRoute(builder: (BuildContext context) => HidenDrawer(animationtime: 0.8,),));               
              }
              }
              },
              child: Text("ENTER", style: TextStyle(fontFamily: 'BrandonLI', color: Colors.white, fontSize: 20),)
              )))

      ],),
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
    final response = await http.get(Uri.parse('https://firebasestorage.googleapis.com/v0/b/macsapp-f2a0f.appspot.com/o/App%20file%2Fdefault%2Fdownload.png?alt=media&token=ae634acf-dc30-4228-a071-587d9007773e'));

    final documentDirectory = await getApplicationDocumentsDirectory();
    setState(() {
      
    _image = File(join(documentDirectory.path, 'defaultProfile.png'));

    _image.writeAsBytesSync(response.bodyBytes);
    });

    return _image;
  }


//Create Task...................................................................................

  createTask(int height, int weight, int age) async{

    //local variables
    Todo t = Todo(id: 0, title: '', description: '', isCompleted: false, time: '', days: '', date1: '', date2: '', category: '');
    Todo t1 = Todo(id: 0, title: '', description: '', isCompleted: false, time: '', days: '', date1: '', date2: '', category: '');
    Todo t2 = Todo(id: 0, title: '', description: '', isCompleted: false, time: '', days: '', date1: '', date2: '', category: '');
    double _result;

//calculate BMI..................................................................................

      double heightBMI = height.toDouble() / 100;
      double weightBMI = weight.toDouble();

      double heightSquare = heightBMI * heightBMI;
      double result = weightBMI / heightSquare;
      _result = double.parse(result.toStringAsFixed(1));

      print("########################################## + $_result");


//sleep..........................................................................................

    if (age >= 10 && age < 30)
    {
      List<int> date = [1, 2, 3, 4, 5, 6, 7];

      setState(() {
        t.id = Random().nextInt(2147483637);
        t.title = "Sleep";
        t.description = "Wake up during 5am";
        t.time = "21:30";
        t.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
        t.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t.category = "Personal";
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t.id,
      title: t.title,
      body: t.description,
      payload: t.description,
      hh:  21,
      mm: 30,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t);
      });
      saveTodo();
    } 

    else if (age >= 30 && age < 60)
    {
      
      List<int> date = [1, 2, 3, 4, 5, 6, 7];

      setState(() {
        t.id = Random().nextInt(2147483637);
        t.title = "Sleep";
        t.description = "Wake up during 6am";
        t.time = "21:00";
        t.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
        t.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t.category = "Personal";
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t.id,
      title: t.title,
      body: t.description,
      payload: t.description,
      hh:  21,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t);
      });
      saveTodo();
    }

    else if (age >= 60 && age < 100)
    {
      List<int> date = [1, 2, 3, 4, 5, 6, 7];

      setState(() {
        t.id = Random().nextInt(2147483637);
        t.title = "Sleep";
        t.description = "Wake up during 7am";
        t.time = "20:00";
        t.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
        t.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t.category = "Personal";
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t.id,
      title: t.title,
      body: t.description,
      payload: t.description,
      hh:  20,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t);
      });
      saveTodo();
    } else {
      debugPrint("age overflow");
    }


//Workout..........................................................................................

//age combo1.......................................................................................
    if (age >= 10 && age < 30)
    {
      if (_result < 18.5){
      List<int> date = [1, 2, 3, 4, 5];

      setState(() {
        t1.id = Random().nextInt(2147483637);
        t1.title = "Workout";
        t1.description = "Time for excersise, \nDuration: 1 hours";
        t1.time = "06:00";
        t1.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t1.category = "Sports";
        t1.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t1.id,
      title: t1.title,
      body: t1.description,
      payload: t1.description,
      hh:  06,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t1);
      });
      saveTodo();

      //await.................................................
     // Future.delayed(Duration(seconds: 1), (){
      setState(() {
        t2.id = Random().nextInt(2147483637) ;
        t2.title = "Evening workout";
        t2.description = "Time for excersise. \nDuration: 1 hour";
        t2.time = "17:00";
        t2.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t2.category = "Sports";
        t2.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t2.id,
      title: t2.title,
      body: t2.description,
      payload: t2.description,
      hh:  17,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t2);
      });

      List items = todos.map((e) => e.toJson()).toList();
      prefs!.setString(user!.email!, jsonEncode(items));
       //print("##########################################  1");

      //});

      } else if (_result >= 18.5 && _result <= 24.9) {
      List<int> date = [1, 2, 3, 4, 5, 6];

      setState(() {
        t1.id = Random().nextInt(2147483637);
        t1.title = "Workout";
        t1.description = "Time for excersise, \nDuration: 1:30 hours";
        t1.time = "06:00";
        t1.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t1.category = "Sports";
        t1.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t1.id,
      title: t1.title,
      body: t1.description,
      payload: t1.description,
      hh:  06,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t1);
      });

      saveTodo();

      //await.................................................
     // Future.delayed(Duration(seconds: 1), (){
      setState(() {
        t2.id = Random().nextInt(2147483637) ;
        t2.title = "Evening workout";
        t2.description = "Time for excersise. \nDuration: 1:30 hour";
        t2.time = "17:00";
        t2.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t2.category = "Sports";
        t2.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t2.id,
      title: t2.title,
      body: t2.description,
      payload: t2.description,
      hh:  17,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t2);
      });

      List items = todos.map((e) => e.toJson()).toList();
      prefs!.setString(user!.email!, jsonEncode(items));
       //print("##########################################  2");

     // });

      } else {
      List<int> date = [1, 2, 3, 4, 5, 6, 7];

      setState(() {
        t1.id = Random().nextInt(2147483637);
        t1.title = "Workout";
        t1.description = "Time for excersise, \nDuration: 2 hours";
        t1.time = "06:00";
        t1.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t1.category = "Sports";
        t1.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t1.id,
      title: t1.title,
      body: t1.description,
      payload: t1.description,
      hh:  06,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t1);
      });
      saveTodo();

      //await.................................................
      setState(() {
        t2.id = Random().nextInt(2147483637) ;
        t2.title = "Evening workout";
        t2.description = "Time for excersise. \nDuration: 1:30 hour";
        t2.time = "17:00";
        t2.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t2.category = "Sports";
        t2.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t2.id,
      title: t2.title,
      body: t2.description,
      payload: t.description,
      hh:  17,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t2);
      });

      List items = todos.map((e) => e.toJson()).toList();
      prefs!.setString(user!.email!, jsonEncode(items));
       //print("##########################################  3");

      }
            //print("########################################## ");

    } 

//age combo2.......................................................................................
    else if (age >= 30 && age < 60)
    {
      if (_result < 18.5){
      List<int> date = [1, 2, 3, 4, 5];

      setState(() {
        t1.id = Random().nextInt(2147483637);
        t1.title = "Workout";
        t1.description = "Time for excersise, \nDuration: 1 hours";
        t1.time = "06:30";
        t1.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t1.category = "Sports";
        t1.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t1.id,
      title: t1.title,
      body: t1.description,
      payload: t1.description,
      hh:  06,
      mm: 30,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t1);
      });
      saveTodo();

//await.................................................

      setState(() {
        t2.id = Random().nextInt(2147483637);
        t2.title = "Evening workout";
        t2.description = "Time for excersise. \nDuration: 30 minutes";
        t2.time = "17:00";
        t2.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t2.category = "Sports";
        t2.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t2.id,
      title: t2.title,
      body: t2.description,
      payload: t2.description,
      hh:  17,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t2);
      });
      saveTodo();

      } else if (_result >= 18.5 && _result <= 24.9){
      List<int> date = [1, 2, 3, 4, 5, 6];

      setState(() {
        t1.id = Random().nextInt(2147483637);
        t1.title = "Workout";
        t1.description = "Time for excersise, \nDuration: 1 hours";
        t1.time = "06:30";
        t1.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t1.category = "Sports";
        t1.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t1.id,
      title: t1.title,
      body: t1.description,
      payload: t1.description,
      hh:  06,
      mm: 30,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t1);
      });
      saveTodo();

//await.................................................
      setState(() {
        t2.id = Random().nextInt(2147483637);
        t2.title = "Evening workout";
        t2.description = "Time for excersise. \nDuration: 30 minutes";
        t2.time = "17:00";
        t2.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t2.category = "Sports";
        t2.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t2.id,
      title: t2.title,
      body: t2.description,
      payload: t2.description,
      hh:  17,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t2);
      });
      saveTodo();

      } else {
      List<int> date = [1, 2, 3, 4, 5, 6];

      setState(() {
        t1.id = Random().nextInt(2147483637);
        t1.title = "Workout";
        t1.description = "Time for excersise, \nDuration: 1:30 hours";
        t1.time = "06:30";
        t1.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t1.category = "Sports";
        t1.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t1.id,
      title: t1.title,
      body: t1.description,
      payload: t1.description,
      hh:  06,
      mm: 30,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t1);
      });
      saveTodo();

//await.................................................
      //Future.delayed(Duration(seconds: 1), () {
      setState(() {
        t2.id = Random().nextInt(2147483637);
        t2.title = "Evening workout";
        t2.description = "Time for excersise. \nDuration: 1 hour";
        t2.time = "17:00";
        t2.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t2.category = "Sports";
        t2.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t2.id,
      title: t2.title,
      body: t2.description,
      payload: t2.description,
      hh:  17,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t2);
      });
      saveTodo();
     // });

      }
            //print("########################################## + 2");

    } 

//age combo3.......................................................................................
    else
    {
      if (_result < 18.5){
      List<int> date = [1, 2, 3];

      setState(() {
        t1.id = Random().nextInt(2147483637);
        t1.title = "Workout";
        t1.description = "Time for excersise, \nDuration: 30 minutes";
        t1.time = "07:00";
        t1.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t1.category = "Sports";
        t1.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t1.id,
      title: t1.title,
      body: t1.description,
      payload: t1.description,
      hh:  07,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t1);
      });
      saveTodo();

//await.................................................
      setState(() {
        t2.id = Random().nextInt(2147483637);
        t2.title = "Evening workout";
        t2.description = "Time for excersise. \nDuration: 15 minutes";
        t2.time = "17:00";
        t2.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t2.category = "Sports";
        t2.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t2.id,
      title: t2.title,
      body: t2.description,
      payload: t2.description,
      hh:  17,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t2);
      });
      saveTodo();

      } else if (_result >= 18.5 && _result <= 24.9){
      List<int> date = [1, 2, 3, 4];

      setState(() {
        t1.id = Random().nextInt(2147483637);
        t1.title = "Workout";
        t1.description = "Time for excersise, \nDuration: 30 minutes";
        t1.time = "07:00";
        t1.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t1.category = "Sports";
        t1.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t1.id,
      title: t1.title,
      body: t1.description,
      payload: t1.description,
      hh:  07,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t1);
      });
      saveTodo();

//await.................................................
      setState(() {
        t2.id = Random().nextInt(2147483637);
        t2.title = "Evening workout";
        t2.description = "Time for excersise. \nDuration: 15 minutes";
        t2.time = "17:00";
        t2.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t2.category = "Sports";
        t2.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t2.id,
      title: t2.title,
      body: t2.description,
      payload: t2.description,
      hh:  17,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t2);
      });
      saveTodo();

      } else {
      List<int> date = [1, 2, 3, 4, 5];

      setState(() {
        t1.id = Random().nextInt(2147483637);
        t1.title = "Workout";
        t1.description = "Time for excersise, \nDuration: 30 minutes";
        t1.time = "07:00";
        t1.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t1.category = "Sports";
        t1.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t1.id,
      title: t1.title,
      body: t1.description,
      payload: t1.description,
      hh:  07,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t1);
      });
      saveTodo();

//await.................................................
      setState(() {
        t2.id = Random().nextInt(2147483637);
        t2.title = "Evening workout";
        t2.description = "Time for excersise. \nDuration: 30 minutes";
        t2.time = "17:00";
        t2.days = date.toString().replaceAll('[', '').replaceAll(']', '');
        t2.category = "Sports";
        t2.date1 = DateTime.now().toString();
        t1.date2 = DateTime.now().toString().substring(0, 10);
      });
      //setting scheduled notification
                              
      NotificationApi.showScheduledNotification(
      id: t2.id,
      title: t2.title,
      body: t2.description,
      payload: t2.description,
      hh:  17,
      mm: 00,
      ss: int.parse("00"),
      days: date,
      date: DateTime.now().add(Duration(seconds: 10))
      );

      setState(() {
      todos.add(t2);
      });
      saveTodo();

      }
      //print("########################################## + 3");
    } 
        
  }
//save data to todo..................................................................................................
  void saveTodo() {
    List items = todos.map((e) => e.toJson()).toList();
    prefs!.setString(user!.email!, jsonEncode(items));
  }
}


    // await FirebaseFirestore.instance.collection("Users").doc(user!.email!).set({
      
    // });