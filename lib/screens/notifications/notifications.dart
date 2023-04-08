import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/screens/profile/user_profile.dart';
import 'package:tokshop/services/notifications_api.dart';

import '../../controllers/notifications_controller.dart';
import '../../controllers/channel_controller.dart';
import '../../controllers/room_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/notifications_model.dart';
import '../../models/tokshow.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';
import '../orders/orders_history.dart';

//ignore: must_be_immutable
class Notifications extends StatelessWidget {
  final NotificationsController _activityController =
      Get.put(NotificationsController());
  final UserController _userController = Get.find<UserController>();
  final TokShowController _homeController = Get.find<TokShowController>();
  ChannelController channelController = Get.find<ChannelController>();

  Notifications({Key? key}) : super(key: key) {
    _activityController.getUserNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(notifications),
            InkWell(
              child: Text(
                clear,
                style: TextStyle(color: Colors.red, fontSize: 13.sp),
              ),
              onTap: () async {
                await showConfirmationDialog(context,
                    clear_all_notifications,
                    function: () {
                  NotificationsAPI.deleteAllActivity(
                      {"userId": FirebaseAuth.instance.currentUser!.uid});
                  _activityController.allNotifications.clear();
                  _activityController.allNotifications.refresh();
                  Get.back();
                }, positiveResponse: "Yes", negativeResponse: "Not now");
              },
            )
          ],
        ),
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _activityController.getUserNotifications();
        },
        child: Obx(() {
          return _activityController.allNotificationsLoading.isFalse
              ? _activityController.allNotifications.isNotEmpty
                  ? Column(
                      children: [
                        if (_activityController.moreNotificationsLoading.isTrue)
                          const CircularProgressIndicator(
                            color: primarycolor,
                          ),
                        Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              controller: _activityController
                                  .notificationsScrollController,
                              itemCount:
                                  _activityController.allNotifications.length,
                              itemBuilder: (context, index) {
                                NotificationModel activityModel =
                                    NotificationModel.fromJson(
                                        _activityController.allNotifications
                                            .elementAt(index));

                                return InkWell(
                                  onTap: () {
                                    if (activityModel.type == "ProfileScreen") {
                                      _userController.getUserProfile(
                                          activityModel.actionkey!);
                                      Get.to(UserProfile());
                                    } else if (activityModel.type ==
                                        "RoomScreen") {
                                      _homeController.currentRoom.value =
                                          Tokshow();
                                      _homeController
                                          .joinRoom(activityModel.actionkey!);
                                    } else if (activityModel.type ==
                                        "OrderScreen") {
                                      _userController.getUserOrders();
                                      Get.to(OrdersHistory());
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        activityModel.imageurl != null
                                            ? CircleAvatar(
                                                radius: 30,
                                                backgroundImage: NetworkImage(
                                                    activityModel.imageurl!),
                                              )
                                            : Container(),
                                        SizedBox(
                                          width: 0.04.sw,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    activityModel.name!,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: primarycolor,
                                                        fontSize: 14.0),
                                                  ),
                                                  Text(activityModel.getTime()!,
                                                      style: const TextStyle(
                                                          color: primarycolor,
                                                          fontSize: 11.0))
                                                ],
                                              ),
                                              SizedBox(
                                                height: 0.01.sh,
                                              ),
                                              Text(
                                                activityModel.message!,
                                                style: TextStyle(
                                                    color: Styles.neutralGrey,
                                                    fontSize: 12.sp),
                                              ),
                                              const Divider(
                                                thickness: 1.0,
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    )
                  : SizedBox(
                      height: 0.8.sh,
                      child: Center(
                        child: Text(
                          no_notifications,
                          style:
                              TextStyle(fontSize: 16.sp, color: primarycolor),
                        ),
                      ),
                    )
              : SizedBox(
                  height: 0.8.sh,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: primarycolor,
                    ),
                  ),
                );
        }),
      ),
    );
  }
}
