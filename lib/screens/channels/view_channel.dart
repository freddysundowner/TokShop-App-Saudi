import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share/share.dart';
import 'package:tokshop/models/tokshow.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/channel_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/user.dart';
import '../../services/dynamic_link_services.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';

//ignore: must_be_immutable
class ViewChannel extends StatelessWidget {
  bool keyboardup = false;
  final ScrollController _scrollController = ScrollController();
  int loadMoreMsgs = 20; // at first it will load only 25
  bool loadingmore = false,
      moreusers = true,
      loading = false,
      mainloading = false;
  Map<List<UserModel>, dynamic> allData = {};

  final picker = ImagePicker();
  late StreamSubscription<DocumentSnapshot> channelliten;
  ChannelController interestsController = Get.find<ChannelController>();
  final UserController _userController = Get.find<UserController>();

  int tabindex = 0;

  dynamic last;
  late String channelid;

  List<List<String>> options = [
    ["hide", "Hide Members List"],
    ["description", "Edit Description"],
    ["leave", "Leave Channel"],
  ];

  ViewChannel({Key? key}) : super(key: key);

  Future<void> leaveChannel() async {
    interestsController.channelLoading.value = true;
    await interestsController
        .leaveChannel(interestsController.currentChannel.value);

    _userController.currentProfile.value.interests.removeWhere(
        (element) => element.id == interestsController.currentChannel.value.id);
    Get.find<AuthController>().usermodel.value!.interests.removeWhere(
        (element) => element.id == interestsController.currentChannel.value.id);

    _userController.currentProfile.refresh();
    Get.find<AuthController>().usermodel.refresh();

    interestsController.channelLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        color: const Color(0Xfff4f5fa),
        child: interestsController.channelLoading.isTrue
            ? const Center(
                child: CircularProgressIndicator(
                  color: primarycolor,
                ),
              )
            : Stack(
                children: [
                  if (loadingmore)
                    const Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: CircularProgressIndicator(),
                        )),
                  SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Scaffold(
                        backgroundColor: const Color(0Xfff4f5fa),
                        appBar: AppBar(
                          backgroundColor: const Color(0Xfff4f5fa),
                          leading: InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: const Icon(
                              Icons.arrow_back,
                              size: 25,
                              color: primarycolor,
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  icon: const Icon(
                                    Icons.share,
                                    size: 25,
                                    color: primarycolor,
                                  ),
                                  onPressed: () {
                                    DynamicLinkService()
                                        .generateShareLink(
                                            interestsController
                                                .currentChannel.value.id
                                                .toString(),
                                            type: "channel")
                                        .then((value) async {
                                      await Share.share(value,
                                          subject:
                                              "$share ${interestsController.currentChannel.value.title!} channel");
                                    });
                                  }),
                            ],
                          ),
                        ),
                        body: Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          child: interestsController.currentChannel.value.id !=
                                  null
                              ? ListView(
                                  controller: _scrollController,
                                  shrinkWrap: true,
                                  children: [
                                    SizedBox(
                                      height: 0.04.sh,
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            interestsController
                                                .currentChannel.value.title
                                                .toString()
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                              color: primarycolor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 0.01.sh,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 0.03.sh,
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.online_prediction,
                                          color: Colors.red,
                                          size: 15,
                                        ),
                                        Text(
                                            " ${interestsController.currentChannel.value.rooms!.length} $tokshow_live_now",
                                            style: TextStyle(
                                              color: kPrimaryColor,
                                              fontSize: 11.sp,
                                            ))
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    if (interestsController
                                            .currentChannel.value.ownerid !=
                                        Get.find<AuthController>()
                                            .currentuser!
                                            .id)
                                      Obx(() {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            interestsController.currentChannel
                                                        .value.members!
                                                        .indexWhere((element) =>
                                                            element ==
                                                            Get.find<
                                                                    AuthController>()
                                                                .currentuser
                                                                ?.id) >
                                                    -1
                                                ? Row(
                                                    children: [
                                                      InkWell(
                                                        onTap: () async {
                                                          await interestsController
                                                              .leaveChannel(
                                                                  interestsController
                                                                      .currentChannel
                                                                      .value);
                                                        },
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 30),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      30,
                                                                  vertical: 10),
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              border: Border.all(
                                                                  color: primarycolor
                                                                      .withOpacity(
                                                                          0.5)),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25)),
                                                          child: Text(
                                                            unsubscribe,
                                                            style: TextStyle(
                                                                fontSize: 11.sp,
                                                                color:
                                                                    primarycolor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 0.04.sw,
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          // channelController
                                                          //     .showInviteFriendsBottomSheet(
                                                          //         context);
                                                        },
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 30),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      30,
                                                                  vertical: 10),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                              color:
                                                                  primarycolor),
                                                          child: Text(
                                                            invite_friends,
                                                            style: TextStyle(
                                                                fontSize: 11.sp,
                                                                color: Colors
                                                                    .white,
                                                                fontFamily:
                                                                    "InterSemiBold"),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : InkWell(
                                                    onTap: () async {
                                                      if (interestsController
                                                              .currentChannel
                                                              .value
                                                              .members!
                                                              .indexWhere((element) =>
                                                                  element ==
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid) ==
                                                          -1) {
                                                        await interestsController
                                                            .joinChannel(
                                                                interestsController
                                                                    .currentChannel
                                                                    .value);
                                                      } else {
                                                        await interestsController
                                                            .leaveChannel(
                                                                interestsController
                                                                    .currentChannel
                                                                    .value);
                                                      }
                                                    },
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 30),
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 40,
                                                          vertical: 10),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          color: primarycolor),
                                                      child: Text(
                                                        subscribe,
                                                        style: TextStyle(
                                                            fontSize: 11.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        );
                                      }),
                                    SizedBox(
                                      height: 0.02.sh,
                                    ),
                                    SizedBox(
                                      height: 0.01.sh,
                                    ),
                                    interestsController
                                            .currentChannel.value.rooms!.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              no_live_tokshows_in_channel,
                                              style: TextStyle(
                                                  color: primarycolor,
                                                  fontSize: 14.sp),
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const ClampingScrollPhysics(),
                                            itemCount: interestsController
                                                .currentChannel
                                                .value
                                                .rooms!
                                                .length,
                                            itemBuilder: (context, index) {
                                              Tokshow roomModel =
                                                  interestsController
                                                      .currentChannel
                                                      .value
                                                      .rooms!
                                                      .elementAt(index);
                                              var hosts = [];
                                              hosts =
                                                  roomModel.hostIds!.length > 10
                                                      ? roomModel.hostIds!
                                                          .sublist(0, 10)
                                                      : roomModel.hostIds!;
                                              roomModel.channel!.add(
                                                  interestsController
                                                      .currentChannel.value);
                                              return Container();
                                              // return HomePage()
                                              //     .roomCard(roomModel, hosts);
                                            })
                                  ],
                                )
                              : Center(
                                  child: Text(
                                    channel_not_found,
                                    style: TextStyle(
                                        color: primarycolor, fontSize: 12.sp),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      );
    });
  }
}
