import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'dart:isolate';
import 'dart:convert';
import 'package:todoalan/AI/leopard_manager.dart';
import 'package:todoalan/main.dart';
// import 'package:todoalan/AI/AI.dart';
import 'package:flutter/material.dart';
import 'package:todoalan/AI/AI/API.dart';
import 'package:rhino_flutter/rhino.dart';
import 'package:todoalan/AI/AI/utils.dart';
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todoalan/themeSelect/themeSelect.dart';
import 'package:todoalan/Animation/fadeAnimation.dart';
import 'package:todoalan/Animation/linearprogress.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:picovoice_flutter/picovoice_error.dart';
import 'package:picovoice_flutter/picovoice_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todoalan/homescreen/Drawerhiden/hidendrawer.dart';
import 'package:todoalan/NotificationClass/notificationClass.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:leopard_flutter/leopard.dart';
import 'package:leopard_flutter/leopard_error.dart';
import 'package:leopard_flutter/leopard_transcript.dart';

//global variables................................................................................................

//for main.dart
  late bool? isDark;
  late bool? isNotificationSound;
  late int? NavBartheme;
  late List<Color> navColor;
  

//for AI
  // String current_page = 'homepage';
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
  bool isTitle = true;

  final collectionReference = FirebaseFirestore.instance;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin
   = FlutterLocalNotificationsPlugin(); //creating an instace of flutter notification plugin
   

  //picovoice local variables
  PicovoiceManager? _picovoiceManager;
  bool _listeningForCommand = false;
  bool _isError = false;
  String _errorMessage = "";
  final String accessKey = "poVLzViS1LMJSHkQraFrV1dzdgN2TWLlMqs9u2cVi4LUKzFsq1XKtw==";

  //leopard local variables
  bool isError = false;
  String errorMessage = "";
  final int maxRecordingLengthSecs = 120;
  bool isRecording = false;
  bool isProcessing = false;
  double recordedLength = 0.0;
  String statusAreaText = "";
  String transcriptText = "";
  List<LeopardWord> words = [];

  MicRecorder? _micRecorder;
  Leopard? _leopard;

