import 'dart:math';
import 'dart:async';
import 'dart:isolate';
import 'dart:convert';
import 'package:todoalan/AI/commands.dart';
import 'package:todoalan/main.dart';
import 'package:flutter/material.dart';
import 'package:todoalan/addTask/ToDo.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:todoalan/homescreen/wish.dart';
import 'package:todoalan/addTask/addTask.dart';
import 'package:todoalan/profile/profile.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:notifications/notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todoalan/addTask/backupTask.dart';
import 'package:flutter_speech/flutter_speech.dart';
import 'package:background_stt/background_stt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todoalan/themeSelect/themeSelect.dart';
import 'package:todoalan/Animation/fadeAnimation.dart';
import 'package:todoalan/Animation/linearprogress.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todoalan/homescreen/Drawerhiden/hidendrawer.dart';
import 'package:todoalan/NotificationClass/notificationClass.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//global variables................................................................................................

//for main.dart
  late bool? isDark;
  late bool? isNotificationSound;
  late int? NavBartheme;
  late List<Color> navColor;
  

//for AI
  String listeningText = "";
  bool isEnable = false;
  SharedPreferences? prefs1;

//for noificatio speak
  late Notifications notifications;
  late StreamSubscription<NotificationEvent> subscription;

class homepage extends StatefulWidget {

  VoidCallback opendrawer;
  double animationtime;
  homepage({required this.opendrawer, required this.animationtime});

  @override
  homepageState createState() => homepageState();
}
  
class homepageState extends State<homepage> with WidgetsBindingObserver {

//local variables..................................................................................................
  SharedPreferences? prefs;
  List todos = [];
  bool isCategory = false;
  String catName = "";
  int sortno = 0;
  bool isLoading = false;
  bool isAlanActive = false;
  FlutterTts flutterTts = FlutterTts();
  ReceivePort? _receivePort;
  User? user = FirebaseAuth.instance.currentUser;
  String text = '';
  bool isListening = false;
  String isTitle = '';
  var _service = BackgroundStt();

  //speech recognition
  late SpeechRecognition _speech;

  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  String transcription = '';



