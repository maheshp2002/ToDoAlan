import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todoalan/Animation/fadeAnimation.dart';
import 'package:todoalan/Animation/linearprogress.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:todoalan/NotificationClass/notificationClass.dart';
import 'package:todoalan/addTask/ToDo.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';


enum Menu { itemDelete, itemClearSelection }

class backupTask extends StatefulWidget {
  backupTask({Key? key}) : super(key: key);

  @override
  _backupTaskState createState() => _backupTaskState();
}

class _backupTaskState extends State<backupTask> {

  final collectionReference = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  final growableList = <String>[];
  SharedPreferences? prefs;
  bool isCategory = false;
  bool isSelectedLocal = false;
  String catName = "";
  List todos = [];
  int worklength = 0;
  int personallength = 0;
  int educationlength = 0;
  int sportslength = 0;
  int medicallength = 0;
  int otherslength = 0;

  @override
  void initState(){
    super.initState();
    NotificationApi.init(initScheduled: true);
    tz.initializeTimeZones();
    setupTodo();
    totalLikes();
  }
  
  //initializing todo.................................................................................................
  setupTodo() async {
    prefs = await SharedPreferences.getInstance();
    String? stringTodo = prefs!.getString(user!.email!);
    List todoList = jsonDecode(stringTodo!);

    for (var todo in todoList) {
      setState(() {
        todos.add(Todo(description: '', id: 1, isCompleted: false, time: '', title: '', category: '').fromJson(todo));
      });
    }
  }

    Future totalLikes() async {
      var respectsQuery = FirebaseFirestore.instance
      .collection("Users").doc(user!.email!)
      .collection('backup')
      .where('category', isEqualTo: "Work");
      var querySnapshot = await respectsQuery.get();
      var totalEquals = querySnapshot.docs.length;
      setState(() {
        worklength = totalEquals;
      });

      var respectsQuery1 = FirebaseFirestore.instance
      .collection("Users").doc(user!.email!)
      .collection('backup')
      .where('category', isEqualTo: "Personal");
      var querySnapshot1 = await respectsQuery1.get();
      var totalEquals1 = querySnapshot1.docs.length;
      setState(() {
        personallength = totalEquals1;
      });

      var respectsQuery2 = FirebaseFirestore.instance
      .collection("Users").doc(user!.email!)
      .collection('backup')
      .where('category', isEqualTo: "Sports");
      var querySnapshot2 = await respectsQuery2.get();
      var totalEquals2 = querySnapshot2.docs.length;
      setState(() {
        sportslength = totalEquals2;
      });
      var respectsQuery3 = FirebaseFirestore.instance
      .collection("Users").doc(user!.email!)
      .collection('backup')
      .where('category', isEqualTo: "Education");
      var querySnapshot3 = await respectsQuery3.get();
      var totalEquals3 = querySnapshot3.docs.length;
      setState(() {
        educationlength = totalEquals3;
      });

      var respectsQuery4 = FirebaseFirestore.instance
      .collection("Users").doc(user!.email!)
      .collection('backup')
      .where('category', isEqualTo: "Medical");
      var querySnapshot4 = await respectsQuery4.get();
      var totalEquals4 = querySnapshot4.docs.length;
      setState(() {
        medicallength = totalEquals4;
      });

      var respectsQuery5 = FirebaseFirestore.instance
      .collection("Users").doc(user!.email!)
      .collection('backup')
      .where('category', isEqualTo: "Others");
      var querySnapshot5 = await respectsQuery5.get();
      var totalEquals5 = querySnapshot5.docs.length;
      setState(() {
        otherslength = totalEquals5;
      });
    }


