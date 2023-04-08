import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:share/share.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/models/recording.dart';
import 'package:tokshop/screens/home/main_page.dart';
import 'package:tokshop/screens/profile/user_profile.dart';
import 'package:tokshop/screens/room/play_recording_page.dart';
import 'package:tokshop/services/dynamic_link_services.dart';
import 'package:tokshop/services/recordings_api.dart';
import 'package:tokshop/utils/dialog.dart';
import 'package:tokshop/utils/functions.dart';
import 'package:tokshop/utils/styles.dart';

import '../../utils/text.dart';

class PreviousTokshows extends StatelessWidget {
  String? userid;
  PreviousTokshows({Key? key, this.userid}) : super(key: key);

  final UserController _userController = Get.find<UserController>();
  final TokShowController _homeController = Get.find<TokShowController>();

  @override
  Widget build(BuildContext context) {
    _userController.getUserRecordings(userid!, limit: "12");
    return Scaffold(
      appBar: AppBar(
        title: const Text(previous_tokshows),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Obx(
          () {
            if (_userController.userRecordings.isEmpty) {
              return Center(
                child: Text(
                  no_recorded_shows,
                  style: TextStyle(color: primarycolor, fontSize: 18.sp),
                ),
              );
            }
            return _userController.userRecordingsLoading.isFalse
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: _userController.userRecordings.length,
                    itemBuilder: (context, index) {
                      Recording recordModel = Recording.fromJson(
                          _userController.userRecordings.elementAt(index));
                      return InkWell(
                        onTap: () async {
                          if (_homeController.currentRoom.value.id != null) {
                            await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: const Text(leave_current_room),
                                    content: const Text(
                                        to_play_recorded_leave_current_room),
                                    actions: [
                                      TextButton(
                                        child: const Text(leave),
                                        onPressed: () async {
                                          _homeController
                                              .leaveRoom(
                                                  idRoom: _homeController
                                                      .currentRoom.value.id)
                                              .then((value) {
                                            Get.offAll(MainPage());
                                            _userController.getUserProfile(
                                                _userController
                                                    .currentProfile.value.id!);
                                            Get.to(UserProfile());
                                            Get.to(PlayRecordingPage(
                                                roomId:
                                                    recordModel.roomId!.id!));
                                            _homeController
                                                .playRecordedRoom(recordModel);
                                          });
                                        },
                                      ),
                                      TextButton(
                                        child: const Text(not_now),
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },
                                      ),
                                    ],
                                  );
                                });
                          } else {
                            Get.to(PlayRecordingPage(
                                roomId: recordModel.roomId!.id!));
                            _homeController.playRecordedRoom(recordModel);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF5F6F9),
                              borderRadius: BorderRadius.circular(20.0),
                              border:
                                  Border.all(color: Colors.grey, width: 0.3)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Styles.smallButton
                                            .withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(15.0)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 3),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.record_voice_over,
                                            color: Colors.red,
                                          ),
                                          Text(recorded_shows,
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w400))
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      Get.to(PlayRecordingPage(
                                          roomId: recordModel.roomId!.id!));
                                      _homeController
                                          .playRecordedRoom(recordModel);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Styles.smallButton
                                              .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 5),
                                        child: Text(
                                          replay,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 0.01.sh,
                              ),
                              Row(
                                children: [
                                  Text(
                                    recordModel.roomId!.title!,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Spacer(),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Theme(
                                      data: ThemeData.light(),
                                      child: PopupMenuButton<String>(
                                        color: Colors.white,
                                        itemBuilder: (BuildContext context) {
                                          return (FirebaseAuth.instance
                                                      .currentUser!.uid ==
                                                  _userController
                                                      .currentProfile.value.id)
                                              ? {'Share', "Delete"}
                                                  .map((String choice) {
                                                  return PopupMenuItem<String>(
                                                    onTap: () async {
                                                      Future.delayed(
                                                          const Duration(
                                                              seconds: 0),
                                                          () async {
                                                        if (choice == "Share") {
                                                          await shareRecording(
                                                              recordModel);
                                                        } else if (choice ==
                                                            "Delete") {
                                                          var confirmation =
                                                              await showConfirmationDialog(
                                                                  context,
                                                                  want_to_delete_recording);

                                                          if (confirmation) {
                                                            RecordingsAPI()
                                                                .deleteRecording(
                                                                    recordModel
                                                                        .id)
                                                                .then((value) {
                                                              if (value ==
                                                                  true) {
                                                                const GetSnackBar(
                                                                  messageText:
                                                                      Text(
                                                                        recording_deleted,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  backgroundColor:
                                                                      kPrimaryColor,
                                                                );
                                                              }
                                                            });
                                                            _userController.getUserRecordings(
                                                                _userController
                                                                    .currentProfile
                                                                    .value
                                                                    .id
                                                                    .toString());
                                                            _userController
                                                                .userRecordings
                                                                .refresh();
                                                          }
                                                        }
                                                      });
                                                    },
                                                    value: choice,
                                                    child: Text(choice),
                                                  );
                                                }).toList()
                                              : {
                                                  'Share',
                                                }.map((String choice) {
                                                  return PopupMenuItem<String>(
                                                    onTap: () async {
                                                      await shareRecording(
                                                          recordModel);
                                                    },
                                                    value: choice,
                                                    child: Text(choice),
                                                  );
                                                }).toList();
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Stack(
                                    children:
                                        recordModel.roomId!.hostIds!.map((e) {
                                      var index = recordModel.roomId!.hostIds!
                                          .indexOf(e);
                                      return Padding(
                                          padding: EdgeInsets.only(
                                              left: (30.0 * index)),
                                          child: e.profilePhoto == "" ||
                                                  e.profilePhoto == null
                                              ? const CircleAvatar(
                                                  radius: 18,
                                                  backgroundImage: AssetImage(
                                                      "assets/icons/profile_placeholder.png"))
                                              : CircleAvatar(
                                                  radius: 18,
                                                  onBackgroundImageError: (object,
                                                          stacktrace) =>
                                                      const AssetImage(
                                                          "assets/icons/profile_placeholder.png"),
                                                  backgroundImage: NetworkImage(
                                                      e.profilePhoto!),
                                                ));
                                    }).toList(),
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                          onTap: () async {
                                            DynamicLinkService()
                                                .generateShareLink(
                                                    recordModel.roomId!.id!,
                                                    type: "room",
                                                    title:
                                                        "$join ${recordModel.roomId!.title} $tokShows",
                                                    msg:
                                                        "$products_being_discussed ${recordModel.roomId!.productIds!.map((e) => e.name).toList()}",
                                                    imageurl: recordModel
                                                        .roomId!
                                                        .productIds![0]
                                                        .images![0])
                                                .then((value) async =>
                                                    await Share.share(value));
                                          },
                                          child: Image.asset(
                                            "assets/icons/arrow.png",
                                            color: Colors.black,
                                          )),
                                      SizedBox(width: 0.03.sw),
                                      const Icon(
                                        Ionicons.people,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                      Text(
                                        recordModel.roomId!.hostIds!.length
                                            .toString(),
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      SizedBox(width: 0.03.sw),
                                      Text(
                                        recordModel.roomId!.userIds!.length
                                            .toString(),
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      SizedBox(width: 0.006.sw),
                                      const Icon(
                                        Ionicons.chatbubble_outline,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 0.01.sh,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      showActualTime(
                                          recordModel.date.toString()),
                                      style: TextStyle(
                                          fontSize: 12.sp, color: primarycolor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(
                    color: primarycolor,
                  ));
          },
        ),
      ),
    );
  }
}
