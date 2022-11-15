import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();
  static final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();
  static FlutterTts flutterTts = FlutterTts();

//scheduled notification.....................................................................................
static void showScheduledNotification({
 int id = 0,
 String? title,
 String? body,
 String? payload,
 int? hh,
 int? mm,
 int? ss,
 List<int>? date,
required DateTime scheduledDate,
}) async =>
_notifications.zonedSchedule(
  id,
  title,
  body,
 //_scheduleDaily(Time(hh!, mm!, ss!)), 
  _scheduleWeekly(hh!, mm!, ss!, days: date!),
  await _notificationDetails(),
  payload : payload,
  androidAllowWhileIdle : true,
  uiLocalNotificationDateInterpretation :
      UILocalNotificationDateInterpretation.absoluteTime,
  matchDateTimeComponents : DateTimeComponents.dayOfWeekAndTime,
);

//schedule notification weekly...................................................................................
static tz.TZDateTime _scheduleWeekly(int hh, mm, ss, {required List<int> days}) {
    tz.TZDateTime scheduleDate= _scheduleDaily(hh, mm, ss);

    while (!days.contains(scheduleDate.weekday)){
      scheduleDate = scheduleDate.add(Duration(days: 1));
    }
    return scheduleDate;
}

//show notification daily.........................................................................................
static tz.TZDateTime _scheduleDaily(int hh, mm, ss) {
  final now = tz.TZDateTime.now (tz.local);
  final scheduledDate = tz.TZDateTime (
    tz.local,
    now.year,
    now.month,
    now.day,
    hh, mm , ss);

return scheduledDate.isBefore(now)
    ? scheduledDate.add(Duration(days: 1))
    : scheduledDate;
}

//notification details............................................................................................
static Future _notificationDetails() async {
  return NotificationDetails(
    android: AndroidNotificationDetails(
      'channel id',
      'channel name',
      //'channel description',
      importance : Importance.max ,
    ), // AndroidNotificationDetails
    iOS : DarwinNotificationDetails(),
  ) ; // NotificationDetails
}

//initialize notification.........................................................................................
static Future init ({bool initScheduled = false}) async {
 final android = AndroidInitializationSettings('@mipmap/ic_launcher');
 final iOS = DarwinInitializationSettings ();
 final settings = InitializationSettings(android: android, iOS: iOS);

 await _notifications.initialize(
    settings,
    onDidReceiveNotificationResponse: (details) async {
      //await flutterTts.speak("details.payload.toString()");
      selectNotificationStream.add(details.payload.toString());
    },

  );

  if (initScheduled) {
    tz.initializeTimeZones();
    final locationName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(locationName));

  }
}
                    
//show sudden notification based on duration......................................................................
static Future showNotification({
  int id = 0,
  String? title,
  String? body,
  String? payload,
})async =>
    _notifications.show(
      id ,
      title ,
      body ,
      await _notificationDetails(),
      payload : payload, 
    );
}                
