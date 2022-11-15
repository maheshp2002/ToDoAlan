import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todoalan/login/login.dart';
import 'package:todoalan/splash/splash.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:notifications/notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todoalan/homescreen/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();
  
  runApp(RestartWidget(
  child:  MyApp()));
}

//global variable..........................................................................................
  late var getUserEmail; //to get user email id

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();

/// InheritedWidget style accessor to our State object.
/// We can call this static method from any descendant context to find our
/// State object and switch the themeMode field value & call for a rebuild.
static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}
/// Our State object
class MyAppState extends State<MyApp> {
  /// 1) our themeMode "state" field
  ThemeMode _themeMode = ThemeMode.system;

 @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1), () async{
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    try{
    prefs.getBool('isDark') == true ? changeTheme(ThemeMode.dark) : changeTheme(ThemeMode.light);  
    setState(() {
    isDark = prefs.getBool('isDark');
    NavBartheme = prefs.getInt('NavBartheme') ?? 1; 
    isNotificationSound = prefs.getBool('isNotificationSound') ?? false;
    });
    }catch(e){
      setState(() {
        isDark = false;
        NavBartheme = 1;
        isNotificationSound = false;
      });
    }
    });

    getCurrentUser();
  }

//get current user email..................................................................................
    Future getCurrentUser() async {
    setState(() {
        
    getUserEmail =  FirebaseAuth.instance.currentUser ?? "notSigned";
    });
    return getUserEmail;}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Evoke',
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode, // 2) ← ← ← use "state" field here //////////////
     home: Splash(),
    );
  }

  /// 3) Call this to change theme from any context using "of" accessor
  /// e.g.:
  /// MyApp.of(context).changeTheme(ThemeMode.dark);
void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

}

class MyApp2 extends StatefulWidget {

  @override
  MyApp2State createState() => MyApp2State();
}

class MyApp2State extends State<MyApp2>{
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:  Container(
        decoration: const BoxDecoration(
              gradient: LinearGradient(
               colors: [Color(0xFFfefbe5),Color(0xFFfefbe5),Color.fromARGB(255, 253, 225, 195), Color(0xFFfFe5ca)],
              begin: Alignment.topCenter,
               end: Alignment.bottomCenter,
          )),
      child:
      Column(mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Image.asset("assets/gif/login.gif"),

      SizedBox(height: 10,),
      
      Text("Hey there..!", style: TextStyle(fontSize: 25, fontFamily: 'BrandonBI', color: Colors.grey),),

      SizedBox(height: 10,),

      Center(child: 
      GoogleSignIn(),),

      ],)
      ),
      
    );
  }

}

//restart app......................................................................................................
class RestartWidget extends StatefulWidget {
  RestartWidget({required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    final State<RestartWidget>? state = context.findAncestorStateOfType<State<RestartWidget>>();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

//foreground service........................................................................................................
// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;
    initPlatformState();
    // You can use the getData function to get the stored data.
    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    debugPrint('customData: $customData');
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'Foreground Service is running',
      // notificationText: 'seconds: $_eventCount',
      notificationText: 'Tap to return to the app',
    );

    // Send data to the main isolate.
    sendPort?.send(_eventCount);

    _eventCount++;
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    debugPrint('onButtonPressed >> $id');
  }

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}

//Notification speak...................................................................................................
  Future<void> initPlatformState() async {
    try {
      isNotificationSound == true ? startListening() : null;
    } catch(e) {
      startListening();
    }
  }

  void onData(NotificationEvent event) {
    FlutterTts flutterTtsNotification = FlutterTts();
    
    try{
      if (event.toString().substring(0, 50) == "NotificationEvent - package: com.alantodo.todoalan")
      {
        if (event.toString().substring(0, 78) == 'NotificationEvent - package: com.alantodo.todoalan, title: Foreground service,'
        || event.toString().substring(0, 89) == 'NotificationEvent - package: com.alantodo.todoalan, title: Foreground Service is running,')
        {
          debugPrint("error");
        } else {
          String message = event.toString();
          flutterTtsNotification.speak(message.substring(50, message.lastIndexOf(",")));
        }
      } else {
        debugPrint("error");
      }
      // NotificationEvent - package: com.alantodo.todoalan, title: mac, message: aaa, timestamp: 2022-10-29 18:51:01.694027
      print(event);
    } catch(e) {
      debugPrint(e.toString());
    }
  }

  void startListening() {
      notifications = new Notifications();
      try {
        subscription = notifications.notificationStream!.listen(onData);
      } on NotificationException catch (exception) {
        debugPrint(exception.toString());
      }
  }

  void stopListening() {
    subscription.cancel();
  }

//Theme........................................................................................................
class ThemeClass{
 
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primarySwatch: Colors.blueGrey,
    hintColor: Colors.blueGrey,
    colorScheme: ColorScheme.light(),
    cardColor: Colors.grey.shade200,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blueGrey,
    )
  );
 
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black45,
    primarySwatch: Colors.blueGrey,
    cardColor: Colors.black,
    hintColor: Colors.white60,
    colorScheme: ColorScheme.dark(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
      )
  );
}

//Navbar theme.....................................................
List<Color> colors1 = [Color(0xFFED7B8A), Color(0xFF04123F)];
List<Color> colors2 = [Color(0xFFED7B8A), Color(0xFF9055FF)];
List<Color> colors3 = [Color(0xFF8C04DB), Color(0xFF04123F)];
List<Color> colors4 = [Color(0xFF8C04DB), Color(0xFF2EAAFA)];
List<Color> colors5 = [Color(0xFF8C04DB), Color(0xFFFFCAC9)];
List<Color> colors6 = [Color(0xFF737DEF), Color(0xFFFFCAC9)];
List<Color> colors7 = [Color(0xFF737DEF), Color(0xFF2EAAFA)];
List<Color> colors8 = [Color(0xFF8C04DB), Color(0xFF2EAAFA)];
List<Color> colors9 = [Color(0xFF8C04DB), Color(0xFF04123F)];
List<Color> colors10 = [Color(0xFFEC00BC), Color(0xFFFC6767)];
List<Color> colors11 = [Color(0xFFEC00BC), Color(0xFF04123F)];
List<Color> colors12 = [Color(0xFFECBC), Color(0xFFC9F0E4)];
List<Color> colors13 = [Color(0xFFA0B5EB), Color(0xFF3957ED)];
List<Color> colors14 = [Color(0xFF04123F), Color(0xFF04123F)];