  final collectionReference = FirebaseFirestore.instance;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin
   = FlutterLocalNotificationsPlugin(); //creating an instace of flutter notification plugin

// Voice AI........................................................................................................
    startService(String? command,) async{

      //Navigation commands..............................................................................
      if(command == "open backup" || command == "openbackup") {
        _service.speak("Opening backup", false);
        Navigator.push(
        context, MaterialPageRoute(builder: (context) => backupTask()));

      } else if(command == "open theme" || command == "opentheme") {
        _service.speak("Opening theme", false);
        Navigator.push(
        context, MaterialPageRoute(builder: (context) => themeSelect()));

      } else if(command == "open profile" || command == "openprofile") {
        _service.speak("Opening profile", false);
        Navigator.push(
        context, MaterialPageRoute(builder: (context) => profileUpdates()));

      } else if(command == "open homepage" || command == "open home page" ) {
      _service.speak("Opening homepage", false);
        Navigator.push(
        context, MaterialPageRoute(builder: (context) => HidenDrawer(animationtime: 0.8,)));

      } else if(command == "go back" || command == "goback") {
        _service.speak("going back", false);
        Navigator.of(context).pop();

      //Other commands..............................................................................
      } else if(command == "tell me the commands" || command == "commands" 
      || command == "tell me the command" || command == "command") {
        _service.speak("Opening command page.", false);
        Navigator.push(
        context, MaterialPageRoute(builder: (context) => commands()));

      } else if(command == "enable notification sound") {
        _service.speak("Notification sound enabled.", false);

        SharedPreferences prefs = await SharedPreferences.getInstance();   

        await prefs.setBool('isNotificationSound', true);

        setState(() {
          isNotificationSound = true;
        });  

       Fluttertoast.showToast(  
       msg: 'Notification sound enabled..!',
       toastLength: Toast.LENGTH_LONG,  
       gravity: ToastGravity.BOTTOM,  
       backgroundColor: Color.fromARGB(255, 255, 178, 89),  
       textColor: Colors.white);   

      } else if(command == "disable notification sound") {
        _service.speak("Notification sound disabled.", false);

        SharedPreferences prefs = await SharedPreferences.getInstance();   

       await prefs.setBool('isNotificationSound', false);

       setState(() {
          isNotificationSound = false;
       });
       homepageState().closeReceivePort();
       stopListening();

       Fluttertoast.showToast(  
       msg: 'Notification sound disabled..!',
       toastLength: Toast.LENGTH_LONG,  
       gravity: ToastGravity.BOTTOM,  
       backgroundColor: Color.fromARGB(255, 255, 178, 89),  
       textColor: Colors.white);   
       
      }
      
      //Add task commands..............................................................................
      else if(command == "set title" || command == "title") {
        setState(() {
          listeningText = "Hold on...";
        });
        _service.speak("Please press the record button to set title.", false);
        Future.delayed(Duration(milliseconds: 100), () => _service.pauseListening());
        setState(() {
          isEnable = true;
          isTitle = 'title';
          listeningText = "Now tap record button and speak...";
        });

      } else if(command == "set description" || command == "description") {
        setState(() {
          listeningText = "Hold on...";
        });
        flutterTts.speak("Please press the record button to set description.");
        Future.delayed(Duration(milliseconds: 100), () => _service.pauseListening());
        setState(() {
          isEnable = true;
          isTitle = 'description';
          listeningText = "Now tap record button and speak...";
        });

      } else if(command == "set time" || command == "time") {
        setState(() {
          listeningText = "Hold on...";
        });
        _service.speak("Please press the record button to set time.", false);
        Future.delayed(Duration(seconds: 100), () => _service.pauseListening());
        setState(() {
          isEnable = true;
          isTitle = 'time';
          listeningText = "Now tap record button and speak...";
        });

      } else if(command == "category is work" || command == "is work") {
        setState(() {
          globalCategory = 'Work';
        });

        Fluttertoast.showToast(  
        msg: "Setting category as Work",  
        toastLength: Toast.LENGTH_LONG,  
        gravity: ToastGravity.TOP,  
        backgroundColor: Color.fromARGB(255, 255, 178, 89),  
        textColor: Colors.white); 

        _service.speak('Setting category as Work', false);
        

      } else if(command == "category is personal" || command == "is personal") {
        setState(() {
          globalCategory = 'Personal';
        });
                
        Fluttertoast.showToast(  
        msg: "Setting category as Personal",  
        toastLength: Toast.LENGTH_LONG,  
        gravity: ToastGravity.TOP,  
        backgroundColor: Color.fromARGB(255, 255, 178, 89),  
        textColor: Colors.white); 

        _service.speak('Setting category as personal', false);

      } else if(command == "category is sports" || command == "is sports") {
        setState(() {
          globalCategory = 'Sports';
        });
                
        Fluttertoast.showToast(  
        msg: "Setting category as Sports",  
        toastLength: Toast.LENGTH_LONG,  
        gravity: ToastGravity.TOP,  
        backgroundColor: Color.fromARGB(255, 255, 178, 89),  
        textColor: Colors.white); 

        _service.speak('Setting category as Sports', false);

      } else if(command == "category is education" || command == "is education") {
        setState(() {
          globalCategory = 'Education';
        });
                
        Fluttertoast.showToast(  
        msg: "Setting category as Education",  
        toastLength: Toast.LENGTH_LONG,  
        gravity: ToastGravity.TOP,  
        backgroundColor: Color.fromARGB(255, 255, 178, 89),  
        textColor: Colors.white); 

        _service.speak('Setting category as Education', false);

      } else if(command == "category is medical" || command == "is medical") {
        setState(() {
          globalCategory = 'Medical';
        });      

        Fluttertoast.showToast(  
        msg: "Setting category as Medical",  
        toastLength: Toast.LENGTH_LONG,  
        gravity: ToastGravity.TOP,  
        backgroundColor: Color.fromARGB(255, 255, 178, 89),  
        textColor: Colors.white); 

        _service.speak('Setting category as Medical', false);

      } else if(command == "category is others" || command == "is others") {
        setState(() {
          globalCategory = 'Others';
        });
                
        Fluttertoast.showToast(  
        msg: "Setting category as Others",  
        toastLength: Toast.LENGTH_LONG,  
        gravity: ToastGravity.TOP,  
        backgroundColor: Color.fromARGB(255, 255, 178, 89),  
        textColor: Colors.white); 

        _service.speak('Setting category as Others', false);

      } else if(command == "save task" || command == "save") {
        _service.speak("saving task", false);
        addVoiceTask();
        
        Future.delayed(Duration(seconds: 3), () => _service.speak("Please restart app to see new task", false));

      } 
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

//speech recognition..................................................................................................
// Platform messages are asynchronous, so we initialize in an async method.
  void activateSpeechRecognizer() {
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.setErrorHandler(errorHandler);
    _speech.activate('fr_FR').then((res) {
      setState(() => _speechRecognitionAvailable = res);
    });
  }

 void start() => _speech.activate('en_IN').then((_) {
        return _speech.listen().then((result) {
          print('_MyAppState.start => result $result');
          setState(() {
            listeningText = "Listening...";
            _isListening = result;
          });
        });
      });


//time conversions...............................................................................................
  voiceTime(String time) {
    int hour = 0;
    int minute = 0;
    // 5:40 a.m.
    String tempHour = "";
    String tempMinute = "";

    if (time.substring(1, 2) == ":") 
    {
      setState(() {
        tempHour = time.substring(0, 1);
        tempMinute = time.substring(2, 5);
        hour = int.parse(tempHour);
        minute = int.parse(tempMinute);  
        });
    } else {
      setState(() {
        tempHour = time.substring(0, 2);
        tempMinute = time.substring(3, 6);
        hour = int.parse(tempHour); 
        minute = int.parse(tempMinute);
      });
    }


    try{
      if(time.substring(6, 10) == "p.m." || time.substring(6, 10) == ".p.m" 
      || time.substring(6, 9) == "p.m" || time.substring(6, 8) == "pm")
      {
        setState(() {hour += 12;});
      }

    } catch(e){
      if (time.substring(5, 9) == "p.m." || time.substring(5, 9) == ".p.m" 
      || time.substring(5, 8) == "p.m" || time.substring(5, 7) == "pm") 
      {
        setState(() {hour += 12;});
      }

    } 

    if (hour >= 24 || minute >= 60) {
      flutterTts.speak("$hour:$minute is an invalid time.");

      Fluttertoast.showToast(  
      msg: '$hour:$minute is an invalid time...!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 255, 0, 0),  
      textColor: Colors.white); 
     
    }
 
    Future.delayed(Duration(seconds: 5), () {

    try{    
      if(time.substring(6, 10) == "a.m." || time.substring(6, 10) == ".a.m" 
      || time.substring(6, 9) == "a.m" || time.substring(6, 8) == "am") {
        if(hour < 10) {
          setState(() {timeController.text = "0" + hour.toString() + ":" + minute.toString();});

        } else {
          setState(() {timeController.text = hour.toString() + ":" + minute.toString();});

        }
      } else {
        setState(() {timeController.text = hour.toString() + ":" + minute.toString();});

      }

    } catch(e){
      if (time.substring(5, 9) == "a.m." || time.substring(5, 9) == ".a.m" 
      || time.substring(5, 8) == "a.m" || time.substring(5, 7) == "am") {
        if(hour < 10) {
          setState(() {timeController.text = "0" + hour.toString() + ":" + minute.toString();});

        } else {
          setState(() {timeController.text = hour.toString() + ":" + minute.toString();});

        }

      } else {
        setState(() {timeController.text = hour.toString() + ":" + minute.toString();});

      }
    }
  });
  }

  void cancel() =>
      _speech.cancel().then((_) => setState(() => _isListening = false));

  void stop() => _speech.stop().then((_) {
        setState(() => _isListening = false);
        _service.resumeListening();

        Future.delayed(Duration(seconds: 2), () {

        setState(() {
           isEnable = false;
        }); 
        _service.speak(
          isTitle == 'title' ? 'setting title as $transcription'
          : isTitle == 'description' ? 'setting description as $transcription'
          : 'setting time ${transcription}', false
        );

        Fluttertoast.showToast(  
        msg: isTitle == 'title' ? 'Title is $transcription' : isTitle == 'description' ?
        'Description is $transcription' : 'time is ${transcription}',  
        toastLength: Toast.LENGTH_LONG,  
        gravity: ToastGravity.TOP,  
        backgroundColor: Color.fromARGB(255, 255, 178, 89),  
        textColor: Colors.white); 

      });
      });

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onRecognitionStarted() {
    setState(() => _isListening = true);
  }

  void onRecognitionResult(String text) {
    print('_MyAppState.onRecognitionResult... $text');
    setState(() => transcription = text);
  }

  void onRecognitionComplete(String text) {
    print('_MyAppState.onRecognitionComplete... $text');
    setState(() => _isListening = false);


    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        listeningText = "Hold on...";
      });

