import 'package:agora_rtm/src/agora_rtm_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../../../controllers/room_controller.dart';
import '../../../models/tokshow.dart';
import '../../../utils/text.dart';

Future<dynamic> raisedHandsBottomSheet(
    BuildContext context, AgoraRtmChannel? rtmChannel) {
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
            initialChildSize: 0.5,
            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Ionicons.hand_left_sharp,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 0.01.sw,
                        ),
                        Text(
                          raised_hands,
                          style:
                              TextStyle(color: Colors.black87, fontSize: 16.sp),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 0.02.sh,
                    ),
                    homeController.currentRoom.value.raisedHands!.isNotEmpty
                        ? SizedBox(
                            height: 0.4.sh,
                            child: GetBuilder<TokShowController>(builder: (hc) {
                              return ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount:
                                      hc.currentRoom.value.raisedHands!.length,
                                  itemBuilder: (context, index) {
                                    OwnerId user = hc
                                        .currentRoom.value.raisedHands!
                                        .elementAt(index);

                                    return InkWell(
                                      onTap: () {
                                        Get.back();
                                        // hc.addUserToSpeaker(user, rtmChannel);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                user.profilePhoto == "" ||
                                                        user.profilePhoto ==
                                                            null
                                                    ? const CircleAvatar(
                                                        radius: 25,
                                                        backgroundImage: AssetImage(
                                                            "assets/icons/profile_placeholder.png"))
                                                    : CircleAvatar(
                                                        radius: 25,
                                                        backgroundImage:
                                                            NetworkImage(user
                                                                .profilePhoto!),
                                                      ),
                                                SizedBox(
                                                  width: 0.02.sw,
                                                ),
                                                Text(
                                                  "${user.firstName} ${user.lastName}",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14.sp),
                                                ),
                                              ],
                                            ),
                                            const Icon(
                                              Ionicons.add_circle,
                                              color: Colors.black54,
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                          )
                        : Text(
                      no_raised_hands,
                            style:
                                TextStyle(color: Colors.grey, fontSize: 14.sp),
                          )
                  ],
                ),
              );
            });
      });
    },
  );
}
