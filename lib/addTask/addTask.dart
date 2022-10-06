import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todoalan/AI/AI.dart';
import 'package:todoalan/Animation/fadeAnimation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoalan/NotificationClass/notificationClass.dart';
import 'package:todoalan/addTask/ToDo.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todoalan/homescreen/homescreen.dart';


enum SelectedColor { Work, Education, Personal, Sports, /* Family,*/ Medical, Others }

class FieldsState{
  String? title;
  String? description;
  String? hours;
  String? minutes;

  FieldsState(this.title, this.description, this.hours, this.minutes);

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'hours': hours,
    'minutes': minutes
  };
}

class addTask extends StatefulWidget {

  Todo todo;
  bool isEdit;
  addTask({Key? key, required this.todo, required this.isEdit}) : super(key: key);

  @override
  addTaskState createState() => addTaskState(todo: this.todo, isEdit: this.isEdit);
}

//global variable......................................................................................

  //controllerd for textfield
  final timeController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  String globalCategory = "";

  //final currentState = FieldsState("", "", "", "");

  // void setVisuals() {
  //   var visuals = jsonEncode(currentState);
  //   AlanVoice.setVisualState(visuals);
  // }

class addTaskState extends State<addTask> {
  
  Todo todo;
  bool isEdit;
  addTaskState({required this.todo, required this.isEdit});

  SelectedColor selected = SelectedColor.Work;
  List<Todo> list = [];

  SharedPreferences? sharedPreferences; //calling instance of sharedpreference
  

  //local variables........................................................................................
  String selectedCategory = "Work";
  bool isPickerSelected = false;
  static DateTime _eventdDate = DateTime.now();
  User? user = FirebaseAuth.instance.currentUser;
  static var now =  TimeOfDay.fromDateTime(DateTime.parse(_eventdDate.toString()));
  String hours = now.toString().substring(10, 15);
  String minutes = now.toString().substring(10, 15);
  String _eventTime = now.toString().substring(10, 15);
  List<int> date = [1, 2, 3, 4, 5, 6, 7];

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin
   = FlutterLocalNotificationsPlugin(); //creating an instace of flutter notification plugin

//this code run when app opens...............................................................................
@override
void initState() {
  super.initState();
  //check if is editing
    if (todo != null) {
      titleController.text = todo.title;
      descriptionController.text = todo.description;
     if(isEdit) {
     _eventTime = timeController.text = todo.time;
     hours = todo.time.toString().substring(0, 2);
     minutes = todo.time.toString().substring(3, 5);   
     isPickerSelected = true;
     }
      setState(() {});
     // setVisuals();
    }
}

//timepicker......................................................................
Future _pickTime() async {
TimeOfDay? timepick = await showTimePicker(
    context: context, initialTime: new TimeOfDay.now());

if (timepick != null) {
  setState(() {
    isPickerSelected = true;
    _eventTime = timeController.text =  timepick.toString().substring(10, 15);
    hours = timepick.toString().substring(10, 12);
    minutes = timepick.toString().substring(13, 15);
  });
  // currentState.hours = hours;
  // currentState.minutes = minutes;
  // setVisuals();
} 
}

