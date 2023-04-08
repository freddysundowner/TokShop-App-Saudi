import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/models/upcoming_tokshow.dart';
import 'package:tokshop/services/dynamic_link_services.dart';

import '../../../utils/text.dart';
import '../../../utils/utils.dart';

class UpcomingTokshowCard extends StatelessWidget {
  UpcomingTokshow event;
  UpcomingTokshowCard({Key? key, required this.event}) : super(key: key);
  TokShowController tokShowController = Get.find<TokShowController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(right: 20, left: 20, bottom: 20, top: 15),
      width: MediaQuery.of(Get.context!).size.width * 0.75,
      decoration: BoxDecoration(
          color: const Color(0xFFF5F6F9),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey, width: 0.3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(25.0)),
            child: Row(
              children: [
                event.hostIds!.isEmpty
                    ? const CircleAvatar(
                        radius: 18,
                        backgroundImage:
                            AssetImage("assets/icons/profile_placeholder.png"))
                    : CircleAvatar(
                        radius: 15,
                        onBackgroundImageError: (object, stacktrace) =>
                            const AssetImage(
                                "assets/icons/profile_placeholder.png"),
                        backgroundImage:
                            NetworkImage(event.hostIds![0].profilePhoto!),
                      ),
                const SizedBox(
                  width: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.hostIds![0].firstName!),
                    const Text(
                      "Host",
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
                const Spacer(),
                Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade400, shape: BoxShape.circle),
                    child: const Icon(
                      Icons.mic,
                      color: Colors.red,
                      size: 18,
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 0.01.sh,
          ),
          Text(
            event.title!,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            date(event.eventDate),
            style: TextStyle(color: Styles.smallButton, fontSize: 12.0.sp),
          ),
          SizedBox(
            height: 0.01.sh,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Row(
              children: [
                Text("Waiting room~",
                    style: TextStyle(
                        fontSize: 12.0.sp, fontWeight: FontWeight.w500)),
                Expanded(
                  child: Wrap(
                    children: List.generate(
                        event.invitedhostIds!.length,
                        (i) => Text(
                              "${event.invitedhostIds![i].firstName!} ${event.invitedhostIds![i].lastName!}, ",
                              style: TextStyle(
                                fontSize: 9.0.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                            )).toList(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 0.01.sh,
          ),
          Row(
            children: [
              InkWell(
                onTap: () async {
                  if (event.id != null) {
                    await tokShowController.joinRoom(event.id!);
                  } else {
                    Get.snackbar('', tokshow_is_no_longer_available,
                        backgroundColor: kPrimaryColor,
                        colorText: Colors.white);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    decoration: BoxDecoration(
                        color: primarycolor,
                        borderRadius: BorderRadius.circular(25.0)),
                    child: const Text(
                      "Join now",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                ),
              ),
              if (event.ownerId!.id != FirebaseAuth.instance.currentUser!.uid)
                Obx(
                  () {
                    int i = tokShowController.allUpcomingEvents
                        .indexWhere((element) => element.id == event.id);

                    bool tobenotified = tokShowController
                                .allUpcomingEvents[i].toBeNotified!
                                .indexWhere((element) =>
                                    element.id ==
                                    FirebaseAuth.instance.currentUser!.uid) !=
                            -1 ||
                        event.invitedhostIds!.indexWhere((element) =>
                                element.id ==
                                FirebaseAuth.instance.currentUser!.uid) !=
                            -1;
                    return InkWell(
                      onTap: () {
                        tokShowController.addRemoveToBeNotified(event, i);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: tobenotified
                                ? kPrimaryColor
                                : Styles.smallButton.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications,
                                color:
                                    tobenotified ? Colors.white : primarycolor,
                                size: 15,
                              ),
                              Text(
                                notify_me,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: tobenotified
                                        ? Colors.white
                                        : primarycolor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: InkWell(
                    onTap: () async {
                      DynamicLinkService()
                          .generateShareLink(event.id!,
                              type: "room",
                              title: "$join ${event.title} $tokShows",
                              msg:
                                  "$products_being_discussed ${event.productIds!.map((e) => e.name).toList()}",
                              imageurl: event.productIds![0].images![0])
                          .then((value) async => await Share.share(value));
                    },
                    child: const Text(
                      "Invite Friends",
                      style: TextStyle(
                          color: primarycolor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }
}
