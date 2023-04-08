import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tokshop/screens/profile/user_profile.dart';
import 'package:tokshop/screens/room/upcomingTokShow/upcoming_tokshows.dart';
import 'package:tokshop/utils/text.dart';
import 'package:url_launcher/url_launcher.dart';

import '/theme.dart';
import '/utils/utils.dart';
import 'bindings.dart';
import 'controllers/auth_controller.dart';
import 'controllers/chat_controller.dart';
import 'controllers/channel_controller.dart';
import 'controllers/room_controller.dart';
import 'controllers/user_controller.dart';
import 'models/upcoming_tokshow.dart';
import 'models/order.dart' as TokshopOrder;
import 'models/user.dart';
import 'screens/chats/chat_room_page.dart';
import 'screens/auth/handle_auth_page.dart';
import 'screens/orders/order_receipt.dart';
import 'services/dynamic_link_services.dart';
import 'services/room_api.dart';
import 'services/user_api.dart';

AndroidNotificationChannel channel = channel;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final UserController _userController = Get.find<UserController>();
final TokShowController _homeController = Get.find<TokShowController>();
final AuthController authController = Get.put(AuthController());
final ChannelController channelController =
    Get.put<ChannelController>(ChannelController());
final ChatController _chatController =
    Get.put<ChatController>(ChatController());

getApiSettings() async {
  try {
    List response = await UserAPI.getSettings();
    if (response.isNotEmpty) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String code = packageInfo.buildNumber;
      String type = "";
      String url = "";
      if (Platform.isAndroid) {
        type = "androidVersion";
        url =
            "https://play.google.com/store/apps/details?id=$packagename&hl=en&gl=US";
      } else if (Platform.isIOS) {
        type = "iosVersion";
        url = "https://apps.apple.com/us/app/itunes-connect/id$iosAppID";
      }
      if (response.first[type] != null &&
          response.first[type] != "" &&
          int.parse(code) > int.parse(response[0][type])) {
        Future.delayed(const Duration(seconds: 2), () {
          GetSnackBar(
            snackPosition: SnackPosition.TOP,
            messageText: const Text(
              appUpdate_message,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            mainButton: InkWell(
              onTap: () async {
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  throw "Could not launch $url";
                }
              },
              child: const Text(updateNowMessage,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            backgroundColor: kPrimaryColor,
          ).show();
        });
      }
      agoraAppID = response[0]["agoraAppID"];
      currencySymbol = response[0]["currency"];
      audioRecordingsBaseUrl = response[0]["recordedVideoBaseUrl"];
      oneSignalAppID = response[0]["oneSignalAppID"];
      applicationFee = response[0]["commission"].toString().isEmpty
          ? 0.0
          : double.parse(response[0]["commission"]);
      stripePublishKey = response[0]["stripepublickey"];
      stripeSecretKey = response[0]["stripeSecretKey"];
      fwPublicKey = response[0]["fwPublicKey"];
      youTubeStreamKey = response[0]["youTubeStreamKey"];
      fbStreamKey = response[0]["fbStreamKey"];
    }
  } catch (e) {
    printOut("errr here $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getApiSettings();
  await Firebase.initializeApp();
  if (stripePublishKey.isNotEmpty) {
    Stripe.publishableKey = stripePublishKey;
    Stripe.merchantIdentifier = 'tokshop';
    await Stripe.instance.applySettings();
  }
  oneSignal();
  runApp(const MyApp());
}

Future<void> oneSignal() async {
  initOneSignal();
  oneSignalObservers();
}

initOneSignal() {
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  OneSignal.shared.setAppId(oneSignalAppID);
  OneSignal.shared
      .promptUserForPushNotificationPermission()
      .then((accepted) {});
}

oneSignalObservers() {
  OneSignal.shared.setNotificationWillShowInForegroundHandler(
      (OSNotificationReceivedEvent event) {
    if (event.notification.additionalData!["screen"] == "ChatScreen" &&
        _homeController.onChatPage.value == true) {
      event.complete(null);
    } else if (event.notification.additionalData!["screen"] ==
            "RoomChatScreen" &&
        _homeController.currentRoom.value.id != null &&
        _homeController.onTokShowChatPage.value == true) {
      event.complete(null);
    } else {
      event.complete(event.notification);
    }
  });

  OneSignal.shared
      .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
    redirectToRooms(result.notification.additionalData!);
    handleNotificationOneSignal(result.notification);
  });
}

Future<void> handleNotificationOneSignal(OSNotification osNotification) async {
  flutterLocalNotificationsPlugin.show(
      osNotification.hashCode,
      osNotification.title,
      osNotification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          "0",
          osNotification.title!,
          channelDescription: osNotification.body!,
          importance: Importance.high,
          priority: Priority.high,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: '@mipmap/ic_stat_onesignal_default',
        ),
      ),
      payload: " ${osNotification.additionalData!['screen']}  "
          "${osNotification.additionalData!['id']} ${osNotification.additionalData!['paidroom'] ?? ""}");
}

bool showloading = false;

Future redirectToRooms(Map<String, dynamic> mess) async {
  String screen = mess["screen"];
  String id = mess["id"];
  if (screen == 'ChatScreen') {
    _chatController.getUserChats();
    _chatController.currentChatId.value = id;
    _chatController.getChatById(id);
    await _chatController.getChatUsers(id);
    // Get.to(AllChatsPage());
    var user = await UserAPI().getUserProfile(
        _chatController.getOtherUser(_chatController.currentChatUsers));
    Get.to(ChatRoomPage(UserModel.fromJson(user)));
    _homeController.onChatPage.value = true;
  } else if (screen == "ProfileScreen") {
    _userController.getUserProfile(id);
    Get.to(UserProfile());
  } else if (screen == "RoomChatScreen") {
    if (_homeController.currentRoom.value.id != null) {
      _homeController.roomPageInitialPage.value = 0;
      _homeController.pageController.jumpToPage(0);
      if (_homeController.onTokShowChatPage.value == false) {
        _homeController.joinRoom(id);
      }
    }
  } else if (screen == "RoomScreen") {
    _homeController.joinRoom(id, type: "notification");
  } else if (screen == "EventScreen") {
    UpcomingTokshow roomModel =
        UpcomingTokshow.fromJson(await RoomAPI().getEventById(id));
    Get.to(() => UpcomingTokShows(roomModel: roomModel));
  } else if (screen == "OrderScreen") {
    var order = await UserAPI().getOrderById(id);
    Get.to(OrderReceipt(TokshopOrder.Order.fromJson(order)));
  }
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DynamicLinkService().handleDynamicLinks();
    _runWhileAppIsTerminated();
  }

  void _runWhileAppIsTerminated() async {
    var details =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (details!.didNotificationLaunchApp) {
      await SharedPreferences.getInstance();
    }
  }

  getSettings() {
    FirebaseFirestore.instance.collection('settings').get().then((value) {
      if (value.docs.isNotEmpty) {
        _homeController.inAppProducts.value =
            value.docs[0].data()["inapp_prooducts"];
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (BuildContext context, c) {
          return GetMaterialApp(
            navigatorKey: navigatorKey,
            title: appName,
            debugShowCheckedModeBanner: false,
            theme: theme(),
            initialBinding: AuthBinding(),
            home: const HandleAuthPage(),
          );
        });
  }
}
