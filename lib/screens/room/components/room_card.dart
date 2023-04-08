import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:share/share.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/models/tokshow.dart';
import 'package:tokshop/services/dynamic_link_services.dart';

import '../../../utils/text.dart';
import '../../../utils/utils.dart';

class RoomCard extends StatelessWidget {
  Tokshow roomModel;
  List<dynamic> hosts;
  bool? showChannel = true;
  RoomCard(
      {Key? key,
      required this.roomModel,
      required this.hosts,
      this.showChannel})
      : super(key: key);

  final TokShowController _homeController = Get.find<TokShowController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10, right: 10),
      width: MediaQuery.of(Get.context!).size.width * 0.75,
      decoration: BoxDecoration(
          color: const Color(0xFFF5F6F9),
          borderRadius: BorderRadius.circular(20.0),
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
                roomModel.hostIds!.isEmpty
                    ? const CircleAvatar(
                        radius: 18,
                        backgroundImage:
                            AssetImage("assets/icons/profile_placeholder.png"))
                    : CircleAvatar(
                        radius: 18,
                        onBackgroundImageError: (object, stacktrace) =>
                            const AssetImage(
                                "assets/icons/profile_placeholder.png"),
                        backgroundImage:
                            NetworkImage(roomModel.hostIds![0].profilePhoto!),
                      ),
                const SizedBox(
                  width: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(roomModel.hostIds![0].firstName!),
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
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 0.01.sh,
          ),
          Text(
            roomModel.title!,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: 0.03.sh,
          ),
          Row(
            children: [
              if (roomModel.userIds!.isEmpty)
                Expanded(
                  child: Row(
                    children: [
                      InkWell(
                          onTap: () async {
                            DynamicLinkService()
                                .generateShareLink(roomModel.id!,
                                    type: "room",
                                    title: "$join ${roomModel.title} $tokShows",
                                    msg:
                                        "$products_being_discussed ${roomModel.productIds!.map((e) => e.name).toList()}",
                                    imageurl:
                                        roomModel.productIds![0].images![0])
                                .then(
                                    (value) async => await Share.share(value));
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
                        roomModel.hostIds!.length.toString(),
                        style: const TextStyle(color: Colors.black),
                      ),
                      SizedBox(width: 0.03.sw),
                      Text(
                        roomModel.userIds!.length.toString(),
                        style: const TextStyle(color: Colors.black),
                      ),
                      SizedBox(width: 0.006.sw),
                      const Icon(
                        Ionicons.chatbubble_outline,
                        color: Colors.black,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              if (roomModel.userIds!.isNotEmpty)
                Expanded(
                  child: SizedBox(
                    height: 30,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: roomModel.userIds!
                          .map(
                            (e) => Stack(
                              children: [
                                e.profilePhoto != null
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
                                        backgroundImage:
                                            NetworkImage(e.profilePhoto!),
                                      ),
                                Positioned(
                                  bottom: 0,
                                  right: -2,
                                  child: Icon(
                                    Icons.fiber_manual_record,
                                    color: Colors.greenAccent,
                                    size: 15,
                                  ),
                                )
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    if (roomModel.id != null) {
                      await _homeController.joinRoom(roomModel.id!);
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: primarycolor,
                          borderRadius: BorderRadius.circular(25.0)),
                      child: Text(
                        "Join now",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
