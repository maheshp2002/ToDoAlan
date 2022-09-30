import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todoalan/Animation/fadeAnimation.dart';
import 'package:todoalan/Animation/linearprogress.dart';
import 'package:todoalan/NotificationClass/notification.dart';
import 'package:todoalan/addTask/ToDo.dart';
import 'package:todoalan/addTask/addTask.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todoalan/homescreen/wish.dart';
import 'package:todoalan/main.dart';


//global variables................................................................................................
late bool? isDark;

class homepage extends StatefulWidget {

  VoidCallback opendrawer;
  double animationtime;
  homepage({required this.opendrawer, required this.animationtime});

  @override
  homepageState createState() => homepageState();
}
class homepageState extends State<homepage> {

//local variables..................................................................................................
  SharedPreferences? prefs;
  List todos = [];
  bool isCategory = false;
  String catName = "";
  int sortno = 0;
  bool isLoading = false;

//initializing todo.................................................................................................
  setupTodo() async {
    prefs = await SharedPreferences.getInstance();
    String? stringTodo = prefs!.getString('todo');
    List todoList = jsonDecode(stringTodo!);

    for (var todo in todoList) {
      setState(() {
        todos.add(Todo(description: '', id: 1, isCompleted: false, time: '', title: '', category: '').fromJson(todo));
      });
    }
  }

//save data to todo..................................................................................................
  void saveTodo() {
    List items = todos.map((e) => e.toJson()).toList();
    prefs!.setString('todo', jsonEncode(items));
  }