      isTitle == 'time' ? voiceTime(transcription) : 
      isTitle == 'title' ? setState((){titleController.text = transcription;})
      : setState((){descriptionController.text = transcription;});

      stop(); 
    });
  }

  void errorHandler() => activateSpeechRecognizer();

//save data to todo..................................................................................................
  void saveTodo() {
    List items = todos.map((e) => e.toJson()).toList();
    prefs!.setString(user!.email!, jsonEncode(items));
  }

//...................................................................................................................

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);

    NotificationApi.init(initScheduled: true);
    initPlatformState(); //notification speak
    _initForegroundTask(); //foreground service
    // listenNotifications();
    tz.initializeTimeZones();

    setupTodo(); //call setupTodo to initialize
    Future.delayed(Duration(milliseconds: 100), () async{
      setState(() {      
       sortno = todos.length;
      });
    });
    
    _service.startSpeechListenService; //start sst

    // init sst
    _service.getSpeechResults().onData((data) {
      print("getSpeechResults: ${data.result} , ${data.isPartial} [STT Mode]");

      startService(data.result);
    });
    
    activateSpeechRecognizer();

    super.initState();
  }

  @override
  void dispose() {
  // _closeReceivePort();
  WidgetsBinding.instance!.removeObserver(this);
  super.dispose();
  }