  @override
  Widget build(BuildContext context) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;
    return Scaffold(
      // floatingActionButton: !isEnable ? Container(
      // padding: EdgeInsets.only(left: 20),
      // alignment: Alignment.bottomLeft,
      // height: 50,
      // child: PersistentWidget(),
      // ) : null,
      backgroundColor: Color.fromARGB(204, 244, 246, 253),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          child: Column(
            children: [
              FadeAnimation(
                delay: 0.2,
                child: Container(
                  margin: EdgeInsets.only(top: he * 0.05, left: we * 0.73),
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.grey[300], shape: BoxShape.circle),
                  child: Container(
                      width: 47,
                      height: 47,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(204, 244, 246, 253),
                      ),
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              isEdit = false;
                            });
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 20,
                          ))),
                ),
              ),
              FadeAnimation(
                  delay: 0.3,
                  child: Container(
                  width: we * 8,
                  //height: he * 0.12,
                  margin: EdgeInsets.only(top: he * 0.12, left: we * 0.1),
                  child: TextFormField(
                    onChanged: (data) {
                      todo.title = data;
                      // currentState.title = data;
                      // setVisuals();
                    },
                    controller: titleController,
                    decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none,
                      hintText: 'Enter title',
                      hintStyle: TextStyle(fontFamily: "BrandonL",
                      color: Theme.of(context).scaffoldBackgroundColor),
                    ),
                    style: TextStyle(fontFamily: "BrandonL",
                    color: Theme.of(context).scaffoldBackgroundColor),
                  )
                )
              ),

              FadeAnimation(
                  delay: 0.4,
                  child: Container(
                  width: we * 8,
                  //height: he * 0.12,
                  margin: EdgeInsets.only(top: 5, left: we * 0.1),
                  child: TextFormField(
                    onChanged: (data) {
                      todo.description = data;
                      // currentState.description = data;
                      // setVisuals();
                    },                    
                    controller: descriptionController,
                    decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none,
                      hintText: 'Enter description',
                      hintStyle: TextStyle(fontFamily: "BrandonL",
                      color: Theme.of(context).scaffoldBackgroundColor),
                    ),
                    style: TextStyle(fontFamily: "BrandonL",
                    color: Theme.of(context).scaffoldBackgroundColor),
                  )
                )
              ), 

              FadeAnimation(
                  delay: 0.4,
                  child: GestureDetector(
                  onTap: (){
                    _pickTime();
                  },
                  child:  Container(
                  width: we * 8,
                  //height: he * 0.12,
                  margin: EdgeInsets.only(top: 5, left: we * 0.1, bottom: he * 0.12),
                  child: TextFormField( 
                    controller: timeController, 
                    enabled: false,
                    decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      border: InputBorder.none,
                      hintText: _eventTime,
                      hintStyle: TextStyle(fontFamily: "BrandonL",
                      color: Theme.of(context).scaffoldBackgroundColor),
                    ),
                    style: TextStyle(fontFamily: "BrandonL",
                    color: Theme.of(context).scaffoldBackgroundColor),
                  )
                )
              ),), 

             FadeAnimation(delay: 0.5, child: _buidTage()),//category
             
             SizedBox(height: 10,),

             FadeAnimation(delay: 0.6, 
             child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                primary: Color.fromARGB(255, 255, 178, 89),
              ),
              onPressed: () async{
              if (titleController.text.trim().isEmpty && descriptionController.text.trim().isEmpty){

                  Fluttertoast.showToast(  
                  msg: 'Please make sure all fields are filled ..!',  
                  toastLength: Toast.LENGTH_LONG,  
                  gravity: ToastGravity.BOTTOM,  
                  backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                  textColor: Colors.white); 

                }

              else if (titleController.text.trim().isEmpty)
              { 
                Fluttertoast.showToast(  
                msg: 'Please enter a title..!',  
                toastLength: Toast.LENGTH_LONG,  
                gravity: ToastGravity.BOTTOM,  
                backgroundColor: Colors.red,  
                textColor: Colors.white); 
              } 
              
              else if (descriptionController.text.trim().isEmpty)
              { 
                Fluttertoast.showToast(  
                msg: 'Please enter description..!',  
                toastLength: Toast.LENGTH_LONG,  
                gravity: ToastGravity.BOTTOM,  
                backgroundColor: Colors.red,  
                textColor: Colors.white); 

              } 

              else if (!isPickerSelected)
              { 
                Fluttertoast.showToast(  
                msg: 'Please pick a time..!',  
                toastLength: Toast.LENGTH_LONG,  
                gravity: ToastGravity.BOTTOM,  
                backgroundColor: Colors.red,  
                textColor: Colors.white); 

              } else {
                List<String> docids = [todo.id.toString()];
                
                setState(() {
                  todo.category = selectedCategory;
                  todo.time = timeController.text =  _eventTime;
                  todo.time = timeController.text;
                });
                
                //if is editing remove previous scheduled notification first
                if (isEdit) {
                  try {
                    await flutterLocalNotificationsPlugin.cancel(todo.id);
                  } catch(e) {
                    debugPrint(e.toString());
                  }   

                  //for backup
                    try{
                      await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
                      .collection("backup").doc(todo.id.toString()).update({
                        'title': todo.title,
                        'description': todo.description,
                        'time': _eventTime,
                        'category': selectedCategory,
                        'date': date.toString(),
                        'id': todo.id,
                        'isSelected': false
                      });
                    }catch(e) {
                      Fluttertoast.showToast(  
                      msg: 'Unable to backup data, no network connection..!',  
                      toastLength: Toast.LENGTH_LONG,  
                      gravity: ToastGravity.BOTTOM,  
                      backgroundColor: Colors.red,  
                      textColor: Colors.white);   
                    }                               
                } else {
                  try{
                    await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
                    .collection("backup").doc(todo.id.toString()).set({
                      'title': todo.title,
                      'description': todo.description,
                      'time': _eventTime,
                      'category': selectedCategory,
                      'date': date.toString(),
                      'id': todo.id,
                      'isSelected': false
                    });
                  }catch(e) {
                    Fluttertoast.showToast(  
                    msg: 'Unable to backup data, no network connection..!',  
                    toastLength: Toast.LENGTH_LONG,  
                    gravity: ToastGravity.BOTTOM,  
                    backgroundColor: Colors.red, 
                    textColor: Colors.white);   
                  }  
                  // //for id
                  //   try{
                  //     await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
                  //     .collection("ID").doc("ID").set({
                  //       'id': docids,
                  //     });
                  //   }catch(e) {
                  //     debugPrint( "######################################################"+e.toString());
                  //   }                                    
                }

                //setting scheduled notification
                          
                NotificationApi.showScheduledNotification(
                  id: todo.id,
                  title: todo.title,
                  body: todo.description,
                  payload: todo.description,
                  hh:  int.parse(hours),
                  mm: int.parse(minutes),
                  ss: int.parse("00"),
                  date: date,
                  scheduledDate: DateTime.now().add(Duration(seconds: 10))
                );
              
                      Fluttertoast.showToast(  
                      msg: 'Task added..!',  
                      toastLength: Toast.LENGTH_LONG,  
                      gravity: ToastGravity.BOTTOM,  
                      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
                      textColor: Colors.white);                               

                Navigator.pop(context, todo);

                titleController.clear();
                descriptionController.clear();

                setState(() {
                  _eventdDate = DateTime.now();
                  isEdit = false;
                });
              }
              },
              child: Text("Add Task", style: TextStyle(
               fontFamily: "BrandonLI",
               fontSize: 18,
               color: Colors.white,
             )),)
             ), 

    ]))));
  }
  Widget _buidTage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  selected = SelectedColor.Work;
                  selectedCategory = "Work";
                });
              },
              child: Container(
                alignment: Alignment.center,
                width: 90,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected == SelectedColor.Work
                            ? Colors.blue
                            : Colors.white,
                        width: selected == SelectedColor.Work ? 3 : 0),
                    color: selected == SelectedColor.Work
                        ? const Color(0xFFAC05FF).withOpacity(0.6)
                        : Colors.grey.withOpacity(0.5)),
                child: const Text(
                  'Work',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  selected = SelectedColor.Personal;
                  selectedCategory = "Personal";
                });
              },
              child: Container(
                margin: const EdgeInsets.only(left: 14),
                alignment: Alignment.center,
                width: 90,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected == SelectedColor.Personal
                            ? Colors.blue
                            : Colors.white,
                        width: selected == SelectedColor.Personal ? 3 : 0),
                    color: selected == SelectedColor.Personal
                        ? const Color(0xFF0011FF).withOpacity(0.6)
                        : Colors.grey.withOpacity(0.5)),
                child: const Text(
                  'Personal',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  selected = SelectedColor.Sports;
                  selectedCategory = "Sports";
                });
              },
              child: Container(
                margin: const EdgeInsets.only(left: 14),
                alignment: Alignment.center,
                width: 90,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected == SelectedColor.Sports
                            ? Colors.blue
                            : Colors.white,
                        width: selected == SelectedColor.Sports ? 3 : 0),
                    color: selected == SelectedColor.Sports
                        ? Colors.red.withOpacity(0.6)
                        : Colors.grey.withOpacity(0.5)),
                child: const Text(
                  'Sports',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  selected = SelectedColor.Education;
                  selectedCategory = "Education";
                });
              },
              child: Container(
                alignment: Alignment.center,
                width: 90,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected == SelectedColor.Education
                            ? Colors.blue
                            : Colors.white,
                        width: selected == SelectedColor.Education ? 3 : 0),
                    color: selected == SelectedColor.Education
                        ? Colors.green.withOpacity(0.6)
                        : Colors.grey.withOpacity(0.5)),
                child: const Text(
                  'Education',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            // GestureDetector(
            //   onTap: () {
            //     setState(() {
            //       selected = SelectedColor.Family;
            //       selectedCategory = "Family";
            //     });
            //   },
            //   child: Container(
            //     margin: const EdgeInsets.only(left: 14),
            //     alignment: Alignment.center,
            //     width: 90,
            //     height: 40,
            //     decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(20),
            //         border: Border.all(
            //             color: selected == SelectedColor.Family
            //                 ? Colors.blue
            //                 : Colors.white,
            //             width: selected == SelectedColor.Family ? 3 : 0),
            //         color: selected == SelectedColor.Family
            //             ? Colors.orange.withOpacity(0.6)
            //             : Colors.grey.withOpacity(0.5)),
            //     child: const Text(
            //       'Family',
            //       style: TextStyle(color: Colors.white),
            //     ),
            //   ),
            // ),
             GestureDetector(
              onTap: () {
                setState(() {
                  selected = SelectedColor.Medical;
                  selectedCategory = "Medical";
                });
              },
              child: Container(
                margin: const EdgeInsets.only(left: 14),
                alignment: Alignment.center,
                width: 90,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected == SelectedColor.Medical
                            ? Colors.blue
                            : Colors.white,
                        width: selected == SelectedColor.Medical ? 3 : 0),
                    color: selected == SelectedColor.Medical
                        ? Color.fromARGB(255, 229, 255, 0).withOpacity(0.6)
                        : Colors.grey.withOpacity(0.5)),
                child: const Text(
                  'Medical',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  selected = SelectedColor.Others;
                  selectedCategory = "Others";
                });
              },
              child: Container(
                margin: const EdgeInsets.only(left: 14),
                alignment: Alignment.center,
                width: 90,
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected == SelectedColor.Others
                            ? Colors.blue
                            : Colors.white,
                        width: selected == SelectedColor.Others ? 3 : 0),
                    color: selected == SelectedColor.Others
                        ? Color.fromARGB(255, 50, 239, 253).withOpacity(0.6)
                        : Colors.grey.withOpacity(0.5)),
                child: const Text(
                  'Others',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),           
          ],
        )
      ],
    );
  }


