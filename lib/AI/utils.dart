import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:todoalan/profile/profile.dart';
import 'package:todoalan/addTask/backupTask.dart';
import 'package:todoalan/homescreen/Drawerhiden/hidendrawer.dart';


class Command {
  static final all = [backup, profile, goBack, homepage];

  static const goBack = 'go back';
  static const backup = 'open backup';
  static const profile = 'open profile';
  static const homepage = 'open homepage';
}

//global instance...........................................................
final  AISpeak = new FlutterTts();

class Utils {
  static scanText(String rawText, BuildContext context) {
    final text = rawText.toLowerCase();

    if (text.contains(Command.backup)) {
      final body = _getTextAfterCommand(text: text, command: Command.backup);

      AISpeak.speak("opening backup"); 

      openBackup(context);

    } else if (text.contains(Command.profile)) {
      final url = _getTextAfterCommand(text: text, command: Command.profile);

      AISpeak.speak("opening profile"); 

      openProfile(context);
      
    } else if (text.contains(Command.goBack)) {
      final url = _getTextAfterCommand(text: text, command: Command.goBack);

      AISpeak.speak("going back"); 

      goBack(context);
    } else if (text.contains(Command.homepage)) {
      final url = _getTextAfterCommand(text: text, command: Command.homepage);

      AISpeak.speak("opening homrpage"); 

      homepage(context);
    }
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

  static Future openProfile(BuildContext context) async {
      Navigator.push(
      context, MaterialPageRoute(builder: (context) => profileUpdates()));
  }

  static Future openBackup(BuildContext context) async {
      Navigator.push(
      context, MaterialPageRoute(builder: (context) => backupTask()));
  }

  static Future homepage(BuildContext context) async {
      Navigator.push(
      context, MaterialPageRoute(builder: (context) => HidenDrawer(animationtime: 0.8,)));
  }

  static Future goBack(BuildContext context) async {
      Navigator.of(context).pop();
  }
}