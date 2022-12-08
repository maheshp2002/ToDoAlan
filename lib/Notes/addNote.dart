import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class addNote extends StatefulWidget {
  
  bool isEdit;
  String title;
  String note;
  int theme;
  MaterialColor color;
  addNote({required this.isEdit, required this.title, required this.note, required this.theme, required this.color});

  @override
  addNoteState createState() => addNoteState();
}
  
class addNoteState extends State<addNote>{
  int theme = 1;
  MaterialColor color = Colors.red;
  User? user = FirebaseAuth.instance.currentUser;
  final noteController = TextEditingController();
  final titleController = TextEditingController();

  @override
  void initState() {
  
  widget.isEdit == true 
  ? setState(() {
    titleController.text = widget.title;
    noteController.text = widget.note;
    theme = widget.theme;
    color = widget.color;
  })
  : null;

  super.initState();
  }

  @override
  Widget build(BuildContext context) {

  return Scaffold(
    appBar: AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: Icon(FontAwesomeIcons.arrowLeft, color: Theme.of(context).hintColor,)
      ),

      actions: [
        StatefulBuilder(builder: (context, setState)
        { 
        return IconButton(onPressed: () => palette(), 
        icon: Icon(Icons.color_lens_outlined, color: theme == 1 ? Theme.of(context).hintColor : color,));
        })
      ],
    ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    floatingActionButton: FloatingActionButton(
    onPressed: () async{
      if (titleController.text.isEmpty) {
        Fluttertoast.showToast(  
        msg: 'Please add a title!',  
        toastLength: Toast.LENGTH_LONG,  
        gravity: ToastGravity.BOTTOM,  
        backgroundColor: Color.fromARGB(255, 248, 17, 0),  
        textColor: Colors.white); 
      } else {
      try{ 
      if (widget.isEdit == true) {
        try{
          await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
          .collection("note").doc(titleController.text).update({
            'title': titleController.text,
            'note': noteController.text,
            'theme': theme,
            'date': DateTime.now().toString(),
            'time': DateFormat('hh:mm a').format(DateTime.now()),
          });
        } catch(e) {
          
          try{
            await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
            .collection("note").doc(widget.title).delete();
          } catch(e) {
            debugPrint(e.toString());
          }

          await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
          .collection("note").doc(titleController.text).set({
            'title': titleController.text,
            'note': noteController.text,
            'theme': theme,
            'date': DateTime.now().toString(),
            'time': DateFormat('hh:mm a').format(DateTime.now()),
          });
        }
      } else {

        await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
        .collection("note").doc(titleController.text).set({
          'title': titleController.text,
          'note': noteController.text,
          'theme': theme,
          'date': DateTime.now().toString(),
          'time': DateFormat('hh:mm a').format(DateTime.now()),
        });
      }

      Fluttertoast.showToast(  
      msg: widget.isEdit == true ? 'Note updated!' : 'Note added!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: const Color.fromARGB(255, 255, 178, 89),  
      textColor: Colors.white); 

      titleController.clear();
      noteController.clear();

      setState(() {
        theme = 1;
        color = Colors.red;
      });

      Navigator.of(context).pop();
    
    } catch(e) {
      Fluttertoast.showToast(  
      msg: 'No network..!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 248, 17, 0),  
      textColor: Colors.white); 
    } }
    
    },
    backgroundColor: const Color.fromARGB(255, 255, 178, 89),
    child: Icon(Icons.check, color: Colors.white, size: 35,),
    ),

    body: Column(
      children: [
          Padding(padding: EdgeInsets.all(10),
          child: TextFormField(
          // onChanged: (data) {
          //   title = data;
          // },
          controller: titleController,
          decoration: InputDecoration(
          enabledBorder: InputBorder.none,
            border: InputBorder.none,
            hintText: 'Enter a title...',
            hintStyle: TextStyle(fontFamily: "BrandonL",
            color: Theme.of(context).hintColor),
          ),
          style: TextStyle(fontFamily: "BrandonL",
          color: Theme.of(context).hintColor),
          )),

          Divider(indent: 10, endIndent: 10, color: Theme.of(context).hintColor,),

          const SizedBox(height: 10,),

          Expanded(
          child: Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: TextFormField(
          // onChanged: (data) {
          //   note = data;
          // },
          controller: noteController,
          decoration: InputDecoration(
          enabledBorder: InputBorder.none,
            border: InputBorder.none,
            hintText: 'Type down your note...',
            hintStyle: TextStyle(fontFamily: "BrandonL",
            color: Theme.of(context).hintColor),
          ),
          style: TextStyle(fontFamily: "BrandonL",
          color: Theme.of(context).hintColor),
          maxLines: 120,
          ))))
        ],
      ),
  );
  }

