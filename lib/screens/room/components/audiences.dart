import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/screens/profile/user_profile.dart';

import '../../../controllers/room_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/tokshow.dart';
import '../../../utils/text.dart';
import '../../../utils/utils.dart';

Future<dynamic> Audiences(
    BuildContext context, AgoraRtmChannel? rtmChannel, RtcEngine? engine) {
  final TokShowController homeController = Get.find<TokShowController>();

  return showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: Colors.grey[200],
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(15),
      topRight: Radius.circular(15),
    )),
    builder: (context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return DraggableScrollableSheet(
            initialChildSize: 0.8,
            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Obx(() {
                  var peopleTalkingInRoom = 0;

                  for (var i = 0;
                      i <
                          homeController
                              .currentRoom.value.invitedSpeakerIds!.length;
                      i++) {
                    if (homeController.currentRoom.value.invitedSpeakerIds!
                            .elementAt(i)
                            .muted ==
                        false) {
                      peopleTalkingInRoom++;
                    }
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 0.02.sh,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.mic_none,
                              color: Colors.black,
                            ),
                            SizedBox(
                              width: 0.01.sw,
                            ),
                            Text(
                              "$peopleTalkingInRoom $talking",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 14.sp),
                            )
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              viewers_who_want_to_speak,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 0.02.sh,
                        ),
                        SizedBox(
                          height: 0.01.sh,
                        ),
                        roomUser(rtmChannel, engine),
                      ],
                    ),
                  );
                }),
              );
            });
      });
    },
  );
}