  @override
  void initState() {
    super.initState();

    NotificationService().initNotification();

    setupTodo(); //call setupTodo to initialize

    Future.delayed(Duration(milliseconds: 100), () async{
      setState(() {      
       sortno = todos.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
  var we = MediaQuery.of(context).size.width;
  var he = MediaQuery.of(context).size.height;

  return Scaffold(
    floatingActionButton: FloatingActionButton(onPressed: (){
      //Navigator.push(context,
      //MaterialPageRoute(builder: (context)=> addTask(todo: null,)));
      addTodo();
    },
    backgroundColor: Color.fromARGB(255, 255, 178, 89),
    child: Icon(FontAwesomeIcons.plus, color: Colors.white, ),
    ),
    appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
                icon:  Icon(
                  FontAwesomeIcons.bars,size: 25,
                  color: Theme.of(context).hintColor, // Change Custom Drawer Icon Color
                ),
                onPressed: widget.opendrawer
                ),
          // title:  Text(
          //   "ToDo",
          //   style: TextStyle(
          //     color: Theme.of(context).hintColor, fontFamily: 'BrandonBI',
          //     fontSize: 30,
          //   ),
          // ),
    actions: [
          IconButton(onPressed: () async{
          SharedPreferences prefs = await SharedPreferences.getInstance();   

          if (isDark == false){
          await prefs.setBool('isDark', true);  
          MyApp.of(context).changeTheme(ThemeMode.dark);     
          setState(() {
            isDark = true;
          });      
          } else {
          await prefs.setBool('isDark', false);  
          MyApp.of(context).changeTheme(ThemeMode.light);  
          setState(() {
            isDark = false;
          });  
          print("dark");
          }
          }, 
          icon: Icon(isDark == true ? Icons.dark_mode_outlined
          : Icons.light_mode_outlined, color: Theme.of(context).hintColor,))
        ],
        elevation: 0.0,
        centerTitle: true,
      ),
      
      backgroundColor:  Theme.of(context).scaffoldBackgroundColor,

      body: ListView(children: [

                    FadeAnimation(
                      delay: widget.animationtime,
                      child: Container(
                        margin: EdgeInsets.only(top: he * 0.02),
                        width: we * 0.9,
                        height: he * 0.15,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Timecall(),
                            SizedBox(
                              height: he * 0.06,
                            ),
                            Padding(padding: EdgeInsets.only(left: 15),
                            child: Text(
                              "CATEGORIES",
                              style: TextStyle(
                                  letterSpacing: 1,
                                  color: Colors.grey.withOpacity(0.8),
                                  fontSize: 13),
                            )),
                          ],
                        ),
                      ),
                    ),
      
                    FadeAnimation(
                      delay: widget.animationtime,
                      child: SizedBox(
                        width: we * 2,
                        height: he * 0.16,
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildCategories(context, "Work",
                                const Color(0xFFAC05FF), todos.where((c) => c.category == "Work").length),
                            _buildCategories(context, "Personal",
                                const Color(0xFF0011FF), todos.where((c) => c.category == "Personal").length),
                            _buildCategories(context, "Sports",
                                Colors.red.withOpacity(0.6), todos.where((c) => c.category == "Education").length),
                            _buildCategories(context, "Education",
                                Colors.green.withOpacity(0.6), todos.where((c) => c.category == "Work").length),
                            _buildCategories(context, "Medical",
                                const Color.fromARGB(255, 229, 255, 0), todos.where((c) => c.category == "Medical").length),
                            _buildCategories(context, "Others",
                                const Color.fromARGB(255, 50, 239, 253), todos.where((c) => c.category == "Others").length),
                          ],
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: he * 0.04,
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.only(left: 15, bottom: 15),
                      child: Text("TODAY'S TASKS",
                          style: TextStyle(
                              letterSpacing: 1,
                              color: Colors.grey.withOpacity(0.8),
                              fontSize: 13)),
                    ),
                    FadeAnimation(
                        delay: widget.animationtime,
                        child: SizedBox(
                            width: we * 0.9,
                            height: he * 0.4,
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : todos.isEmpty
                                    ? Center(
                                        child: Image.asset(
                                          "assets/78347-no-search-result.json",
                                          width: we * 0.6,
                                        ),
                                      )
    :  //Container(alignment: Alignment.center,
     // padding: EdgeInsets.only(bottom: 100),
     // height: 500,
        //child:  
        FadeAnimation(
          delay: widget.animationtime,
          child: 


            ListView.builder(
            itemCount: todos.length,
            itemBuilder:
            (BuildContext context, int index) {
             // ignore: non_constant_identifier_names
              //final IsSelected =
              //all_selected_tasks.contains(
              //noted[index].description);

              return isCategory == true ? 

              catName == todos[index].category ?

              Slidable(
              endActionPane: ActionPane(
              motion: const StretchMotion(),
              children: [
              SlidableAction(
              onPressed: (context) {
              setState(() {              
              todos[index].isCompleted = !todos[index].isCompleted;
              });
              delete(todos[index]);
              },
              backgroundColor:const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: "Delete",
              ),
              SlidableAction(
              onPressed: (context) async {
                Todo t = await Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) =>
                addTask(todo: todos[index])));
                if (t != null) {
                  setState(() {
                  todos[index] = t;
                });
                saveTodo();
                }
              },
              backgroundColor:
              const Color(0xFF21B7CA),
              foregroundColor: Colors.white,
              label: "Edit",
              icon: Icons.edit,
              ),
              ],
              ),
              child: makeListTile(todos[index], index)
              )

              : Text("")

              : Slidable(
              endActionPane: ActionPane(
              motion: const StretchMotion(),
              children: [
              SlidableAction(
              onPressed: (context) {
              setState(() {              
              todos[index].isCompleted = !todos[index].isCompleted;
              });
              delete(todos[index]);
              },
              backgroundColor:const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: "Delete",
              ),
              SlidableAction(
              onPressed: (context) async {
                Todo t = await Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) =>
                addTask(todo: todos[index])));
                if (t != null) {
                  setState(() {
                  todos[index] = t;
                });
                saveTodo();
                }
              },
              backgroundColor:
              const Color(0xFF21B7CA),
              foregroundColor: Colors.white,
              label: "Edit",
              icon: Icons.edit,
              ),
              ],
              ),
              child: makeListTile(todos[index], index)
              );
            },
            physics: const BouncingScrollPhysics(),
            )           
        ))
        ),
    ]));
  }

//build category...........................................................................................
  Widget _buildCategories(
      context, String title, Color lineProgress, int numbertask) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;

    return Card(
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
    );
  }