//color palette.......................................................................................................
  palette() {
    return showDialog(
        context: context,
        builder: (context) =>AlertDialog(
              title: Text("Choose a color", textAlign: TextAlign.left,
              style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonBI', fontSize: 30)),
              actions: [ 
              StatefulBuilder(builder: (context, setState)
              { 
              return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [   
              
              SizedBox(
              height: 100,
              child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                Padding(padding: EdgeInsets.only(left: 10, right: 5),
                child: GestureDetector(
                onTap:() {
                  setState(() {
                    theme = 1;    
                    color = Colors.red;
                  });                 
                },
                child: Container( 
                height:35,
                width: 35,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlueAccent, width: theme == 1 ? 2 : 0),
                  shape: BoxShape.circle,
                  color: Theme.of(context).hintColor),
                ))),

                Padding(padding: EdgeInsets.only(left: 10, right: 5),
                child: GestureDetector(
                onTap:() {
                  setState(() {
                    theme = 2;    
                    color = Colors.red;
                  });                 
                },
                child: Container( 
                height:35,
                width: 35,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlueAccent,  width: theme == 2 ? 2 : 0),
                  shape: BoxShape.circle,
                  color: Colors.red),
                ))),

                Padding(padding: EdgeInsets.only(left: 10, right: 5),
                child: GestureDetector(
                onTap:() {
                  setState(() {
                    theme = 3;    
                    color = Colors.orange;
                  });                 
                },
                child: Container( 
                height:35,
                width: 35,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlueAccent,  width: theme == 3 ? 2 : 0),
                  shape: BoxShape.circle,
                  color: Colors.orange),
                ))),

                Padding(padding: EdgeInsets.only(left: 10, right: 5),
                child: GestureDetector(
                onTap:() {
                  setState(() {
                    theme = 4;    
                    color = Colors.yellow;
                  });                 
                },
                child: Container( 
                height:35,
                width: 35,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlueAccent,  width: theme == 4 ? 2 : 0),
                  shape: BoxShape.circle,
                  color: Colors.yellow),
                ))),

                Padding(padding: EdgeInsets.only(left: 10, right: 5),
                child: GestureDetector(
                onTap:() {
                  setState(() {
                    theme = 5;    
                    color = Colors.green;
                  });                 
                },
                child: Container( 
                height:35,
                width: 35,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlueAccent,  width: theme == 5 ? 2 : 0),
                  shape: BoxShape.circle,
                  color: Colors.green),
                ))),

                Padding(padding: EdgeInsets.only(left: 10, right: 5),
                child: GestureDetector(
                onTap:() {
                  setState(() {
                    theme = 6;    
                    color = Colors.blue;
                  });                 
                },
                child: Container( 
                height:35,
                width: 35,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlueAccent,  width: theme == 6 ? 2 : 0),
                  shape: BoxShape.circle,
                  color: Colors.blue),
                ))),

                Padding(padding: EdgeInsets.only(left: 10, right: 5),
                child: GestureDetector(
                onTap:() {
                  setState(() {
                    theme = 7;    
                    color = Colors.purple;
                  });                 
                },
                child: Container( 
                height:35,
                width: 35,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlueAccent,  width: theme == 7 ? 2 : 0),
                  shape: BoxShape.circle,
                  color: Colors.purple),
                ))),

                Padding(padding: EdgeInsets.only(left: 10, right: 5),
                child: GestureDetector(
                onTap:() {
                  setState(() {
                    theme = 8;    
                    color = Colors.pink;
                  });                 
                },
                child: Container( 
                height:35,
                width: 35,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.lightBlueAccent,  width: theme == 8 ? 2 : 0),
                  shape: BoxShape.circle,
                  color: Colors.pink),
                ))),
              ])),

              const SizedBox(height: 10,), 

              Center(child: 
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Close",
                    style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonLI'))),
              )]);
            }),
          ])         
        );           
  }

}
