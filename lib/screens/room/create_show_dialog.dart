import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/channel.dart';

import '../../controllers/channel_controller.dart';
import '../../utils/functions.dart';
import '../../utils/styles.dart';
import '../../utils/text.dart';
import '../home/create_room.dart';

class CreateShowDialog extends StatelessWidget {
  CreateShowDialog({Key? key}) : super(key: key);

  final ChannelController channelController = Get.find<ChannelController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadedScaleAnimation(
        child: Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView(
              children: [
                InkWell(
                  onTap: () => Get.back(),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.clear,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name_of_tokShow,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.sp),
                    ),
                    Text(what_do_you_want_to_talk_about,
                        style: TextStyle(color: kTextColor, fontSize: 12.sp)),
                    SizedBox(
                      height: 0.01.sh,
                    ),
                    TextField(
                      decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.transparent, width: 0.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.transparent, width: 0.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 2),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.2)),
                      controller: homeController.roomTitleController,
                      style: TextStyle(fontSize: 19.sp),
                    ),
                    SizedBox(
                      height: 0.005.sh,
                    ),
                    if (homeController.errorroomtitle.isNotEmpty)
                      Text(
                        homeController.errorroomtitle.value,
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp),
                      ),
                    SizedBox(
                      height: 0.03.sh,
                    ),
                    InkWell(
                      onTap: () async {
                        showProductBottomSheet(context);
                        await productController.getAllroducts(
                            userid: FirebaseAuth.instance.currentUser!.uid);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: kPrimaryColor)),
                        child: Text(
                          "Tag Products +",
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ),
                    if (homeController.roomPickedProduct.isNotEmpty)
                      Wrap(
                        children: homeController.roomPickedProduct
                            .map((element) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 7),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: kPrimaryColor),
                                  child: InkWell(
                                    onTap: () {
                                      homeController.roomPickedProduct.removeAt(
                                          homeController.roomPickedProduct
                                              .indexWhere(
                                                  (e) => e.id == element.id));
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            element.name!,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Icon(
                                          Icons.cancel,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    SizedBox(
                      height: 0.03.sh,
                    ),
                    InkWell(
                      onTap: () async {
                        showChooseChannelBottomSheet(context);
                        await channelController.getAllChannels();
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              showChooseChannelBottomSheet(context);
                              await channelController.getAllChannels();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  select_Channel,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                  ),
                                ),
                                const Icon(
                                  Icons.navigate_next,
                                )
                              ],
                            ),
                          ),
                          Text(select_channel_for_the_tokshow,
                              style: TextStyle(
                                  color: kTextColor, fontSize: 12.sp)),
                        ],
                      ),
                    ),
                    if (homeController.roomPickedChannel.isNotEmpty)
                      Wrap(
                        children: homeController.roomPickedChannel
                            .map((element) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 7),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: kPrimaryColor),
                                  child: InkWell(
                                    onTap: () {
                                      homeController.roomPickedChannel.removeAt(
                                          homeController.roomPickedChannel
                                              .indexWhere(
                                                  (e) => e.id == element.id));
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            element.title!,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        const Icon(
                                          Icons.cancel,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    SizedBox(
                      height: 0.02.sh,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          text_chat,
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                        Switch(
                            activeColor: Colors.white,
                            activeTrackColor: kPrimaryColor,
                            value: (homeController.allowchat.value),
                            onChanged: (value) async {
                              homeController.allowchat.value = value;
                            })
                      ],
                    ),
                    Text(can_audience_send_messages,
                        style: TextStyle(color: kTextColor, fontSize: 12.sp)),
                    SizedBox(
                      height: 0.02.sh,
                    ),
                  ],
                ),
                Obx(() {
                  return Center(
                    child: InkWell(
                        onTap: () async {
                          if (homeController.roomTitleController.text.isEmpty) {
                            homeController.errorroomtitle.value =
                                "Enter name of the tokshow";
                            return;
                          }
                          Get.back();
                          Get.back();
                          await homeController.createRoom();
                          homeController.errorroomtitle.value = "";
                          homeController.roomPickedProduct.value = [];
                        },
                        child: Container(
                          width: 0.8.sw,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: kPrimaryColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: Text(
                                homeController.newRoomType.value == "private"
                                    ? pick_friends_to_chat_with
                                    : go_live,
                                style: TextStyle(
                                    fontSize: 18.sp, color: Colors.white),
                              ),
                            ),
                          ),
                        )),
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