//foreground service...............................................................................................
  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Color.fromARGB(255, 255, 178, 89),
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

//check if app is in background........................................................
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
  super.didChangeAppLifecycleState(state);

  final isBg = state == AppLifecycleState.paused;
  final isClosed = state == AppLifecycleState.detached;
  final isScreen = state == AppLifecycleState.resumed;

  isBg || isScreen == false || isClosed == true
      ? runTask(isClosed)
      : await _service.resumeListening();
  }


runTask(bool isClosed) async{
  try{
    isNotificationSound == true ? _startForegroundTask() : null;

    isClosed ? await _service.pauseListening() : null;  

  } catch(e) {
    _startForegroundTask();
    
    try{
      await _service.resumeListening();
    } catch(e) {
      print(e);
    }
  }
  
}

//add task via voice...........................................................................................
addVoiceTask() async{
  try{

    //no of task
    await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
    .collection("taskLength").doc('task').update({
      globalCategory: FieldValue.increment(1),
    });
    
    Todo t = Todo(id: 0, title: '', description: '', isCompleted: false, time: '', days: '', date1: '', date2: '', category: '');

    List<int> date = [1, 2, 3, 4, 5, 6, 7];
    List<String> days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

    String hourstext = timeController.text.toString().substring(0, 2);
    String minutestext = timeController.text.toString().substring(3, 5);   

    setState(() {
      t.id = Random().nextInt(2147483637);
      t.title = titleController.text;
      t.description = descriptionController.text;
      t.time = timeController.text;
      t.category = globalCategory;
      t.date1 = DateTime.now().toString();
      t.date2 = DateTime.now().toString().substring(0, 10);
      t.days = date.toString().replaceAll('[', '').replaceAll(']', '');
    });

    //setting scheduled notification                           
    NotificationApi.showScheduledNotification(
      id: t.id,
      title: titleController.text,
      body: descriptionController.text,
      payload: descriptionController.text,
      hh:  int.parse(hourstext),
      mm: int.parse(minutestext),
      ss: int.parse("00"),
      days: date,
      date: DateTime.parse(t.date1)
    );


    try{
      await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
      .collection("backup").doc(t.id.toString()).set({
        'title': titleController.text,
        'description': descriptionController.text,
        'time': timeController.text,
        'category': globalCategory,
        'date': date.toString(),
        'days': days.toString().replaceAll('[', '').replaceAll(']', ''),
        'id': t.id,
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

    setState(() {
      todos.add(t);
    });
    
    saveTodo();
  }catch(e) {
    Fluttertoast.showToast(  
    msg: 'Unable to backup data, no network connection..!',  
    toastLength: Toast.LENGTH_LONG,  
    gravity: ToastGravity.BOTTOM,  
    backgroundColor: Colors.red, 
    textColor: Colors.white);   
  }  

}


//foreground task.................................................................................................
  Future<bool> _startForegroundTask() async {
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted =
          await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        debugPrint('SYSTEM_ALERT_WINDOW permission denied!');
        return false;
      }
    }

    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    bool reqResult;
    if (await FlutterForegroundTask.isRunningService) {
      reqResult = await FlutterForegroundTask.restartService();
    } else {
      reqResult = await FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }

    ReceivePort? receivePort;
    if (reqResult) {
      receivePort = await FlutterForegroundTask.receivePort;
    }

    return _registerReceivePort(receivePort);
  }

  Future<bool> _stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? receivePort) {
    closeReceivePort();

    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) {
        if (message is int) {
          debugPrint('eventCount: $message');
        } else if (message is String) {
          if (message == 'onNotificationPressed') {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> HidenDrawer(animationtime: 0.8,)));
          }
        } else if (message is DateTime) {
          debugPrint('timestamp: ${message.toString()}');
        }
      });

      return true;
    }

    return false;
  }

  void closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

