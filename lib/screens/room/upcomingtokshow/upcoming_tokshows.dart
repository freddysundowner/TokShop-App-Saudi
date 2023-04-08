import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/screens/room/components/upcoming_tokshow_card.dart';
import '../../../controllers/room_controller.dart';
import '../../../models/upcoming_tokshow.dart';
import '../../../utils/text.dart';
import '../../../utils/utils.dart';
import '../../home/create_room.dart';
import 'new_upcoming_tokshow.dart';

class UpcomingTokShows extends StatelessWidget {
  final UpcomingTokshow? roomModel;
  UpcomingTokShows({Key? key, this.roomModel}) : super(key: key) {
    tokShowController.fetchEvents();
  }
  final TokShowController tokShowController = Get.find<TokShowController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          const Text(upcoming_tokshows),
          Spacer(),
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              CupertinoIcons.calendar_badge_plus,
              size: 25,
            ),
            onPressed: () {
              Get.to(() => NewUpcomingTokshow());
            },
          )
        ],
      )),
      body: RefreshIndicator(
        onRefresh: () {
          if (homeController.selectedEvents.value == "mine") {
            return tokShowController
                .fetchMyEvents(FirebaseAuth.instance.currentUser!.uid);
          } else {
            return tokShowController.fetchEvents();
          }
        },
        child: Obx(() {
          List<UpcomingTokshow> rooms = tokShowController.allUpcomingEvents;
          if (tokShowController.allUpcomingEvents.isEmpty) {
            return Container(
              alignment: Alignment.center,
              child: Center(
                  child: Column(
                children: [
                  const SizedBox(
                    height: 120,
                  ),
                  Text(
                    no_upcoming_events_to_show,
                    style: TextStyle(color: primarycolor, fontSize: 16.sp),
                  ),
                  SizedBox(
                    height: 0.01.sh,
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      CupertinoIcons.calendar_badge_plus,
                      size: 80,
                      color: primarycolor,
                    ),
                    onPressed: () {
                      Get.to(() => NewUpcomingTokshow());
                    },
                  )
                ],
              )),
            );
          }
          return ListView(
            children: rooms.map((event) {
              return UpcomingTokshowCard(
                event: event,
              );
            }).toList(),
          );
        }),
      ),
    );
  }
}