  Widget build(BuildContext context) {
  var we = MediaQuery.of(context).size.width;
  var he = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        actions: <Widget>[
          // This button presents popup menu items.
          PopupMenuButton<Menu>(
            icon: Icon(FontAwesomeIcons.ellipsisVertical, color: Theme.of(context).hintColor,),

            color: Theme.of(context).scaffoldBackgroundColor,
              // Callback that sets the selected popup menu item.
              onSelected: (Menu item) async{   

                  if (item.name == "itemClearSelection") {
                    try{
                     for (var i = 0 ; i <= growableList.length - 1 ; i++){
                      print(growableList[i]);
                      await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
                      .collection("backup").doc(growableList[i]).update({ 
                        'isSelected': false
                       }); 
                     }
                     setState(() {     
                      growableList.clear();
                      isSelectedLocal = false;                    
                     }); 
                    } catch(e){
                      debugPrint(e.toString());
                     }                   

              } else {     
   
              selectedItem();

              }
              },

              itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
                     PopupMenuItem<Menu>(
                      value: Menu.itemDelete,
                      child: Row(children: [
                        Icon(Icons.delete, color: Theme.of(context).hintColor,),
                        Text(" Delete message",
                        style:  TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor,fontWeight: FontWeight.bold))
                      ]),
                    ),
                     PopupMenuItem<Menu>(
                      value: Menu.itemClearSelection,
                      child: Row(children: [
                        Icon(FontAwesomeIcons.circleXmark, color: Theme.of(context).hintColor,),
                        Text(" Clear selection",
                        style:  TextStyle(fontFamily: 'BrandonLI', color: Theme.of(context).hintColor,fontWeight: FontWeight.bold))
                      ]),
                    ),      
                  ]),
            ],   
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: IconButton(
            icon: Icon(
                    FontAwesomeIcons.arrowLeft,
                    color: Theme.of(context).hintColor, // Change Custom Drawer Icon Color
                  ),
            onPressed: () => Navigator.of(context).pop(),
            ),
            title:  Text(
              "Backup task",
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontFamily: 'BrandonBI',
                fontSize: 18,
              ),
            ),
            elevation: 0.0,
            centerTitle: true,
      ),
      body: StreamBuilder(
      stream: isCategory == false? FirebaseFirestore.instance.collection("Users").doc(user!.email!)
      .collection('backup').snapshots()

      : FirebaseFirestore.instance.collection("Users").doc(user!.email!)
      .collection('backup').where('category', isEqualTo: catName).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              
      if (!snapshot.hasData) {  
        return Center(
        child:
        Image.asset('assets/nothing.png', height: 400, width: 400,)
        );
       
      }
    else { 
    return ListView(
    physics: const BouncingScrollPhysics(),
    children: [
    SizedBox(height: 20,),
    Padding(padding: EdgeInsets.only(left: 10),
    child: FadeAnimation(
            delay: 0.8,
            child: SizedBox(
            width: we * 2,
            height: he * 0.16,
            child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
            _buildCategories(context, "Work",
             const Color(0xFFAC05FF), worklength),
            _buildCategories(context, "Personal",
            const Color(0xFF0011FF), personallength),
            _buildCategories(context, "Sports",
            Colors.red.withOpacity(0.6), sportslength),
            _buildCategories(context, "Education",
            Colors.green.withOpacity(0.6), educationlength),
            _buildCategories(context, "Medical",
            const Color.fromARGB(255, 229, 255, 0), medicallength),
            _buildCategories(context, "Others",
            const Color.fromARGB(255, 50, 239, 253), otherslength),
            ],
            scrollDirection: Axis.horizontal,
            ),
            ),
            )
            ),

              SizedBox(
              height: he * 0.04,
              ),
          ListView.builder(
           physics: const ScrollPhysics(),
           padding: const EdgeInsets.all(5),
           scrollDirection: Axis.vertical,
           shrinkWrap: true,
           itemCount: snapshot.data.docs.length,        
           itemBuilder: (BuildContext context, int index) {
            return  Slidable(
              endActionPane: ActionPane(
              motion: const StretchMotion(),
              children: [
              SlidableAction(
              onPressed: (context) async{
                delete(snapshot.data.docs[index].id);
              },
              backgroundColor:const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: "Delete",
              ),
              SlidableAction(
              onPressed: (context) async {
                Todo t = Todo(id: int.parse(snapshot.data.docs[index].id), title: '', description: '', isCompleted: false, time: '', category: '');

                setState(() {
                  t.id = int.parse(snapshot.data.docs[index].id);
                  t.title = snapshot.data.docs[index]['title'];
                  t.description = snapshot.data.docs[index]['description'];
                  t.time = snapshot.data.docs[index]['time'];
                  t.category = snapshot.data.docs[index]['category'];
                });

                List<int> date = [1, 2, 3, 4, 5, 6, 7];
                String hours = t.time.toString().substring(0, 2);
                String minutes = t.time.toString().substring(3, 5);


                //setting scheduled notification
                                          
                  NotificationApi.showScheduledNotification(
                  id: t.id,
                  title: t.title,
                  body: t.description,
                  payload: t.description,
                  hh:  int.parse(hours),
                  mm: int.parse(minutes),
                  ss: int.parse("00"),
                  date: date,
                  scheduledDate: DateTime.now().add(Duration(seconds: 10))
                  );

                  setState(() {
                  todos.add(t);
                  });

                  List items = todos.map((e) => e.toJson()).toList();
                  prefs!.setString(user!.email!, jsonEncode(items));

                  Fluttertoast.showToast(  
                   msg: 'Task added..! Please restart your app..!',  
                  toastLength: Toast.LENGTH_LONG,  
                  gravity: ToastGravity.BOTTOM,  
                  backgroundColor: Color.fromARGB(255, 255, 178, 89), 
                  textColor: Colors.white);                     
              },
              backgroundColor:
              const Color(0xFF21B7CA),
              foregroundColor: Colors.white,
              label: "Set",
              icon: Icons.alarm,
              ),
              ],
              ),
            child: makeListTile(snapshot.data.docs[index].id, snapshot.data.docs[index]['category'], snapshot.data.docs[index]['title'],
            snapshot.data.docs[index]['description'], snapshot.data.docs[index]['time'], snapshot.data.docs[index]['isSelected'],),
             );
           }),
            ]);           
      }})
      );

  }

//make listview of task items................................................................................