//................................................................................................................

  @override
  Widget build(BuildContext context) {
  var we = MediaQuery.of(context).size.width;
  var he = MediaQuery.of(context).size.height;

  return Scaffold(
    bottomSheet: isEnable ? Container(
      padding: EdgeInsets.only(bottom: 10, right: 100),
      alignment: Alignment.bottomLeft,
      color:  Theme.of(context).scaffoldBackgroundColor,
      height: 50,
      child:   Row(mainAxisAlignment: MainAxisAlignment.start,
    children: [
    AvatarGlow(
    animate: _isListening,
    endRadius: 35,
    glowColor: Color.fromARGB(255, 255, 17, 1),
    child: GestureDetector(
    // onLongPress: () => stop(),
    child:  FloatingActionButton(
    backgroundColor: _isListening ? Colors.greenAccent : Colors.blue,
    child: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 20),
    onPressed: () => !_isListening ? start() : stop()    
    ),
    )),  
    Container(
    width: 100,
    height: 300,
    child: Text(transcription, 
    style: TextStyle(fontSize: 10.0, color: Theme.of(context).hintColor, fontFamily: 'BrandonLI'))
    ),
    ],),
    ) : null,
    floatingActionButton: GestureDetector(
    onLongPress: () => Navigator.push(
      context, MaterialPageRoute(builder: (context) => commands())),
    child: FloatingActionButton(onPressed: (){
      addTodo();
    },
    backgroundColor: Color.fromARGB(255, 255, 178, 89),
    child: Icon(FontAwesomeIcons.plus, color: Colors.white, ),
    )),

    appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: IconButton(
                icon:  Icon(
                  FontAwesomeIcons.bars,size: 25,
                  color: Theme.of(context).hintColor, // Change Custom Drawer Icon Color
                ),
                onPressed: widget.opendrawer
                ),
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
          }
          }, 
          icon: Icon(isDark == true ? Icons.dark_mode_outlined
          : Icons.light_mode_outlined, color: Theme.of(context).hintColor,))
        ],
        elevation: 0.0,
        centerTitle: true,
      ),
      
      backgroundColor:  Theme.of(context).scaffoldBackgroundColor,

      body: WithForegroundTask(
      child:
      ListView(children: [
                    isEnable == true ?
                    Padding(padding: EdgeInsets.only(left: 5),
                    child: Text(listeningText,
                    style: TextStyle(
                    color: Colors.grey.withOpacity(0.8),
                    fontSize: 13)))
                    : Text(""),

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
                                Colors.red.withOpacity(0.6), todos.where((c) => c.category == "Sports").length),
                            _buildCategories(context, "Education",
                                Colors.green.withOpacity(0.6), todos.where((c) => c.category == "Education").length),
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
                                        child: isDark == true ?
                                        FadeAnimation(
                                        delay: 1,
                                        child: Image.asset(
                                          "assets/gif/ghost3.gif",
                                          width: 300,
                                          height: 300,
                                        ))                                        
                                        : FadeAnimation(
                                        delay: 1,
                                        child: Image.asset(
                                          "assets/gif/ghost1.gif",
                                          width: 300,
                                          height: 300,
                                        )),
                                      )
    : Padding(padding: EdgeInsets.only(left: 10),
    child: FadeAnimation(
          delay: widget.animationtime,
          child: ListView.builder(
            itemCount: todos.length,
            itemBuilder:
            (BuildContext context, int index) {
             // ignore: non_constant_identifier_names

              return isCategory == true ? 

              catName == todos[index].category ?

              Slidable(
              endActionPane: ActionPane(
              motion: const StretchMotion(),
              children: [
              SlidableAction(
              onPressed: (context) async{
              int isZero = 0;
              try{
                await collectionReference.collection("Users").doc(user!.email!)
                .collection("taskLength").doc('task').get()
                .then((snapshot) {
                  setState(() {
                    isZero = snapshot.get(todos[index].category);                
                  });
                });
              } catch(e) {
                debugPrint("error");
              }
              if (isZero >= 0) {
               try{
                //no of task
                await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
                .collection("taskLength").doc("task").update({
                  todos[index].category: FieldValue.increment(-1),
                });

              delete(todos[index]);

              } catch(e) {
                Fluttertoast.showToast(  
                msg: 'No network..!',  
                toastLength: Toast.LENGTH_LONG,  
                gravity: ToastGravity.BOTTOM,  
                backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                textColor: Colors.white); 
              } 
                              
              } else {
                Fluttertoast.showToast(  
                msg: 'Please be patient..!',  
                toastLength: Toast.LENGTH_LONG,  
                gravity: ToastGravity.BOTTOM,  
                backgroundColor: Color.fromARGB(255, 255, 178, 89),  
                textColor: Colors.white); 
              }

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
                addTask(todo: todos[index], isEdit: true,)));
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

              : Text("", style: TextStyle(fontSize: 0.1))

              : Slidable(
              endActionPane: ActionPane(
              motion: const StretchMotion(),
              children: [
              SlidableAction(
              onPressed: (context) async{
              int isZero = 0;
              try{
                await collectionReference.collection("Users").doc(user!.email!)
                .collection("taskLength").doc('task').get()
                .then((snapshot) {
                  setState(() {
                    isZero = snapshot.get(todos[index].category);                
                  });
                });
                } catch(e) {
                  debugPrint("error");
                }
                if (isZero > 0) {
                  delete(todos[index]);      
                } else {
                  Fluttertoast.showToast(  
                  msg: 'Please be patient..!',  
                  toastLength: Toast.LENGTH_LONG,  
                  gravity: ToastGravity.BOTTOM,  
                  backgroundColor: Color.fromARGB(255, 255, 178, 89),  
                  textColor: Colors.white); 
                }   
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
                addTask(todo: todos[index], isEdit:  true,)));
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
        )),
    ])));
  }

//build category...........................................................................................
  Widget _buildCategories(context, String title, Color lineProgress, int numbertask) {
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;

    return StreamBuilder(
    stream: FirebaseFirestore.instance.collection("Users").doc(user!.email!)
    .collection("taskLength").doc('task').snapshots(),
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    if (!snapshot.hasData) { 
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
                    length: 1000000000,
                    value: numbertask.toDouble(),
                    Color: lineProgress,
                  )),
            ],
          ),
        ),
      ));
    } else {
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
                    length: numbertask.toDouble(),
                    value: numbertask.toDouble() - snapshot.data[title].toDouble(),
                    Color: lineProgress,
                  )),
            ],
          ),
        ),
      ));
    }});
  }

