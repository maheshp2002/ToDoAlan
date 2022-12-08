import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:todoalan/Notes/addNote.dart';

class noteView extends StatefulWidget {
  
  @override
  noteViewState createState() => noteViewState();
}
  
class noteViewState extends State<noteView>{
  MaterialColor color = Colors.red;
  User? user = FirebaseAuth.instance.currentUser;
  final noteController = TextEditingController();
  final titleController = TextEditingController();

  @override
  void initState() {
  super.initState();
  }

  @override
  Widget build(BuildContext context) {

  return Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: Text("Notes",
      style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonBI', fontSize: 25,),
      ),
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: Icon(FontAwesomeIcons.arrowLeft, color: Theme.of(context).hintColor,)
    ),
    ),
    floatingActionButton: FloatingActionButton(
    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> addNote(isEdit: false, title: '', note: '', theme: 1, color: color))),
    backgroundColor: const Color.fromARGB(255, 255, 178, 89),
    child: Icon(Icons.add, color: Colors.white, size: 35,),
    ),
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,

    body: StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Users").doc(user!.email!)
      .collection("note").orderBy('date', descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              
      if (!snapshot.hasData) {  
        return Center(
        child:
        Image.asset('assets/nothing.png', height: 400, width: 400,)
        );
       
      }
      else if (snapshot.hasData) { 
      return MasonryGridView.count(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 12,
      itemCount: snapshot.data.docs.length,
      itemBuilder: (context, index) {
        return makeGridTile(
          snapshot.data.docs[index]['title'], 
          snapshot.data.docs[index]['note'], 
          snapshot.data.docs[index]['theme'], 
          snapshot.data.docs[index].id,
          snapshot.data.docs[index]['time'], 
        );
      },
    );
    
    } else {
      return Center(child: CircularProgressIndicator(color: const Color.fromARGB(255, 255, 178, 89)));
    }
    }),

  );
  }
//make listview of task items................................................................................
makeGridTile(String title, String note, int theme, String docID, String time) {
    MaterialColor color = Colors.red;

    if (theme == 2) {
      color = Colors.red;
    } else if (theme == 3) {
      color = Colors.orange;
    } else if (theme == 4) {
      color = Colors.yellow;
    } else if (theme == 5) {
      color = Colors.green;
    } else if (theme == 6) {
      color = Colors.blue;
    } else if (theme == 7) {
      color = Colors.purple;
    } else if (theme == 8) {
      color = Colors.pink;
    }

    return GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: ((context) => 
      addNote(isEdit: true, title: title, note: note, theme: theme, color: color)))),
    onLongPress: () => delete(docID, title),
    child: Material(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 12,
          color: theme == 1 ? Theme.of(context).scaffoldBackgroundColor : color,
          child: Container(
          color: Colors.transparent,
          child: Wrap(children: [
            Align(alignment: Alignment.topLeft,
            child: Padding(padding: EdgeInsets.all(10),
            child: Text(title,
            style: TextStyle(color: theme == 1 ? Theme.of(context).hintColor : theme == 4 ? Colors.blueGrey : Colors.white, fontFamily: 'BrandonBI', fontSize: 25,)))),

            Align(alignment: Alignment.centerLeft,
            child: Padding(padding: EdgeInsets.all(10),
            child: Text(note,
            style: TextStyle(color: theme == 1 ? Theme.of(context).hintColor : theme == 4 ? Colors.blueGrey : Colors.white, fontFamily: 'BrandonLI', fontSize: 18,)))),

            Align(alignment: Alignment.bottomRight,
            child: Padding(padding: EdgeInsets.all(10),
            child: Text(time,
            style: TextStyle(color: theme == 1 ? Theme.of(context).hintColor : theme == 4 ? Colors.blueGrey : Colors.white, fontFamily: 'BrandonLI', fontSize: 12,)))),
                    
          ],)
          ),
        ));
  } 


//delete note.......................................................................................................
  delete(String docID, String title) {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Alert!", textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonBI')),
              content: Text("Are you sure to delete ❛$title❜?",
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
                      Navigator.pop(ctx);
                      try{
                      //no of task
                      await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
                      .collection("note").doc(docID).delete();
                     
                      Fluttertoast.showToast(  
                      msg: 'Note deleted..!',  
                      toastLength: Toast.LENGTH_LONG,  
                      gravity: ToastGravity.BOTTOM,  
                      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
                      textColor: Colors.white);                               

                      } catch(e) {
                        Fluttertoast.showToast(  
                        msg: 'No network..!',  
                        toastLength: Toast.LENGTH_LONG,  
                        gravity: ToastGravity.BOTTOM,  
                        backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                        textColor: Colors.white); 
                      }  
                    },
                    child: Text("Yes",
                    style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonLI')))
              ],
            ));
            
  }

}