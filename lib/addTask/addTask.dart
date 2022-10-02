import 'package:flutter/material.dart';
import 'package:todoalan/Animation/fadeAnimation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoalan/NotificationClass/notificationClass.dart';
import 'package:todoalan/addTask/ToDo.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum SelectedColor { Work, Education, Personal, Sports, /* Family,*/ Medical, Others }

class addTask extends StatefulWidget {

  Todo todo;
  bool isEdit;
  addTask({Key? key, required this.todo, required this.isEdit}) : super(key: key);

  @override
  addTaskState createState() => addTaskState(todo: this.todo, isEdit: this.isEdit);
}
class addTaskState extends State<addTask> {
  
  Todo todo;
  bool isEdit;
  addTaskState({required this.todo, required this.isEdit});

  SelectedColor selected = SelectedColor.Work;
  List<Todo> list = [];

//controllerd for textfield................................................................................
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  SharedPreferences? sharedPreferences; //calling instance of sharedpreference


  //local variables........................................................................................
  String selectedCategory = "Work";
  bool isPickerSelected = false;
  static DateTime _eventdDate = DateTime.now();
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
     _eventTime = todo.time;
     hours = todo.time.toString().substring(0, 2);
     minutes = todo.time.toString().substring(3, 5);   
     isPickerSelected = true;
     }
      setState(() {});
    }
}

//timepicker......................................................................
Future _pickTime() async {
TimeOfDay? timepick = await showTimePicker(
    context: context, initialTime: new TimeOfDay.now());

if (timepick != null) {
  setState(() {
    isPickerSelected = true;
    _eventTime = timepick.toString().substring(10, 15);
    hours = timepick.toString().substring(10, 12);
    minutes = timepick.toString().substring(13, 15);
  });
} 
}

  @override
  Widget build(BuildContext context) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;
    return Scaffold(
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
                setState(() {
                  todo.category = selectedCategory;
                  todo.time = _eventTime;
                });
                
                //if is editing remove previous scheduled notification first
                if (isEdit) {
                  try {
                    await flutterLocalNotificationsPlugin.cancel(todo.id);
                  } catch(e) {
                    debugPrint(e.toString());
                  }                
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
}