//picovoice initilize...................................................................................................
  void _initPicovoice() async {
    String platform = Platform.isAndroid
        ? "android"
        : Platform.isIOS
            ? "ios"
            : throw PicovoiceRuntimeException(
                "This demo supports iOS and Android only.");
    String keywordAsset = "assets/pico_voice/hey-evoke_en_android_v2_1_0.ppn";
    String contextAsset = "assets/pico_voice/Evoke_en_android_v2_1_0.rhn";

    try {
      _picovoiceManager = await PicovoiceManager.create(accessKey, keywordAsset,
          _wakeWordCallback, contextAsset, _inferenceCallback,
          processErrorCallback: _errorCallback);
      await _picovoiceManager?.start();
    } on PicovoiceInvalidArgumentException catch (ex) {
      _errorCallback(PicovoiceInvalidArgumentException(
          "${ex.message}\nEnsure your accessKey '$accessKey' is a valid access key."));
    } on PicovoiceActivationException {
      _errorCallback(
          PicovoiceActivationException("AccessKey activation error."));
    } on PicovoiceActivationLimitException {
      _errorCallback(PicovoiceActivationLimitException(
          "AccessKey reached its device limit."));
    } on PicovoiceActivationRefusedException {
      _errorCallback(PicovoiceActivationRefusedException("AccessKey refused."));
    } on PicovoiceActivationThrottledException {
      _errorCallback(PicovoiceActivationThrottledException(
          "AccessKey has been throttled."));
    } on PicovoiceException catch (ex) {
      _errorCallback(ex);
    }
  }

    void _wakeWordCallback() {
      setState(() {
        _listeningForCommand = true;
      });
    }

  void _inferenceCallback(RhinoInference inference) {  
    if (inference.isUnderstood!) {
      Map<String, String> slots = inference.slots!;
      if (inference.intent == 'Navigation') {
        _navigate(slots);
      } else if (inference.intent == 'addtask') {
        _task(slots);
      } 
      else if (inference.intent == 'setTime') {
        _setTime(slots);
      }

    } else {
        flutterTts.speak("Sorry I didn't understand that command!");
        
        Fluttertoast.showToast(  
        msg: "Sorry I didn't understand that command..!",  
        toastLength: Toast.LENGTH_LONG,  
        gravity: ToastGravity.BOTTOM,  
        backgroundColor: Color.fromARGB(255, 255, 178, 89),  
        textColor: Colors.white); 
     
    }
    setState(() {
      _listeningForCommand = false;
    });
  }

  //task
  _task(Map<String, String> slots){
    if (slots['category'] == 'Work') {
      flutterTts.speak("Setting category as Work");

      Fluttertoast.showToast(  
      msg: 'Setting category as Work..!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
      textColor: Colors.white); 
     
      setState(() {
        globalCategory = 'Work';
      });

    } else if (slots['category'] == 'Personal') {
      flutterTts.speak("Setting category as Personal");

      Fluttertoast.showToast(  
      msg: 'Setting category as Personal..!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
      textColor: Colors.white); 
     
      setState(() {
        globalCategory = 'Personal';
      });
      
    } else if (slots['category'] == 'Sports') {
      flutterTts.speak("Setting category as Sports");

      Fluttertoast.showToast(  
      msg: 'Setting category as Sports..!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
      textColor: Colors.white); 
     
      setState(() {
        globalCategory = 'Sports';
      });
      
    } else if (slots['category'] == 'Education') {
      flutterTts.speak("Setting category as Education");

      Fluttertoast.showToast(  
      msg: 'Setting category as Education..!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
      textColor: Colors.white); 
     
      setState(() {
        globalCategory = 'Education';
      });

    } else if (slots['category'] == 'Medical') {
      flutterTts.speak("Setting category as Medical");

      Fluttertoast.showToast(  
      msg: 'Setting category as Medical..!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
      textColor: Colors.white); 
     
      setState(() {
        globalCategory = 'Medical';
      });
      
    } else if (slots['category'] == 'Others') {
      flutterTts.speak("Setting category as Others");

      Fluttertoast.showToast(  
      msg: 'Setting category as Others..!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
      textColor: Colors.white); 

      setState(() {
        globalCategory = 'Others';
      });
      
    } else if (slots['editTask'] == 'title') {
      flutterTts.speak("Please tell me the title");

      Fluttertoast.showToast(  
      msg: 'Please tell me the title..!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
      textColor: Colors.white); 

      setState(() {
        // _listeningForCommand = false;
        isEnable = true;
        isTitle = true;
      });
      _picovoiceManager?.stop();

    } else if (slots['editTask'] == 'description') {
      flutterTts.speak("Please tell me the description");

      Fluttertoast.showToast(  
      msg: 'Please tell me the description..!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
      textColor: Colors.white); 

      setState(() {
        // _listeningForCommand = false;
        isEnable = true;
        isTitle = false;
      });
      _picovoiceManager?.stop();     
    } else if (slots['save'] == 'save') {
      flutterTts.speak("saving task");

      Fluttertoast.showToast(  
      msg: 'Saving task..!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
      textColor: Colors.white); 

      addVoiceTask();

      Future.delayed(Duration(seconds: 5,), (){
        AISpeak.speak("please restart app to see new task"); 

        Fluttertoast.showToast(  
        msg: 'Please restart app to see new task..!',  
        toastLength: Toast.LENGTH_LONG,  
        gravity: ToastGravity.BOTTOM,  
        backgroundColor: Color.fromARGB(255, 255, 178, 89),  
        textColor: Colors.white); 

    });

    }
  }

  //time
  _setTime(Map<String, String> slots) {
    int hour = 0;
    int minute = 0;

    if (slots['hours'] != null) {
      setState(() {
        hour = int.parse(slots['hours']!);
      });
      
      if (hour == 12) setState(() {hour = 0; });
    }
    if (slots['minutes'] != null) {
      setState(() {
        minute = int.parse(slots['minutes']!);
      });
      
    }

    if (slots['amPm'] == "pm") setState(() {hour += 12; });

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
    flutterTts.speak("setting time $hour:$minute.");     

    setState(() {
      timeController.text = hour.toString() + ":" + minute.toString();
    });
    
    Fluttertoast.showToast(  
    msg: 'Setting time $hour:$minute....!',  
    toastLength: Toast.LENGTH_LONG,  
    gravity: ToastGravity.BOTTOM,  
    backgroundColor: Color.fromARGB(255, 255, 178, 89),  
    textColor: Colors.white); 

    });
  }

  //navigation
  _navigate(Map<String, String> slots){
    if (slots['navigation'] == 'backup') {
      flutterTts.speak("Opening backup page");

      Fluttertoast.showToast(  
      msg: 'Opening backup page...!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
      textColor: Colors.white); 

      Navigator.push(
      context, MaterialPageRoute(builder: (context) => backupTask()));

    } else if (slots['navigation'] == 'homepage') {
      flutterTts.speak("Opening homepage");

      Fluttertoast.showToast(  
      msg: 'Opening homepage...!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
      textColor: Colors.white); 

      Navigator.push(
      context, MaterialPageRoute(builder: (context) => HidenDrawer(animationtime: 0.8,)));
      
    } else if (slots['navigation'] == 'theme') {
      flutterTts.speak("Opening theme page");

      Fluttertoast.showToast(  
      msg: 'Opening theme page...!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
      textColor: Colors.white); 

      Navigator.push(
      context, MaterialPageRoute(builder: (context) => themeSelect()));

    } else if (slots['navigation'] == 'profile') {
      flutterTts.speak("Opening profile page");

      Fluttertoast.showToast(  
      msg: 'Opening profile page...!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
      textColor: Colors.white); 

      Navigator.push(
      context, MaterialPageRoute(builder: (context) => profileUpdates()));

    } else if (slots['back'] == 'back') {
      flutterTts.speak("Going back");

      Fluttertoast.showToast(  
      msg: 'Going back...!',  
      toastLength: Toast.LENGTH_LONG,  
      gravity: ToastGravity.BOTTOM,  
      backgroundColor: Color.fromARGB(255, 255, 178, 89),  
      textColor: Colors.white); 

      Navigator.of(context).pop();

    }
  }

    void _errorCallback(PicovoiceException error) {
      setState(() {
        _isError = true;
        _errorMessage = error.message!;
      });
    }