//alan add task............................................................................................

//get category
getCategory(String cat) async{
  setState(() {
    selectedCategory = cat;
    todo.category = cat;
  });
}


}
//add task via  voice


addVoiceTask() async{
  WidgetsFlutterBinding.ensureInitialized();

  prefs1 = await SharedPreferences.getInstance();

  List todos = [];
  int id = Random().nextInt(2147483637);
  List<int> date = [1, 2, 3, 4, 5, 6, 7];
  User? user = FirebaseAuth.instance.currentUser;
  Todo t = Todo(id: id, title: '', description: '', isCompleted: false, time: '', category: '');

  String hourstext = timeController.text.toString().substring(0, 2);
  String minutestext = timeController.text.toString().substring(3, 5);   
  
  t.id = id;
  t.title = titleController.text;
  t.description = descriptionController.text;
  t.time = timeController.text;
  t.category = globalCategory;

  //setting scheduled notification
                          
  NotificationApi.showScheduledNotification(
  id: t.id,
  title: titleController.text,
  body: descriptionController.text,
  payload: descriptionController.text,
  hh:  int.parse(hourstext),
  mm: int.parse(minutestext),
  ss: int.parse("00"),
  date: date,
  scheduledDate: DateTime.now().add(Duration(seconds: 10))
  );

  todos.add(t); 

  List items = todos.map((e) => e.toJson()).toList();
  prefs1!.setString(user!.email!, jsonEncode(items));

 // titleController.clear();
  //descriptionController.clear();

}


