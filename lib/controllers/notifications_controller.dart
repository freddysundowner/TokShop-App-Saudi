import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/notifications_api.dart';
import '../utils/utils.dart';

class NotificationsController extends GetxController {
  var allNotificationsLoading = false.obs;
  var moreNotificationsLoading = false.obs;
  var allNotifications = [].obs;
  var roomPageInitialPage = 1.obs;
  var notificationsPageNumber = 0.obs;
  final notificationsScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    getUserNotifications();

    notificationsScrollController.addListener(() {
      if (notificationsScrollController.position.atEdge) {
        bool isTop = notificationsScrollController.position.pixels == 0;
        if (isTop) {
        } else {
          notificationsPageNumber.value = notificationsPageNumber.value + 1;
          getMoreUserNotifications();
        }
      }
    });
  }

  getUserNotifications() async {
    try {
      allNotificationsLoading.value = true;

      notificationsPageNumber.value = 0;

      var activities = await NotificationsAPI().getAllUserNotifications(
          FirebaseAuth.instance.currentUser!.uid,
          notificationsPageNumber.value.toString());
      if (activities != null) {
        allNotifications.value = activities;
      } else {
        allNotifications.value = [];
      }

      allNotifications.refresh();
      allNotificationsLoading.value = false;
    } catch (e) {
      allNotificationsLoading.value = false;
      allNotifications.value = [];
      printOut("Error getting notifications $e");
    }
  }

  getMoreUserNotifications() async {
    try {
      moreNotificationsLoading.value = true;

      var activities = await NotificationsAPI().getAllUserNotifications(
          FirebaseAuth.instance.currentUser!.uid,
          notificationsPageNumber.value.toString());
      if (activities != null) {
        allNotifications.addAll(activities);
      }
      moreNotificationsLoading.value = false;
    } catch (e) {
      moreNotificationsLoading.value = false;
      printOut("Error getting notifications $e");
    }
  }
}
