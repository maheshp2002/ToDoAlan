import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:todoalan/AI/AI/API.dart';
import 'package:todoalan/addTask/addTask.dart';
import 'package:todoalan/profile/profile.dart';
import 'package:todoalan/addTask/backupTask.dart';
import 'package:todoalan/homescreen/Drawerhiden/hidendrawer.dart';
import 'package:todoalan/themeSelect/themeSelect.dart';


class Command {
  static final all = [backup, profile, goBack, homepage, title, description, time, saveTask, category, theme, hour, minutes];

  static const time = 'time is';
  static const hour = 'hours is';
  static const minutes = 'minute is';
  static const title = 'title is';
  static const goBack = 'go back';
  static const theme = 'open theme';
  static const saveTask = 'save task';
  static const backup = 'open backup';
  static const profile = 'open profile';
  static const category = 'category is';
  static const homepage = 'open home page';
  static const description = 'description is';
}

//global instance...........................................................
final  AISpeak = new FlutterTts();

class Utils {
 // String text = '';
  scanText(String rawText, BuildContext context) {
  String  text = rawText.toLowerCase();
    if (text.contains(Command.backup)) {
     // _getTextAfterCommand(text: text, command: Command.backup);
      AISpeak.speak("opening backup"); 
      rawText = '';
      openBackup(context);

    } else if (text.contains(Command.profile)) {
     // _getTextAfterCommand(text: text, command: Command.profile);

      AISpeak.speak("opening profile"); 

      openProfile(context);
      
    } else if (text.contains(Command.goBack)) {
      //_getTextAfterCommand(text: text, command: Command.goBack);

      AISpeak.speak("going back"); 

      goBack(context);

    } else if (text.contains(Command.homepage)) {
       _getTextAfterCommand(text: text, command: Command.homepage);

      AISpeak.speak("opening homepage"); 

      homepage(context);

    } else if (text.contains(Command.title)) {
      final title = _getTextAfterCommand(text: text, command: Command.title);

      AISpeak.speak("adding title as ${title}"); 

      taskTitle(title ,context);

    } else if (text.contains(Command.description)) {
      final description = _getTextAfterCommand(text: text, command: Command.description);

      AISpeak.speak("adding descrition ${description}"); 

      taskDescription(description ,context);

    } else if (text.contains(Command.time)) {
      final time = _getTextAfterCommand(text: text, command: Command.time);

      AISpeak.speak("adding time ${time}"); 

      taskTime(time ,context);

    } else if (text.contains(Command.hour)) {
      final hour = _getTextAfterCommand(text: text, command: Command.hour);

      taskHour(hour ,context);

    } else if (text.contains(Command.minutes)) {
      final minutes = _getTextAfterCommand(text: text, command: Command.minutes);

      taskMinutes(minutes ,context);

    } else if (text.contains(Command.category)) {
      final category1 = _getTextAfterCommand(text: text, command: Command.category);

      AISpeak.speak("category is ${category1}"); 

      taskCategory(category1, context);

    } else if (text.contains(Command.saveTask)) {
      final savetask = _getTextAfterCommand(text: text, command: Command.saveTask);

      AISpeak.speak("saving task"); 

      saveTask(context);

    } else if (text.contains(Command.theme)) {

      AISpeak.speak("opening theme page"); 

      setTheme(context);

    }
    //  else {
    //   Future.delayed(Duration(seconds: 10), () {
    //     AISpeak.speak("Listening..."); 
    //   });
    // }
  }

  static String _getTextAfterCommand({
    String text = "",
    String command = "",
  }) {
    final indexCommand = text.indexOf(command);
    final indexAfter = indexCommand + command.length;

    if (indexCommand == -1) {
      return "";
    } else {
      return text.substring(indexAfter).trim();
    }
  }

//Navigation..............................................................

  static Future openProfile(BuildContext context) async {
      Navigator.push(
      context, MaterialPageRoute(builder: (context) => profileUpdates()));
  }

  static Future openBackup(BuildContext context) async {
      speech.stop();
      Navigator.push(
      context, MaterialPageRoute(builder: (context) => backupTask()));
      // Navigator.pushNamed(context, '/backupTask');
  }

  static Future homepage(BuildContext context) async {
      Navigator.push(
      context, MaterialPageRoute(builder: (context) => HidenDrawer(animationtime: 0.8,)));
  }

  static Future setTheme(BuildContext context) async {
      Navigator.push(
      context, MaterialPageRoute(builder: (context) => themeSelect()));
  }

  static Future goBack(BuildContext context) async {
      Navigator.of(context).pop();
  }

//task add.................................................................................
  static Future taskTitle(String title, BuildContext context) async {
    titleController.text = title;

  }

  static Future taskDescription(String description, BuildContext context) async {
    descriptionController.text = description;

  }

  static Future taskTime(String time, BuildContext context) async {
    timeController.text = time;

  }

  static Future taskHour(String hour, BuildContext context) async {
    AISpeak.speak("adding hour ${hour}"); 
    hr = hour;
    
  }

  static Future taskMinutes(String minutes, BuildContext context) async {
    AISpeak.speak("adding minutes ${minutes}"); 
    timeController.text = hr + ":" + minutes;
    
  }

  static Future taskCategory(String category, BuildContext context) async {
    if (category == 'work') {
      globalCategory = 'Work';
    } else if (category == 'personal') {
      globalCategory = 'Personal';
    } else if (category == 'sports') {
      globalCategory = 'Sports';
    } else if (category == 'education') {
      globalCategory = 'Education';
    } else if (category == 'medical') {
      globalCategory = 'Medical';
    } else if (category == 'others') {
      globalCategory = 'Others';
    } else {
      AISpeak.speak("category not found"); 
    }
    

  }

  static Future saveTask(BuildContext context) async {
    addVoiceTask();
    Future.delayed(Duration(seconds: 1,), (){
      AISpeak.speak("please restart app to see new task"); 
   });
  }

}