//initializing leopard.................................................................................................
  Future<void> initLeopard() async {
    String platform = Platform.isAndroid
        ? "android"
        : Platform.isIOS
            ? "ios"
            : throw LeopardRuntimeException(
                "This demo supports iOS and Android only.");
    String modelPath = "assets/pico_voice/Evoke--leopard-v1.1.0--22-11-08--07-38-33.pv";

    try {
      _leopard = await Leopard.create(accessKey, modelPath,
          enableAutomaticPunctuation: true);
      _micRecorder = await MicRecorder.create(
          _leopard!.sampleRate, recordedCallback, errorCallback);
    } on LeopardInvalidArgumentException catch (ex) {
      errorCallback(LeopardInvalidArgumentException(
          "${ex.message}\nEnsure your accessKey '$accessKey' is a valid access key."));
    } on LeopardActivationException {
      errorCallback(LeopardActivationException("AccessKey activation error."));
    } on LeopardActivationLimitException {
      errorCallback(LeopardActivationLimitException(
          "AccessKey reached its device limit."));
    } on LeopardActivationRefusedException {
      errorCallback(LeopardActivationRefusedException("AccessKey refused."));
    } on LeopardActivationThrottledException {
      errorCallback(
          LeopardActivationThrottledException("AccessKey has been throttled."));
    } on LeopardException catch (ex) {
      errorCallback(ex);
    }
  }

  Future<void> recordedCallback(double length) async {
    if (length < maxRecordingLengthSecs) {
      setState(() {
        recordedLength = length;
        statusAreaText =
            "Recording : ${length.toStringAsFixed(1)} / $maxRecordingLengthSecs seconds";
      });
    } else {
      setState(() {
        recordedLength = length;
        statusAreaText = "Transcribing, please wait...";
      });
      await _stopRecording();
    }
  }

  void errorCallback(LeopardException error) {
    setState(() {
      isError = true;
      errorMessage = error.message!;
    });
  }

  Future<void> _startRecording() async {
    if (isRecording || _micRecorder == null) {
      return;
    }

    try {
      await _micRecorder!.startRecord();
      setState(() {
        isRecording = true;
      });
    } on LeopardException catch (ex) {
      print("Failed to start audio capture: ${ex.message}");
    }
  }

  Future<void> _stopRecording() async {
    if (!isRecording || _micRecorder == null) {
      return;
    }

    try {
      File recordedFile = await _micRecorder!.stopRecord();
      setState(() {
        statusAreaText = "Transcribing, please wait...";
        isRecording = false;
      });
      _processAudio(recordedFile);
    } on LeopardException catch (ex) {
      print("Failed to stop audio capture: ${ex.message}");
    }
  }

  Future<void> _processAudio(File recordedFile) async {
    if (_leopard == null) {
      return;
    }

    Stopwatch stopwatch = Stopwatch()..start();
    LeopardTranscript? result = await _leopard?.processFile(recordedFile.path);
    Duration elapsed = stopwatch.elapsed;

    String audioLength = recordedLength.toStringAsFixed(1);
    String transcriptionTime =
        (elapsed.inMilliseconds / 1000).toStringAsFixed(1);

    setState(() {
      statusAreaText =
          "Transcribed $audioLength(s) of audio in $transcriptionTime(s)";
      transcriptText = result?.transcript ?? "";
      isTitle ? titleController.text = result?.transcript ?? ""
      : descriptionController.text = result?.transcript ?? "";
      words = result?.words ?? [];
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
           isEnable = false;
        }); 

        Fluttertoast.showToast(  
        msg: 'title is $transcriptText',  
        toastLength: Toast.LENGTH_LONG,  
        gravity: ToastGravity.BOTTOM,  
        backgroundColor: Color.fromARGB(255, 255, 178, 89),  
        textColor: Colors.white); 

        _picovoiceManager?.start();

      });
      
    });
  }