makeListTile(String id, category, title, description, time, isSelected) {
    Color color = Colors.red;
    if (category == "Work") {
      color = const Color(0xFFAC05FF);
    } else if (category == "Personal") {
      color = const Color(0xFF0011FF);
    } else if (category == "Sports") {
      color = Colors.red;
    } else if (category == "Education") {
      color = Colors.green;
    } else if (category == "Medical") {
      color = Colors.yellow;
    } else if (category == "Others") {
      color = Color.fromARGB(255, 50, 239, 253);
    } 
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;

    return GestureDetector(
    onTap: () => !isSelectedLocal ? detailTask(time, title, description, category,) : debugPrint("hi"),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: we * 0.9,
        height: he * 0.09,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 20),
                child: InkWell(
                  onTap: () async{
                    if(isSelected == true){

                      try {
                      await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
                      .collection("backup").doc(id).update({ 
                        'isSelected': false
                       });
                      } catch(e){
                        debugPrint(e.toString());
                      }

                     setState(() {                    
                     growableList.remove(id);
                     isSelectedLocal = false;
                     });

                    } else {

                      try {
                      await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
                      .collection("backup").doc(id).update({ 
                        'isSelected': true
                       });
                      } catch(e){
                        debugPrint(e.toString());
                      }

                    setState(() {
                      growableList.add(id);
                      isSelectedLocal = true;
                    });                   
                    
                    }
                  },
                  child: Icon(isSelected == true ? Icons.check_circle_outline : Icons.circle_outlined,
                          color: isSelected == true ? Colors.grey : color)

                )),
            SizedBox(
              width: we * 0.025,
            ),
            Expanded(
              child: Text(title,
                    maxLines: 20,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w500,
                      // ignore: unrelated_type_equality_checks
                      decoration: isSelected == true ? TextDecoration.lineThrough : TextDecoration.none,
                    )))
          ],
        ),
      ),
    ));
}

//delete item.......................................................................................................
  delete(String id) {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Alert",
              style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonBI')),
              content: Text("Are you sure to delete?",
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
                      await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
                      .collection('backup').doc(id).delete();   
                      Fluttertoast.showToast(  
                      msg: 'Task deleted..!',  
                      toastLength: Toast.LENGTH_LONG,  
                      gravity: ToastGravity.BOTTOM,  
                      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
                      textColor: Colors.white);   

                      Navigator.of(context).pop();             
                    },
                    child: Text("Yes",
                    style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonLI')))
              ],
            ));
            
  }


//detailed view.......................................................................................................
  detailTask(String title, description, time, category) {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(title,textAlign: TextAlign.left,
              style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonBI', fontSize: 30)),
              content: Text("Description: " + description + "\n" + "Reminder time: " + time
              + "\nCategory: " + category, textAlign: TextAlign.left,
              style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonLI')),
              actions: [                
              Center(child: 
                FlatButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: Text("Close",
                    style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonLI'))),
                ),
              ],
            ));
            
  }

//build category...........................................................................................
  Widget _buildCategories(
    context, String title, Color lineProgress, int numbertask) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;

    return GestureDetector(
    onTap: ()async{
      if (!isCategory) {
        setState(() {
          isCategory = true;
          catName = title;
        });
      } else {
        setState(() {
          isCategory = false;
          catName = "";
        });
      }
    },
    child: Card(
      margin: const EdgeInsets.only(left: 23),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        width: we * 0.5,
        height: he * 0.1,
        margin: const EdgeInsets.only(
          top: 25,
          left: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$numbertask task",
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(
              height: he * 0.01,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 23,
                color: Theme.of(context).hintColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: he * 0.03),
            Padding(
                padding: const EdgeInsets.only(right: 30),
                child: LineProgress(
                  value: numbertask.toDouble(),
                  Color: lineProgress,
                )),
          ],
        ),
      ),
    ));
  }

//delete selected task.....................................................
  selectedItem() async {
    String docid = '';
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Alert",
              style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonBI')),
              content: Text("Are you sure to delete?",
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
                      try{
                        for (var i = 0 ; i <= growableList.length - 1 ; i++){
                          try{
                          await collectionReference.collection("Users").doc(user!.email!).collection("backup")
                          .doc(growableList[i]).delete(); 
                                              
                          }catch(e){
                            Fluttertoast.showToast(  
                            msg: 'No task selected..!',  
                            toastLength: Toast.LENGTH_LONG,  
                            gravity: ToastGravity.BOTTOM,  
                            backgroundColor: Color.fromARGB(255, 255, 89, 89),  
                            textColor: Colors.white);  
                          }
                        }
                      }
                    catch(e){
                      Fluttertoast.showToast(  
                      msg: 'No task selected..!',  
                      toastLength: Toast.LENGTH_LONG,  
                      gravity: ToastGravity.BOTTOM,  
                      backgroundColor: Color.fromARGB(255, 255, 89, 89),  
                      textColor: Colors.white);  
                    }  
                    Navigator.of(context).pop();
                    },
                    child: Text("Yes",
                    style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonLI')))
              ],
            ));
  }
}