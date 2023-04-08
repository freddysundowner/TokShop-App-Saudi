import 'dart:convert';

import '../utils/utils.dart';
import 'client.dart';
import 'end_points.dart';

class NotificationsAPI {
  getAllUserNotifications(String uid, String pageNumber) async {
    var activities = await DbBase().databaseRequest(
        "$userActivities$uid/$pageNumber", DbBase().getRequestType);

    return jsonDecode(activities)[0]["data"];
  }

  saveActivity(Map<String, dynamic> data) async {
    try {
      await DbBase()
          .databaseRequest(addActivity, DbBase().postRequestType, body: data);
    } catch (e, s) {
      printOut("Error $saveActivity $e $s");
    }
  }

  static deleteAllActivity(Map<String, dynamic> data) async {
    try {
      await DbBase()
          .databaseRequest(addActivity, DbBase().deleteRequestType, body: data);
    } catch (e, s) {
      printOut("Error  $e $s");
    }
  }

  sendNotification(List userIds, String title, String message, String screen,
      String id) async {
    var body = {
      "users": userIds,
      "title": title,
      "message": message,
      "screen": screen,
      "id": id
    };
    printOut(body);
    printOut(notifications);
    await DbBase()
        .databaseRequest(notifications, DbBase().postRequestType, body: body);
  }
}