//initializing todo.................................................................................................
  setupTodo() async {
    prefs = await SharedPreferences.getInstance();
    String? stringTodo = prefs!.getString(user!.email!);
    List todoList = jsonDecode(stringTodo!);

    for (var todo in todoList) {
      setState(() {
        todos.add(Todo(description: '', id: 1, isCompleted: false, time: '', title: '', days: '', category: '').fromJson(todo));
      });
    }
  }

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

    _initPicovoice();

    setState(() {
      recordedLength = 0.0;
      statusAreaText =
          "Press START to start recording some audio to transcribe";
      transcriptText = "";
      words = [];
    });

    initLeopard();

    super.initState();
  }

  @override
  void dispose() {
  // _closeReceivePort();
  WidgetsBinding.instance!.removeObserver(this);
  _picovoiceManager?.stop();
  _stopRecording();
  super.dispose();
  }

//lsiten to notification..........................................................................................
// void listenNotifications() =>
//             NotificationApi.onNotifications.stream.listen(onClickedNotification);

//   void onClickedNotification(String? payload) async{
//     isNotificationSound == true 
//     ? await flutterTts.speak(payload.toString()) 
//     : debugPrint("################################disabled");
//   } 

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
        // buttons: [
        //   const NotificationButton(id: 'sendButton', text: 'Send'),
        //   const NotificationButton(id: 'testButton', text: 'Test'),
        // ],
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
  super.didChangeAppLifecycleState(state);

  final isBg = state == AppLifecycleState.paused;
  final isClosed = state == AppLifecycleState.detached;
  final isScreen = state == AppLifecycleState.resumed;

  isBg || isScreen == false || isClosed == true
      ? runTask(isClosed)

      : _picovoiceManager?.start();
  }


