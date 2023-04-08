import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auction_controller.dart';
import 'package:tokshop/models/auction.dart';
import 'package:tokshop/screens/profile/user_profile.dart';

import '../../../controllers/room_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/tokshow.dart';
import '../../../utils/text.dart';
import '../../../utils/utils.dart';

Future<dynamic> BidsView(BuildContext context) {
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
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 0.02.sh,
                        ),
                        Text(
                          "${homeController.currentRoom.value.activeauction!.bids!.length} $total_bids",
                          style:
                              TextStyle(color: Colors.black54, fontSize: 14.sp),
                        ),
                        SizedBox(
                          height: 0.02.sh,
                        ),
                        SizedBox(
                          height: 0.01.sh,
                        ),
                        roomUser(),
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

Widget roomUser() {
  final TokShowController homeController = Get.find<TokShowController>();
  final AuctionController auctionController = Get.find<AuctionController>();
  final UserController userController = Get.find<UserController>();
  return Column(
    children: [
      Obx(() {
        if (homeController.currentRoom.value.activeauction == null)
          return Text(no_bids_available);
        List<Bid> bids = homeController.currentRoom.value.activeauction!.bids!;
        bids.sort((a, b) {
          return a.amount
              .toString()
              .toLowerCase()
              .compareTo(b.amount.toString().toLowerCase());
        });
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: bids.length,
            itemBuilder: (context, index) {
              OwnerId user = bids[index].bidder;
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
                      if (homeController
                              .currentRoom.value.activeauction!.winning!.id ==
                          user.id)
                        const Text(
                          highest_bidder,
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      SizedBox(
                        width: 20,
                      ),
                      Text("$currencySymbol ${bids[index].amount.toString()}")
                    ],
                  ),
                ),
              );
            });
      }),
    ],
  );
}