Widget roomUser(AgoraRtmChannel? rtmChannel, RtcEngine? engine) {
  final TokShowController homeController = Get.find<TokShowController>();
  final UserController userController = Get.find<UserController>();
  return Column(
    children: [
      Obx(() {
        List<OwnerId> users = homeController.currentRoom.value.raisedHands!;
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              OwnerId user = users[index];
              print(homeController.userBeingMoved.value);
              print(
                  "raised ${homeController.currentRoom.value.invitedSpeakerIds!.indexWhere((element) => element.id == user.id)}");
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: InkWell(
                  onTap: () {
                    Get.back();
                    userController.getUserProfile(user.id!);
                    Get.to(UserProfile());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            user.profilePhoto == "" || user.profilePhoto == null
                                ? const CircleAvatar(
                                    radius: 20,
                                    backgroundImage: AssetImage(
                                        "assets/icons/profile_placeholder.png"))
                                : CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        NetworkImage(user.profilePhoto!),
                                  ),
                            SizedBox(
                              width: 0.02.sw,
                            ),
                            Expanded(
                              child: Text(
                                "${user.firstName.toString()} ${user.lastName.toString()} ",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12.sp),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (homeController
                                  .currentRoom.value.invitedSpeakerIds!
                                  .indexWhere(
                                      (element) => element.id == user.id) !=
                              -1)
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(30)),
                              child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: InkWell(
                                    onTap: () async {
                                      homeController.muteUnMuteRemoteUser(
                                          user, rtmChannel, engine!);
                                      ;
                                    },
                                    child: Icon(
                                      user.muted == true
                                          ? Icons.mic_off
                                          : Icons.mic,
                                      color: Colors.black,
                                      size: 25,
                                    ),
                                  )),
                            ),
                          Row(
                            children: [
                              SizedBox(
                                width: 0.015.sw,
                              ),
                              InkWell(
                                onTap: () async {
                                  // Get.back();
                                  try {
                                    homeController.userBeingMoved.value =
                                        user.id!;

                                    if (homeController.currentRoom.value
                                            .invitedSpeakerIds!
                                            .indexWhere((element) =>
                                                element.id == user.id) ==
                                        -1) {
                                      homeController
                                          .currentRoom.value.invitedSpeakerIds!
                                          .add(user);
                                      homeController.currentRoom.refresh();
                                      await homeController.inviteToSpeaker(
                                          user, engine, rtmChannel);
                                    } else {
                                      await homeController
                                          .removeUserFromInvitedSpeakers(
                                              user, engine, rtmChannel);
                                    }
                                    homeController.userBeingMoved.value = "";
                                  } catch (e, s) {
                                    homeController.userBeingMoved.value = "";
                                    printOut(" eeee  $e $s");
                                  } finally {
                                    homeController.userBeingMoved.value = "";
                                    printOut(
                                        " userBeingMoved 2 ${homeController.userBeingMoved.value}");
                                  }
                                },
                                child: Obx(() {
                                  return Container(
                                    width: 0.27.sw,
                                    height: 0.04.sh,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                      child: homeController
                                                  .userBeingMoved.value ==
                                              user.id
                                          ? Transform.scale(
                                              scale: 0.3,
                                              child:
                                                  const CircularProgressIndicator(
                                                color: Colors.white,
                                              ))
                                          : Text(
                                              homeController.currentRoom.value
                                                          .invitedSpeakerIds!
                                                          .indexWhere(
                                                              (element) =>
                                                                  element.id ==
                                                                  user.id) !=
                                                      -1
                                                  ? remove
                                                  : invite_to_speak,
                                              style: TextStyle(
                                                  fontSize: 10.sp,
                                                  color: Styles.greenTheme),
                                            ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                          // if (user.id! !=
                          //     FirebaseAuth.instance.currentUser!.uid)
                          //   Row(
                          //     children: [
                          //       SizedBox(
                          //         width: 0.015.sw,
                          //       ),
                          //       InkWell(
                          //         onTap: () async {
                          //           try {
                          //             userController.userBeingFollowingId
                          //                 .value = user.id!;
                          //
                          //             if (user.followers!.indexWhere(
                          //                     (element) =>
                          //                         element ==
                          //                         FirebaseAuth.instance
                          //                             .currentUser!.uid) !=
                          //                 -1) {
                          //               user.followers!.removeWhere((element) =>
                          //                   element ==
                          //                   FirebaseAuth
                          //                       .instance.currentUser!.uid);
                          //
                          //               homeController
                          //                   .currentRoom.value.allUsersCombined!
                          //                   .elementAt(index)
                          //                   .followers!
                          //                   .removeWhere((element) =>
                          //                       element ==
                          //                       FirebaseAuth
                          //                           .instance.currentUser!.uid);
                          //
                          //               await UserAPI().unFollowAUser(
                          //                   FirebaseAuth
                          //                       .instance.currentUser!.uid,
                          //                   user.id!);
                          //             } else {
                          //               user.followers!.add(FirebaseAuth
                          //                   .instance.currentUser!.uid);
                          //
                          //               homeController
                          //                   .currentRoom.value.allUsersCombined!
                          //                   .elementAt(index)
                          //                   .followers!
                          //                   .add(FirebaseAuth
                          //                       .instance.currentUser!.uid);
                          //
                          //               await UserAPI().followAUser(
                          //                   FirebaseAuth
                          //                       .instance.currentUser!.uid,
                          //                   user.id!);
                          //             }
                          //             homeController.currentRoom.refresh();
                          //             userController
                          //                 .userBeingFollowingId.value = "";
                          //           } catch (e, s) {
                          //             printOut(
                          //                 "Following unfollowing user $e $s");
                          //             userController
                          //                 .userBeingFollowingId.value = "";
                          //           } finally {
                          //             userController
                          //                 .userBeingFollowingId.value = "";
                          //           }
                          //         },
                          //         child: Container(
                          //           width: 0.2.sw,
                          //           height: 0.04.sh,
                          //           decoration: BoxDecoration(
                          //               color: user.followers!.contains(
                          //                       Get.find<AuthController>()
                          //                           .usermodel
                          //                           .value!
                          //                           .id)
                          //                   ? Styles.greenTheme
                          //                   : Colors.transparent,
                          //               borderRadius:
                          //                   BorderRadius.circular(10)),
                          //           child: Center(
                          //             child: Obx(
                          //               () => userController
                          //                           .userBeingFollowingId
                          //                           .value ==
                          //                       user.id
                          //                   ? Transform.scale(
                          //                       scale: 0.3,
                          //                       child:
                          //                           const CircularProgressIndicator(
                          //                         color: Colors.white,
                          //                       ))
                          //                   : Text(
                          //                       user.followers!.contains(
                          //                               Get.find<
                          //                                       AuthController>()
                          //                                   .usermodel
                          //                                   .value!
                          //                                   .id)
                          //                           ? "Following"
                          //                           : "Follow",
                          //                       style: TextStyle(
                          //                         color: user.followers!
                          //                                 .contains(Get.find<
                          //                                         AuthController>()
                          //                                     .usermodel
                          //                                     .value!
                          //                                     .id)
                          //                             ? Colors.white
                          //                             : Colors.black,
                          //                         fontSize: 10.sp,
                          //                       ),
                          //                     ),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
      }),
    ],
  );
}
