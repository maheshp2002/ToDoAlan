// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;


// class NotificationService {
// static final NotificationService _notificationService =
// 	NotificationService._internal();

// factory NotificationService() {
// 	return _notificationService;
// }

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// 	FlutterLocalNotificationsPlugin();

// NotificationService._internal();

// Future<void> initNotification() async {
// 	var initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//         //var initializationSettingsIOS = IOSInitializationSettings();
//         var initializationSettings = InitializationSettings(
//             android: initializationSettingsAndroid,);
//         flutterLocalNotificationsPlugin.initialize(
//           initializationSettings,
//         );
// // 	// Android initialization
// // 	final AndroidInitializationSettings initializationSettingsAndroid =
// // 		AndroidInitializationSettings('@mipmap/ic_launcher');

// // // IOS initialization
// //   final DarwinInitializationSettings initializationSettingsIOS =
// //     DarwinInitializationSettings(
// //       requestAlertPermission: false,
// //       requestBadgePermission: false,
// //       requestSoundPermission: false,
// //     );


// // 	final InitializationSettings initializationSettings =
// // 		InitializationSettings(
// // 			android: initializationSettingsAndroid,
// // 			iOS: initializationSettingsIOS);
// // 	// the initialization settings are initialized after they are setted
// // 	await flutterLocalNotificationsPlugin.initialize(initializationSettings);
// }

// Future<void> showNotification(int id, String title, String body, int HH, int MM) async {
// 	await flutterLocalNotificationsPlugin.zonedSchedule(
// 	id,
// 	title,
// 	body,
// 	tz.TZDateTime.now(tz.local).add(Duration(hours: HH, minutes: MM,)), //schedule the notification to show after 2 seconds.
// 	const NotificationDetails(
		
// 		// Android details
// 		android: AndroidNotificationDetails('main_channel', 'Main Channel',
// 			channelDescription: "ToDo",
// 			importance: Importance.max,
// 			priority: Priority.max),
// 		// iOS details
// 		// iOS: IOSNotificationDetails(
// 		// sound: 'default.wav',
// 		// presentAlert: true,
// 		// presentBadge: true,
// 		// presentSound: true,
// 		// ),
// 	),
	
// 	// Type of time interpretation
// 	uiLocalNotificationDateInterpretation:
// 		UILocalNotificationDateInterpretation.absoluteTime,
// 	androidAllowWhileIdle:
// 		true, // To show notification even when the app is closed
// 	);
// }
// }