runTask(bool isClosed) {
  try{
    isNotificationSound == true ? _startForegroundTask() : null;

    // isClosed ? _stopRecording() : null;
    // isClosed ? _picovoiceManager?.stop() : null;

    try{
      _stopRecording();
    } catch(e) {
      print(e);
    }

    try{
      _picovoiceManager?.stop();
    } catch(e) {
      print(e);
    }

  } catch(e) {
    _startForegroundTask();
    
    try{
      _stopRecording();
    } catch(e) {
      print(e);
    }

    try{
      _picovoiceManager?.stop();
    } catch(e) {
      print(e);
    }
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
    animate: isRecording,
    endRadius: 35,
    glowColor: Color.fromARGB(255, 255, 17, 1),
    child: FloatingActionButton(
    backgroundColor: isRecording ? Colors.greenAccent : Colors.blue,
    child: Icon(isRecording ? Icons.mic : Icons.mic_none, size: 20),
    onPressed: isError ? null : isRecording ? _stopRecording : _startRecording,      
      // toggleRecording,
    ),
    ),  
    Container(
    width: 100,
    height: 300,
    child: Text(transcriptText, 
    style: TextStyle(fontSize: 10.0, color: Theme.of(context).hintColor, fontFamily: 'BrandonLI'))
    // SingleChildScrollView(
    // reverse: true,  
    // child:
    // SubstringHighlight(
    // text: text,
    // terms: Command.all,
    // textStyle: TextStyle(fontSize: 10.0, color: Theme.of(context).hintColor, fontFamily: 'BrandonLI'),
    // textStyleHighlight: TextStyle( fontSize: 10.0, color: Colors.red, fontFamily: 'BrandonBI'),
    // ))
    ),
    ],),
    ) : null,
    floatingActionButton: GestureDetector(onLongPress: () { 
      // Permission.microphone;
      // isEnable ?
      // setState(() {
      //   flutterTts.speak("see you again"); 
      //   isEnable = false;
      // }) 
      // : setState(() {
      //   flutterTts.speak("Hey there, I'm here to help you"); 
      //   isEnable = true;
      // });

    },
    child: FloatingActionButton(onPressed: (){
      addTodo();
    },
    backgroundColor: Color.fromARGB(255, 255, 178, 89),
    child: Icon(FontAwesomeIcons.plus, color: Colors.white, ),
    ),),

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
        Text(statusAreaText),
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
              if (isZero > 0) {
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
    Todo t = Todo(id: id, title: '', description: '', isCompleted: false, time: '', days: '', category: '');
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
                     if (isZero > 0) {
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
                      date: date,
                      scheduledDate: DateTime.now().add(Duration(seconds: 10))
                    );
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
              content: Text("Description: " + todo.description + "\n" + "Reminder time: " + todo.time + "\nCategory: " + todo.category + "\nDays: " + todo.days, textAlign: TextAlign.left,
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
 
   Future toggleRecording() => SpeechApi().toggleRecording(
        onResult: (text) => setState(() {
          setState(() {
            isListening = true;
          });
          this.text = text;
          Future.delayed(Duration(milliseconds: 1), () {
            Utils().scanText(text, context);
          });
          Future.delayed(Duration(milliseconds: 10), () {
          setState(() {
            isListening = false;
          });
          });
        }),
        onListening: (isListening) {
          setState(() => this.isListening = isListening);
          // if (!isListening) {
          //   Future.delayed(Duration(seconds: 5), () {
          //     Utils().scanText(text, context);
          //   });
          // }
        },
      );
 
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


//...........................................................................................................
    // onStart() {
    //   WidgetsFlutterBinding.ensureInitialized();
    //   //final service = FlutterBackgroundService();
    //   // Run taks here :
    //   startListening(); 
    //   service.onDataReceived.listen((event) { 
    //     // !IMPORTANT 
    //     // must include print statement to pass null check: 
    //     // other wise you get error: 
    //     print(event!); 
    //     // use Contain key or contain value: 
    //     // for ignore null errors :  
    //     // if (event.containsKey('action')) {  
    //     //   String changer = 'game'; 
    //     //   return; 
    //     // } 
    //     // startListening(); 
    //     service.setNotificationInfo(
    //       title: "Evoke",
    //       content: "Updated at ${DateTime.now()}",
    //     );
    //   });


// //Notification speak...................................................................................................
//   Future<void> initPlatformState() async {
//     startListening();
//   }

//   void onData(NotificationEvent event) {
//     if (event.toString().substring(0, 50) == "NotificationEvent - package: com.alantodo.todoalan")
//     {
//       String message = event.toString();
//       flutterTts.speak(message.substring(50, message.lastIndexOf(",")));
//     } else {
//       debugPrint("error");
//     }
//     // NotificationEvent - package: com.alantodo.todoalan, title: mac, message: aaa, timestamp: 2022-10-29 18:51:01.694027
//      print(event);
//   }

//   void startListening() {
//       _notifications = new Notifications();
//       try {
//         _subscription = _notifications.notificationStream!.listen(onData);
//       } on NotificationException catch (exception) {
//         print(exception);
//       }
//   }


//...........................................................
  // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initPlatformStateForBackground() async {
  //   // Configure BackgroundFetch.
  //   int status = await BackgroundFetch.configure(BackgroundFetchConfig(
  //       minimumFetchInterval: 15,
  //       stopOnTerminate: false,
  //       enableHeadless: true,
  //       requiresBatteryNotLow: false,
  //       requiresCharging: false,
  //       requiresStorageNotLow: false,
  //       requiresDeviceIdle: false,
  //       requiredNetworkType: NetworkType.NONE
  //   ),   (String taskId) async {  // <-- Event handler
  //     // This is the fetch-event callback.
  //     initPlatformState().then((value) => flutterTts.speak('[BackgroundFetch] Headless event received.'));
  //     //flutterTts.speak('[BackgroundFetch] configure success: ');
  //     print("[BackgroundFetch] Event received $taskId");
  //     // setState(() {
  //     //   _events.insert(0, new DateTime.now());
  //     // });
  //     // IMPORTANT:  You must signal completion of your task or the OS can punish your app
  //     // for taking too long in the background.
  //     BackgroundFetch.finish(taskId);
  //   },   
  //   (String taskId) async {  // <-- Task timeout handler.
  //     // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
  //     print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
  //     BackgroundFetch.finish(taskId);
  //   }
  //   );
  //   initPlatformState().then((value) => flutterTts.speak('[BackgroundFetch] Headless event received.'));
  //   print('[BackgroundFetch] configure success: $status');
  //   setState(() {
  //     _status = status;
  //   });        

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;
  // }
 
 //local variables for text to speech ..................................................................................................
  // late Notifications _notifications;
  // late StreamSubscription<NotificationEvent> _subscription;