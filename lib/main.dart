
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoalan/homescreen/homescreen.dart';
import 'package:todoalan/login/login.dart';
import 'package:todoalan/splash/splash.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_background_service/flutter_background_service.dart';



//initialize firebase app during notification.................................................................
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up : ${message.messageId}');
}


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();


  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FlutterBackgroundService.initialize(homepageState().onStart);
  
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



//Comment code.........................................................................................

//import 'package:background_fetch/background_fetch.dart';
//import 'dart:io';
//import 'package:rhino_flutter/rhino.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:picovoice_flutter/picovoice_error.dart';
// import 'package:picovoice_flutter/picovoice_manager.dart';


  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  
  // PicovoiceManager? _picovoiceManager;
  // bool _listeningForCommand = false;
  // bool _isError = false;
  // String _errorMessage = "";
  // final String accessKey = "poVLzViS1LMJSHkQraFrV1dzdgN2TWLlMqs9u2cVi4LUKzFsq1XKtw==";

// //pico voice initilize
//   void _initPicovoice() async {
//     String platform = Platform.isAndroid
//         ? "android"
//         : Platform.isIOS
//             ? "ios"
//             : throw PicovoiceRuntimeException(
//                 "This demo supports iOS and Android only.");
//     String keywordAsset = "assets/$platform/pico clock_$platform.ppn";
//     String contextAsset = "assets/$platform/clock_$platform.rhn";

//     try {
//       _picovoiceManager = await PicovoiceManager.create(accessKey, keywordAsset,
//           _wakeWordCallback, contextAsset, _inferenceCallback,
//           processErrorCallback: _errorCallback);
//       await _picovoiceManager?.start();
//     } on PicovoiceInvalidArgumentException catch (ex) {
//       _errorCallback(PicovoiceInvalidArgumentException(
//           "${ex.message}\nEnsure your accessKey '$accessKey' is a valid access key."));
//     } on PicovoiceActivationException {
//       _errorCallback(
//           PicovoiceActivationException("AccessKey activation error."));
//     } on PicovoiceActivationLimitException {
//       _errorCallback(PicovoiceActivationLimitException(
//           "AccessKey reached its device limit."));
//     } on PicovoiceActivationRefusedException {
//       _errorCallback(PicovoiceActivationRefusedException("AccessKey refused."));
//     } on PicovoiceActivationThrottledException {
//       _errorCallback(PicovoiceActivationThrottledException(
//           "AccessKey has been throttled."));
//     } on PicovoiceException catch (ex) {
//       _errorCallback(ex);
//     }
//   }

//   void _wakeWordCallback() {
//     setState(() {
//       _listeningForCommand = true;
//     });
//   }

// void _inferenceCallback(RhinoInference inference) {  
//   if (inference.isUnderstood!) {
//     Map<String, String> slots = inference.slots!;
//     if (inference.intent == 'navigate') {
//       _navigate(slots);
//     }
//     // } else if (inference.intent == 'timer') {
//     //   _performTimerCommand(slots);
//     // } else if (inference.intent == 'setTimer') {
//     //   _setTimer(slots);
//     // } else if (inference.intent == 'alarm') {
//     //   _performAlarmCommand(slots);
//     // } else if (inference.intent == 'setAlarm') {
//     //   _setAlarm(slots);
//     // } else if (inference.intent == 'stopwatch') {
//     //   _performStopwatchCommand(slots);
//     // } else if (inference.intent == 'availableCommands') {
//     //   _showAvailableCommands();
//     // }
//   } else {
//       Fluttertoast.showToast(
//           msg: "Didn't understand command!\n" +
//               "Say 'PicoClock, what can I say?' to see a list of example commands",
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.TOP,
//           timeInSecForIosWeb: 2,
//           backgroundColor: Color.fromRGBO(55, 125, 255, 1),
//           textColor: Colors.white,
//           fontSize: 16.0);
//   }
//   setState(() {
//     _listeningForCommand = false;
//   });
// }

// _navigate(Map<String, String> slots){

// }

//   void _errorCallback(PicovoiceException error) {
//     setState(() {
//       _isError = true;
//       _errorMessage = error.message!;
//     });
//   }

//..........................................................................................................

// [Android-only] This "Headless Task" is run when the Android app is terminated with `enableHeadless: true`
// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
// @pragma('vm:entry-point')
// void backgroundFetchHeadlessTask(HeadlessTask task) async {
//   String taskId = task.taskId;
//   bool isTimeout = task.timeout;
//   if (isTimeout) {
//     // This task has exceeded its allowed running-time.  
//     // You must stop what you're doing and immediately .finish(taskId)
//     print("[BackgroundFetch] Headless task timed-out: $taskId");
//     BackgroundFetch.finish(taskId);
//     return;
//   }  
//   print('[BackgroundFetch] Headless event received.');
//   // Do your work here...
//   BackgroundFetch.finish(taskId);
// }

//..........................................................................................................