//get value from addTask...................................................................................
  addTodo() async {
    int id = Random().nextInt(2147483637);
    Todo t = Todo(id: id, title: '', description: '', isCompleted: false, time: '', days: '', date1: '', date2: '', category: '');
    Todo returnTodo = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => addTask(todo: t, isEdit: false,)));
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
    if (todo.category == "Work") {
      color = const Color(0xFFAC05FF);
    } else if (todo.category == "Personal") {
      color = const Color(0xFF0011FF);
    } else if (todo.category == "Sports") {
      color = Colors.red;
    } else if (todo.category == "Education") {
      color = Colors.green;
    } else if (todo.category == "Medical") {
      color = Colors.yellow;
    } else if (todo.category == "Others") {
      color = Color.fromARGB(255, 50, 239, 253);
    } 
    var we = MediaQuery.of(context).size.width;
    var he = MediaQuery.of(context).size.height;

    return GestureDetector(
    onTap: () => detailTask(todo),
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
                    int isZero = 0;
                    try{
                      await collectionReference.collection("Users").doc(user!.email!)
                      .collection("taskLength").doc('task').get()
                      .then((snapshot) {
                        setState(() {
                          isZero = snapshot.get(todos[index].category);   
                        });
                      });
                    } catch(e) {
                      debugPrint("error");
                    }

                    if (!todo.isCompleted) {
                     if (isZero >= 0) {
                     try{
                        //no of task
                        await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
                          .collection("taskLength").doc("task").update({
                          todo.category: FieldValue.increment(-1),
                        });

                      setState(() {
                        todo.isCompleted = true;
                      });
                      await flutterLocalNotificationsPlugin.cancel(todo.id);

                      } catch(e) {
                        Fluttertoast.showToast(  
                        msg: 'No network..!',  
                        toastLength: Toast.LENGTH_LONG,  
                        gravity: ToastGravity.BOTTOM,  
                        backgroundColor: Color.fromARGB(255, 248, 17, 0),  
                        textColor: Colors.white); 
                      }
                      } else {
                        Fluttertoast.showToast(  
                        msg: 'Please be patient..!',  
                        toastLength: Toast.LENGTH_LONG,  
                        gravity: ToastGravity.BOTTOM,  
                        backgroundColor: Color.fromARGB(255, 255, 178, 89),  
                        textColor: Colors.white); 
                      }
                    } else {
                    int isZero = 0;

                    try{
                      await collectionReference.collection("Users").doc(user!.email!)
                      .collection("taskLength").doc('task').get()
                      .then((snapshot) {
                        setState(() {
                          isZero = snapshot.get(todos[index].category);                
                        });
                      });
                    } catch(e) {
                      debugPrint("error");
                    }
                     
                     try{
                        //no of task
                        if(isZero > todos.where((c) => c.category == todo.category).length) {

                          Fluttertoast.showToast(  
                          msg: 'Please be patient..!',  
                          toastLength: Toast.LENGTH_LONG,  
                          gravity: ToastGravity.BOTTOM,  
                          backgroundColor: Color.fromARGB(255, 255, 178, 89),  
                          textColor: Colors.white); 

                        } else {
                          await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
                            .collection("taskLength").doc("task").update({
                            todo.category: FieldValue.increment(1),
                          });

                          setState(() {
                            todo.isCompleted = false;
                          });

                          String hours = todo.time.toString().substring(0, 2);
                          String minutes = todo.time.toString().substring(3, 5);   
                          List<int> date = [1, 2, 3, 4, 5, 6, 7];

                          NotificationApi.showScheduledNotification(
                          id: todo.id,
                          title: todo.title,
                          body: todo.description,
                          payload: todo.description,
                          hh:  int.parse(hours),
                          mm: int.parse(minutes),
                          ss: int.parse("00"),
                          days: date,
                          date: DateTime.parse(todo.date1)
                        );

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
              child: Text(todo.title,
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
    ));
}

//detailed view.......................................................................................................
  detailTask(Todo todo) {
    return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(todo.title,textAlign: TextAlign.left,
              style: TextStyle(color: Theme.of(context).hintColor, fontFamily: 'BrandonBI', fontSize: 30)),
              content: Text("Description: " + todo.description + "\nReminder time: " + todo.time
              + "\nCategory: " + todo.category + "\nDays: " + todo.days + "\nDate: " + todo.date2, textAlign: TextAlign.left,
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
                    onPressed: () async{
                      try{
                      //no of task
                      await FirebaseFirestore.instance.collection("Users").doc(user!.email!)
                      .collection("taskLength").doc("task").update({
                        todo.category: FieldValue.increment(-1),
                      });
                      setState(() {
                        todos.remove(todo);
                      });
                      try{
                         await flutterLocalNotificationsPlugin.cancel(todo.id);
                      } catch(e){
                        debugPrint(e.toString());
                      }
                     
                      Fluttertoast.showToast(  
                      msg: 'Task deleted..!',  
                      toastLength: Toast.LENGTH_LONG,  
                      gravity: ToastGravity.BOTTOM,  
                      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
                      textColor: Colors.white);                               
                      Navigator.pop(ctx);
                      saveTodo();

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

// comment code.....................................................................................................
//alan voice commands...............................................................................................

//   handleCmd(Map<String, dynamic> res) async{
//     int id = Random().nextInt(2147483637);
//     Todo t = Todo(id: id, title: '', description: '', isCompleted: false, time: '', category: '');
//     switch (res["command"]) {
//       case "Add Task":
//         addTodo();
//         print('Opening');
//         break;

//       case "Previous":
//         Navigator.of(context).pop();
//         print('previous');
//         break;

//       case "Go back":
//         Navigator.of(context).pop();
//         print('Go back');
//         break;

//       case "HomePage":
//         Navigator.push(
//             context, MaterialPageRoute(builder: (context) => HidenDrawer(animationtime: 0.8,)));
//         print('Opening');
//         break;

//       case "Open profile":
//         print('Open profile');
//         Navigator.push(
//           context, MaterialPageRoute(builder: (context) => profileUpdates()));;
//         break;

//       case "Open theme":
//         print('Open theme');
//         Navigator.push(
//           context, MaterialPageRoute(builder: (context) => themeSelect()));
//         break;

//       case "Open backup":
//         print('Open backup');
//         Navigator.push(
//           context, MaterialPageRoute(builder: (context) => backupTask()));;
//         break;

//       case "Disable notification sound":
//         print('Disable notification sound');
//         SharedPreferences prefs = await SharedPreferences.getInstance(); 
//         await prefs.setBool('isNotificationSound', false);
//         setState(() {
//           isNotificationSound = false;
//         });
//         //print("######################################$isNotificationSound");
//         break;

//       case "Enable notification sound":
//         print('Enable notification sound');
//         SharedPreferences prefs = await SharedPreferences.getInstance(); 
//         await prefs.setBool('isNotificationSound', true);
//         setState(() {
//           isNotificationSound = true;
//         });           
//         //print("######################################$isNotificationSound");
//         break;        
//       //add task.......................................................
//       case "getTitle":
//         titleController.text = res["text"];
//         currentState.title = titleController.text;
//         setVisuals();
//         print('Tell me the title');
//         break;

//       case "Description":
//         descriptionController.text = res["text"];
//         currentState.description = descriptionController.text;
//         setVisuals();
//         print('Tell me the description');
//         break;

//       case "Hours":
//         hoursText = res["text"];
//         currentState.hours = hoursText;
//         setVisuals();        
//         print('Tell me the hours');
//         break;

//       case "Minutes":
//         minutesText = res["text"];
//         currentState.minutes = minutesText;
//         setVisuals();         
//         print('Tell me the minutes');
//         break;

//  //category.......................................................       
//       case "Work":
//         print('Selecting Work');
//         addTaskState(todo: t, isEdit: false).getCategory('Work');
//         break;

//       case "Personal":
//         print('Selecting Personal');
//         addTaskState(todo: t, isEdit: false).getCategory('Personal');
//         break;

//       case "Sports":
//         print('Selecting Sports');
//         addTaskState(todo: t, isEdit: false).getCategory('Sports');
//         break;

//       case "Education":
//         print('Selecting Education');
//         addTaskState(todo: t, isEdit: false).getCategory('Education');
//         break;

//       case "Medical":
//         print('Selecting Medical');
//         addTaskState(todo: t, isEdit: false).getCategory('Medical');
//         break;

//       case "Others":
//         print('Selecting Others');
//         addTaskState(todo: t, isEdit: false).getCategory('Others');
//         break;

//       case "Save task":
//         print('Saving task');
//         addVoiceTask();
//         break;

//       default:
//         print("Command not found");
//         break;
//     }
//   }

//   //Alan button..................................................................................................
//   setUpalan() {
//    setState(() {
//       isAlanActive = true;
//     });
//     AlanVoice.addButton("4ce15c488ee34010696168ed2b4dade32e956eca572e1d8b807a3e2338fdd0dc/stage",
//         buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT,
//         bottomMargin: 100);
//     AlanVoice.callbacks.add((command) => handleCmd(command.data));
//   }


  // _onBackgroundFetch() async {
  //   initPlatformState();
  //   flutterTts.speak('[BackgroundFetch] started: ');
  //   BackgroundFetch.finish;
  // }  

  // void _onClickEnable(enabled) {
  //   setState(() {
  //     _enabled = enabled;
  //   });
  //   if (enabled) {
  //     BackgroundFetch.start().then((int status) {
  //       print('[BackgroundFetch] start success: $status');
  //     }).catchError((e) {
  //       print('[BackgroundFetch] start FAILURE: $e');
  //     });
  //   } else {
  //     BackgroundFetch.stop().then((int status) {
  //       print('[BackgroundFetch] stop success: $status');
  //     });
  //   }
  // }