//get value from addTask...................................................................................
  addTodo() async {
    int id = Random().nextInt(30);
    Todo t = Todo(id: id, title: '', description: '', isCompleted: false, time: '', category: '');
    Todo returnTodo = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => addTask(todo: t)));
    if (returnTodo != null) {
      setState(() {
        todos.add(returnTodo);
      });
      saveTodo();
    }
  }

//make listview of task items................................................................................

makeListTile(Todo todo, index) {
    Color color = Colors.red;
    if (todo.title == "Work") {
      color = const Color(0xFFAC05FF);
    } else if (todo.title == "Personal") {
      color = const Color(0xFF0011FF);
    } else if (todo.title == "Sports") {
      color = Colors.red;
    } else if (todo.title == "Education") {
      color = Colors.green;
    } else if (todo.title == "Family") {
      color = Colors.orange;
    }
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;

    return Card(
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
                  onTap: () {
                    if (!todo.isCompleted) {
                      setState(() {
                        todo.isCompleted = true;
                      });
                    } else {
                      setState(() {
                        todo.isCompleted = false;
                      });                      
                    }
                  },
                  child: todo.isCompleted
                      ? const Icon(Icons.check_circle_outlined,
                          color: Colors.grey)
                      
                      : Icon(
                          Icons.circle_outlined,
                          color: color,
                        ),
                )),
            SizedBox(
              width: we * 0.025,
            ),
            Expanded(
                child: Text(todo.description,
                    maxLines: 20,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w500,
                      // ignore: unrelated_type_equality_checks
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    )))
          ],
        ),
      ),
    );
}
//  makeListTile(Todo todo, index) {
    // return GestureDetector(
    // onHorizontalDragEnd: (DragEndDetails details) {
    // if (details.primaryVelocity! > 0) {
    //   // Right Swipe
    //   delete(todo);
    // }
    // },
    // child: ListTile(
    //     shape: StadiumBorder(),
    //     contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
    //     leading: Container(
    //       padding: EdgeInsets.only(right: 12.0),
    //       decoration: new BoxDecoration(
    //       border: new Border(
    //       right: new BorderSide(width: 1.0, color: Theme.of(context).scaffoldBackgroundColor))),
    //       child: CircleAvatar(
    //         backgroundColor: Theme.of(context).hintColor,
    //         child: Text("${index + 1}"),
    //       ),
    //     ),
    //     title:// Row(
    //       //children: [
    //         Text(
    //           todo.title,
    //           style:
    //               TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold, fontFamily: 'BrandonBI',
    //               decoration: todo.isCompleted ? TextDecoration.lineThrough: TextDecoration.none,
    //               decorationColor: Theme.of(context).hintColor),
    //         ),
    //         // SizedBox(
    //         //   width: 10,
    //         // ),
    //         // todo.isCompleted
    //         //     ? Icon(
    //         //         Icons.verified,
    //         //         color: Colors.greenAccent,
    //         //       )
    //         //     : Container()
    //      // ],
    //     //),
    //     // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

    //     subtitle: Wrap(
    //       children: <Widget>[
    //         Text(todo.description,
    //             overflow: TextOverflow.clip,
    //             maxLines: 1,
    //             style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonLI',
    //             decoration: todo.isCompleted ? TextDecoration.lineThrough: TextDecoration.none,
    //             decorationColor: Theme.of(context).hintColor))
    //       ],
    //     ),
    //     trailing: InkWell(
    //         onTap: () {
    //           setState(() {              
    //           todo.isCompleted = !todo.isCompleted;
    //           });
    //           //delete(todo);
    //         },
    //         child: Icon(todo.isCompleted ? FontAwesomeIcons.circleCheck
    //         : FontAwesomeIcons.circle, color: todo.isCompleted  ? Color.fromARGB(255, 1, 255, 9) 
    //         : Theme.of(context).hintColor, size: 30.0))
    //         ));
//  }

//delete item.......................................................................................................
  delete(Todo todo) {
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
                    onPressed: () {
                      setState(() {
                        todos.remove(todo);
                      });
                      Navigator.pop(ctx);
                      saveTodo();
                    },
                    child: Text("Yes",
                    style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonLI')))
              ],
            ));
            
  }

} 
class SalesData {
  SalesData(this.year, this.sales);
  final double year;
  final double sales;
}