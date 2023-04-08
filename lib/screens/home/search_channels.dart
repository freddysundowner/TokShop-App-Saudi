import 'package:firebase_auth/firebase_auth.dart';
import 'package:tokshop/controllers/channel_controller.dart';
import 'package:tokshop/controllers/global.dart';
import 'package:tokshop/models/channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/screens/channels/view_channel.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';

//ignore: must_be_immutable
class SearchChannels extends StatelessWidget {
  String? text = "";
  SearchChannels({Key? key, this.text}) : super(key: key);
  ChannelController channelController =
      Get.put<ChannelController>(ChannelController());
  List<Channel> channels = [];
  @override
  Widget build(BuildContext context) {
    channels = text == null
        ? channelController.allchannels
        : channelController.allchannels
            .where((p0) => p0.title!.toString().toLowerCase().contains(text!))
            .toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (c, i) {
          return Container(
            height: 15,
          );
        },
        itemCount: channels.length,
        itemBuilder: (context, index) {
          return singleChannel(channels[index]);
        },
      ),
    );
  }

  singleChannel(Channel channel) {
    return InkWell(
      onTap: () {
        channelController.getChannel(channel.id!);
        Get.to(() => ViewChannel());
      },
      child: Container(
        decoration: BoxDecoration(
            color: primarycolor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.title!,
                      style: TextStyle(color: Colors.black, fontSize: 14.sp),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.online_prediction,
                          color: Colors.red,
                          size: 15,
                        ),
                        Text(" ${channel.rooms!.length} $tokshows_live_now",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 11.sp,
                            ))
                      ],
                    ),
                  ],
                ),
                InkWell(
                  onTap: () async {
                    try {
                      channelController.channelJoiningId.value = channel.id!;
                      if (Get.find<AuthController>()
                              .usermodel
                              .value
                              ?.channels!
                              .indexWhere(
                                  (element) => element.id == channel.id) ==
                          -1) {
                        await channelController.joinChannel(channel);
                      } else {
                        await channelController.leaveChannel(channel);
                      }
                      channelController.channelJoiningId.value = "";
                    } catch (e, s) {
                      printOut("$e $s");
                      channelController.channelJoiningId.value = "";
                    } finally {
                      channelController.channelJoiningId.value = "";
                    }
                  },
                  child: Obx(() {
                    return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 20),
                        decoration: BoxDecoration(
                            color: Get.find<AuthController>()
                                        .usermodel
                                        .value
                                        ?.channels!
                                        .indexWhere((element) =>
                                            element.id == channel.id) !=
                                    -1
                                ? kPrimaryColor
                                : Colors.transparent,
                            border: Border.all(
                                color: Get.find<AuthController>()
                                            .usermodel
                                            .value
                                            ?.channels!
                                            .indexWhere((element) =>
                                                element.id == channel.id) !=
                                        -1
                                    ? Colors.transparent
                                    : primarycolor),
                            borderRadius: BorderRadius.circular(8)),
                        child: channelController.channelJoiningId.value ==
                                channel.id
                            ? Transform.scale(
                                scale: 0.3,
                                child: const CircularProgressIndicator(
                                  color: primarycolor,
                                ))
                            : Text(
                                Get.find<AuthController>()
                                            .usermodel
                                            .value
                                            ?.channels!
                                            .indexWhere((element) =>
                                                element.id == channel.id) !=
                                        -1
                                    ? unsubscribe
                                    : subscribe,
                                style: TextStyle(
                                    color: Get.find<AuthController>()
                                                .usermodel
                                                .value
                                                ?.channels!
                                                .indexWhere((element) =>
                                                    element.id == channel.id) !=
                                            -1
                                        ? Colors.white
                                        : primarycolor,
                                    fontWeight: FontWeight.bold),
                              ));
                  }),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
