import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart' as rtcengine;
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtclocalview;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtcremoteview;
import 'package:agora_rtm/agora_rtm.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:tokshop/controllers/auction_controller.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/controllers/chat_controller.dart';
import 'package:tokshop/controllers/checkout_controller.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/controllers/shop_controller.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/models/auction.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/models/tokshow.dart';
import 'package:tokshop/screens/home/create_room.dart';
import 'package:tokshop/screens/products/components/product_list_single_item.dart';
import 'package:tokshop/screens/products/product_details.dart';
import 'package:tokshop/screens/profile/components/profile_image.dart';
import 'package:tokshop/screens/profile/user_profile.dart';
import 'package:tokshop/screens/profile/user_review_dialog.dart';
import 'package:tokshop/screens/room/components/audiences.dart';
import 'package:tokshop/screens/room/components/bids.dart';
import 'package:tokshop/services/auction_api.dart';
import 'package:tokshop/services/dynamic_link_services.dart';
import 'package:tokshop/services/room_api.dart';
import 'package:tokshop/services/user_api.dart';
import 'package:tokshop/utils/configs.dart';
import 'package:tokshop/utils/functions.dart';
import 'package:tokshop/utils/styles.dart';
import 'package:tokshop/widgets/bottom_sheet_dialog.dart';
import 'package:tokshop/widgets/follow_button.dart';
import 'package:tokshop/widgets/text_form_field.dart';
import 'package:tokshop/widgets/widgets.dart';
import 'package:wakelock/wakelock.dart';

import '../../utils/text.dart';

class AgoraMessage {
  String? message;
  String? sender;

  AgoraMessage({this.message, this.sender});
  factory AgoraMessage.fromJson(var json) {
    return AgoraMessage(message: json["message"], sender: json["sender"]);
  }
}

class NewLiveTokshowPage extends StatefulWidget {
  String roomId;
  NewLiveTokshowPage({Key? key, required this.roomId}) : super(key: key);

  @override
  State<NewLiveTokshowPage> createState() => _NewLiveTokshowPageState();
}

class _NewLiveTokshowPageState extends State<NewLiveTokshowPage> {
  final TokShowController _tokshowcontroller = Get.find<TokShowController>();
  final AuctionController auctionController = Get.find<AuctionController>();
  final CheckOutController checkOutController = Get.find<CheckOutController>();

  final ChatController _chatController = Get.find<ChatController>();
  final AuthController authController = Get.find<AuthController>();

  final ShopController shopController = Get.find<ShopController>();

  final OwnerId currentUser = OwnerId(
      id: Get.find<AuthController>().usermodel.value!.id,
      bio: Get.find<AuthController>().usermodel.value!.bio,
      email: Get.find<AuthController>().usermodel.value!.email,
      firstName: Get.find<AuthController>().usermodel.value!.firstName,
      muted: Get.find<AuthController>().usermodel.value!.muted,
      lastName: Get.find<AuthController>().usermodel.value!.lastName,
      userName: Get.find<AuthController>().usermodel.value!.userName,
      agorauid: Get.find<AuthController>().usermodel.value!.agorauid,
      profilePhoto: Get.find<AuthController>().usermodel.value!.profilePhoto);

  final TextEditingController messageController = TextEditingController();
  String agoraId = "";
  String connnectionError = "";

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    agoraId = Get.find<AuthController>().usermodel.value!.agorauid!.toString();

    _initRoom();
  }

  _initRoom() async {
    if (_tokshowcontroller.engine != null) {
      await _tokshowcontroller.leaveAgoraEngine(widget.roomId);
    }
    if (_tokshowcontroller.currentRoom.value.id != null &&
        _tokshowcontroller.currentRoom.value.id !=
            authController.usermodel.value!.currentRoom) {
      await _tokshowcontroller.leaveRoom();
    }

    await _tokshowcontroller.fetchRoom(widget.roomId);
    _chatController.currentChatId.value = widget.roomId;
    _chatController.singleRoomChatStream(widget.roomId);
    if (_tokshowcontroller.currentRoom.value.event == false) {
      initAgora();
      _createClient();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _chatController.roomChatStream.cancel();
  }

  void _createClient() async {
    _tokshowcontroller.client =
        await AgoraRtmClient.createInstance(agoraAppID.trim());
    _tokshowcontroller.client?.onMessageReceived =
        (AgoraRtmMessage message, String peerId) {
      print("Private Message from $peerId: ${message.text}");
    };

    _tokshowcontroller.client?.onConnectionStateChanged =
        (int state, int reason) {
      print('Connection state changed: $state, reason: $reason');
      if (state == 5) {
        _tokshowcontroller.client?.logout();
        print('Logout.');
      }
    };
  }

  void _login() async {
    try {
      var token = await RoomAPI().generateRtmToken(agoraId);
      await _tokshowcontroller.client?.login(token, agoraId);
      print('Login success: ');
      _joinChannel();
    } catch (errorCode) {
      print('Login error: $errorCode');
    }
  }

  void _joinChannel() async {
    String channelId = widget.roomId;
    _tokshowcontroller.rtmChannel = await _createChannel(channelId);
    await _tokshowcontroller.rtmChannel?.join();

    _tokshowcontroller.emitRoom(
        action: "user_joined",
        currentUser: currentUser.toJson(),
        roomId: _tokshowcontroller.currentRoom.value.id!,
        agoraRtmChannel: _tokshowcontroller.rtmChannel);

    _initRoomData();
  }

  void _initRoomData() {
    _chatController.saveToFirestore(
        "${authController.usermodel.value!.firstName!} $joined 👋",
        widget.roomId);
    _tokshowcontroller.activeUsers.clear();
    _tokshowcontroller.activeUsers.addAll(
        _tokshowcontroller.currentRoom.value.userIds!.map((e) => e.agorauid!));

    if (_tokshowcontroller.currentRoom.value.activeauction != null &&
        _tokshowcontroller.currentRoom.value.activeauction!.started == true) {
      if (checkOwner() == true) {
        _startTime(
            _tokshowcontroller.currentRoom.value.activeauction!.startedTime!);
      } else {
        getTimeRemainingAuction(
            _tokshowcontroller.currentRoom.value.activeauction!.startedTime!);
      }
    }

    if ((authController.usermodel.value!.address == null ||
            authController.usermodel.value!.defaultpaymentmethod == null) &&
        checkOwner() == false) {
      showAlert();
    }
  }

  Future<AgoraRtmChannel?> _createChannel(String name) async {
    AgoraRtmChannel? channel =
        await _tokshowcontroller.client?.createChannel(name);
    channel?.onMemberJoined = (AgoraRtmMember member) {
      if (_tokshowcontroller.activeUsers
              .indexWhere((element) => element == int.parse(member.userId)) ==
          -1) {
        _tokshowcontroller.activeUsers.add(int.parse(member.userId));
      }
    };
    channel?.onMemberLeft = (AgoraRtmMember member) {
      _tokshowcontroller.activeUsers
          .removeWhere((element) => element == int.parse(member.userId));
    };
    channel?.onMessageReceived =
        (AgoraRtmMessage message, AgoraRtmMember member) {
      var decodedData = jsonDecode(message.text);
      _tokshowcontroller.roomListeners(
          decodedData,
          member.channelId,
          _tokshowcontroller.client,
          _tokshowcontroller.engine,
          _tokshowcontroller.rtmChannel);
    };
    return channel;
  }

  bool _isReadyPreview = false;

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();
    _tokshowcontroller.engine =
        await RtcEngine.createWithContext(RtcEngineContext(agoraAppID.trim()));

    await _tokshowcontroller.engine
        ?.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _tokshowcontroller.engine?.enableAudioVolumeIndication(250, 10, true);

    await _tokshowcontroller.engine?.setDefaultAudioRouteToSpeakerphone(true);
    await _tokshowcontroller.engine?.enableVideo();
    await _tokshowcontroller.engine?.setVideoEncoderConfiguration(
      VideoEncoderConfiguration(
        dimensions: const VideoDimensions(width: 640, height: 360),
        frameRate: VideoFrameRate.Fps30,
        bitrate: 0,
        orientationMode: VideoOutputOrientationMode.FixedPortrait,
      ),
    );
    await _tokshowcontroller.engine?.startPreview();

    await _tokshowcontroller.engine?.setClientRole(ClientRole.Broadcaster);

    agoraId = Get.find<AuthController>().usermodel.value!.agorauid!.toString();
    setState(() {
      _isReadyPreview = true;
    });
    await _joinTokshow();
    if (FirebaseAuth.instance.currentUser!.uid ==
            _tokshowcontroller.currentRoom.value.ownerId?.id! ||
        (_tokshowcontroller.currentRoom.value.invitedSpeakerIds != null &&
            _tokshowcontroller.currentRoom.value.invitedSpeakerIds!.indexWhere(
                    (element) =>
                        element.id == FirebaseAuth.instance.currentUser!.uid) !=
                -1)) {
      await _tokshowcontroller.engine?.muteLocalAudioStream(false);
      await _tokshowcontroller.engine?.enableAudio();
    } else {
      await _tokshowcontroller.engine
          ?.setClientRole(rtcengine.ClientRole.Audience);
    }
    _tokshowcontroller.audioMuted.value = false;

    _login();
  }

  Future<void> _joinTokshow() async {
    print(_tokshowcontroller.currentRoom.value.token);
    await _tokshowcontroller.engine?.joinChannel(
      _tokshowcontroller.currentRoom.value.token,
      _tokshowcontroller.currentRoom.value.id!,
      null,
      int.parse(agoraId),
    );
    _tokshowcontroller.engine?.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (s, i, ii) {
      print("joinChannelSuccess");
    }, audioVolumeIndication:
            (List<AudioVolumeInfo> speakers, int totalVolume) async {
      if (totalVolume > 2) {
        _tokshowcontroller.writeToDbRoomActive();
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        _tokshowcontroller.commentFieldFocus.value = false;
        _tokshowcontroller.roomChatViewInFocus.value = false;
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: primarycolor,
        body: Obx(
          () => _tokshowcontroller.currentRoom.value.id == null ||
                  _tokshowcontroller.isCurrentRoomLoading.isTrue
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.white,
                ))
              : Stack(
                  children: [
                    if (_tokshowcontroller.currentRoom.value.ownerId!.id ==
                            currentUser.id &&
                        _isReadyPreview)
                      _videoView(const rtclocalview.SurfaceView(
                        mirrorMode: rtcengine.VideoMirrorMode.Auto,
                      )),
                    if (_tokshowcontroller.currentRoom.value.ownerId!.id !=
                            currentUser.id &&
                        _isReadyPreview)
                      _videoView(rtcremoteview.SurfaceView(
                        channelId: _tokshowcontroller.currentRoom.value.id!,
                        uid: _tokshowcontroller
                            .currentRoom.value.ownerId!.agorauid!,
                      )),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                              Colors.black12.withOpacity(0.05),
                              Colors.black.withOpacity(0.4)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter),
                      ),
                      padding:
                          const EdgeInsets.only(top: 60, left: 10, right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.find<UserController>().getUserProfile(
                                        _tokshowcontroller
                                            .currentRoom.value.ownerId!.id!);
                                    Get.to(() => UserProfile());
                                  },
                                  child: Row(
                                    children: [
                                      if (checkOwner() == false)
                                        ProfileImage(
                                          path: _tokshowcontroller.currentRoom
                                              .value.ownerId!.profilePhoto!,
                                          width: 30,
                                          height: 30,
                                        ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      if (checkOwner() == false)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                _tokshowcontroller.currentRoom
                                                    .value.ownerId!.firstName!,
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: Colors.white)),
                                            Row(
                                              children: [
                                                buildProductRatingWidget(userController
                                                                .curentUserReview
                                                                .value ==
                                                            null ||
                                                        userController
                                                            .curentUserReview
                                                            .value!
                                                            .isEmpty
                                                    ? 0.toDouble()
                                                    : userController
                                                            .curentUserReview
                                                            .value!
                                                            .map(
                                                                (e) => e.rating)
                                                            .toList()
                                                            .reduce((value,
                                                                    element) =>
                                                                value +
                                                                element) /
                                                        userController
                                                            .curentUserReview
                                                            .value!
                                                            .length),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                if (userController
                                                    .canreview.value)
                                                  InkWell(
                                                    onTap: () async {
                                                      await showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return UserReviewDialog(
                                                            user: userController
                                                                .currentProfile
                                                                .value,
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 7),
                                                      child: Center(
                                                        child: Text(
                                                          "$rate +",
                                                          style: TextStyle(
                                                              color:
                                                                  kPrimaryColor,
                                                              fontSize: 12.sp),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                if (checkOwner() == false)
                                                  Obx(
                                                    () => FollowUnfollowButton(
                                                      height: 25,
                                                      width: 80,
                                                      callBack: () async {
                                                        if (_tokshowcontroller
                                                                .currentRoom
                                                                .value
                                                                .ownerId!
                                                                .followers!
                                                                .indexWhere((element) =>
                                                                    element ==
                                                                    FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid) !=
                                                            -1) {
                                                          _tokshowcontroller
                                                              .currentRoom
                                                              .value
                                                              .ownerId!
                                                              .followers!
                                                              .removeWhere((element) =>
                                                                  element ==
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid);
                                                          _tokshowcontroller
                                                              .currentRoom
                                                              .refresh();

                                                          await UserAPI().unFollowAUser(
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid,
                                                              _tokshowcontroller
                                                                  .currentRoom
                                                                  .value
                                                                  .ownerId!
                                                                  .id!);
                                                        } else {
                                                          _tokshowcontroller
                                                              .currentRoom
                                                              .value
                                                              .ownerId!
                                                              .followers!
                                                              .add(FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid);
                                                          _tokshowcontroller
                                                              .currentRoom
                                                              .refresh();
                                                          await UserAPI().followAUser(
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid,
                                                              _tokshowcontroller
                                                                  .currentRoom
                                                                  .value
                                                                  .ownerId!
                                                                  .id!);
                                                        }
                                                      },
                                                      bgColor: kPrimaryColor,
                                                      enabled: _tokshowcontroller
                                                              .currentRoom
                                                              .value
                                                              .ownerId!
                                                              .followers!
                                                              .indexWhere((element) =>
                                                                  element ==
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid) ==
                                                          -1,
                                                    ),
                                                  )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              "${_tokshowcontroller.currentRoom.value.ownerId!.followers!.length} $followers",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                          ],
                                        )
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.remove_red_eye_outlined,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Obx(
                                          () => Text(
                                            _tokshowcontroller
                                                .activeUsers.length
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        if (_tokshowcontroller
                                                .currentRoom.value.event ==
                                            true) {
                                          Get.back();
                                          return;
                                        }
                                        if (_tokshowcontroller.currentRoom.value
                                                .ownerId!.id !=
                                            FirebaseAuth
                                                .instance.currentUser!.uid) {
                                          await _tokshowcontroller.leaveTokshow(
                                              currentUser,
                                              _tokshowcontroller
                                                  .currentRoom.value);
                                          Get.back();
                                        } else {
                                          showDialog(
                                            barrierDismissible: false,
                                            context: Get.context!,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(confirmation),
                                                content: const Text(
                                                    sure_want_to_end_tokshow),
                                                actions: [
                                                  TextButton(
                                                    child: const Text(okay),
                                                    onPressed: () async {
                                                      await _tokshowcontroller
                                                          .leaveTokshow(
                                                              currentUser,
                                                              _tokshowcontroller
                                                                  .currentRoom
                                                                  .value);
                                                      Get.back();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text(not_now),
                                                    onPressed: () async {
                                                      Get.back();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      },
                                      child: Text(
                                        _tokshowcontroller.currentRoom.value
                                                        .ownerId!.id ==
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid &&
                                                _tokshowcontroller.currentRoom
                                                        .value.event ==
                                                    false
                                            ? "End Show"
                                            : "Leave",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 45,
                      right: 20,
                      child: Row(
                        children: [
                          Obx(() => _tokshowcontroller
                                      .currentRoom.value.streamOptions!
                                      .indexWhere(
                                          (element) => element == "fb") !=
                                  -1
                              ? Image.asset(
                                  "assets/icons/facebook.png",
                                  width: 30,
                                  color: Colors.white,
                                )
                              : Container()),
                          const SizedBox(
                            width: 5,
                          ),
                          Obx(() => _tokshowcontroller
                                      .currentRoom.value.streamOptions!
                                      .indexWhere(
                                          (element) => element == "yt") !=
                                  -1
                              ? Image.asset(
                                  "assets/icons/youtube.png",
                                  width: 30,
                                )
                              : Container()),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black12.withOpacity(0.01)),
                        padding: const EdgeInsets.only(bottom: 20, left: 20),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => SizedBox(
                                      height: 160,
                                      child: SingleChildScrollView(
                                        reverse: true,
                                        child: ListView(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          children: _chatController
                                              .currentRoomChat
                                              .map((e) => Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 5),
                                                    child: Row(
                                                      children: [
                                                        ProfileImage(
                                                          path: e
                                                              .senderProfileUrl!,
                                                          width: 20,
                                                          height: 20,
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              e.senderName!,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Text(
                                                              e.message,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Obx(
                                  () => Container(
                                    margin: const EdgeInsets.only(right: 20),
                                    child: Column(
                                      children: [
                                        if (_tokshowcontroller.currentRoom.value
                                                    .ownerId!.id ==
                                                currentUser.id &&
                                            _tokshowcontroller
                                                    .currentRoom.value.event ==
                                                false)
                                          InkWell(
                                            onTap: () async {
                                              await _tokshowcontroller.engine
                                                  ?.switchCamera();
                                            },
                                            child: Column(
                                              children: [
                                                const Icon(
                                                  Icons.switch_camera,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  switching,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.sp),
                                                )
                                              ],
                                            ),
                                          ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        // if ((_tokshowcontroller.currentRoom
                                        //             .value.ownerId!.id ==
                                        //         currentUser.id ||
                                        //     _tokshowcontroller.currentRoom.value
                                        //             .allowrecording ==
                                        //         true))
                                        //   InkWell(
                                        //     onTap: () async {
                                        //       await _tokshowcontroller
                                        //           .recordStartStop(
                                        //               context,
                                        //               currentUser,
                                        //               _tokshowcontroller
                                        //                   .currentRoom.value);
                                        //       // if (_tokshowcontroller.currentRoom
                                        //       //         .value.recordingIds!
                                        //       //         .indexWhere((element) =>
                                        //       //             element ==
                                        //       //             authController
                                        //       //                 .usermodel
                                        //       //                 .value!
                                        //       //                 .id
                                        //       //                 .toString()) ==
                                        //       //     -1) {
                                        //       //   await _tokshowcontroller
                                        //       //       .alertStopRecording();
                                        //       // } else {
                                        //       //   await _tokshowcontroller
                                        //       //       .recordStartStop(
                                        //       //           context,
                                        //       //           currentUser,
                                        //       //           _tokshowcontroller
                                        //       //               .currentRoom.value);
                                        //       // }
                                        //     },
                                        //     child: _tokshowcontroller
                                        //                 .currentRoom
                                        //                 .value
                                        //                 .recordingIds!
                                        //                 .indexWhere((element) =>
                                        //                     element ==
                                        //                     authController
                                        //                         .usermodel
                                        //                         .value!
                                        //                         .id
                                        //                         .toString()) !=
                                        //             -1
                                        //         ? Column(
                                        //             children: [
                                        //               Icon(
                                        //                 Icons
                                        //                     .fiber_smart_record,
                                        //                 color: Colors.red,
                                        //               ),
                                        //               const SizedBox(
                                        //                 height: 5,
                                        //               ),
                                        //               Text(
                                        //                 stop_recordind,
                                        //                 style: TextStyle(
                                        //                     color: Colors.white,
                                        //                     fontSize: 10.sp),
                                        //               )
                                        //             ],
                                        //           )
                                        //         : Column(
                                        //             children: [
                                        //               const Icon(
                                        //                 Ionicons.recording,
                                        //                 color: Colors.white,
                                        //                 size: 28,
                                        //               ),
                                        //               const SizedBox(
                                        //                 height: 5,
                                        //               ),
                                        //               Text(
                                        //                 record,
                                        //                 style: TextStyle(
                                        //                     color: Colors.white,
                                        //                     fontSize: 10.sp),
                                        //               )
                                        //             ],
                                        //           ),
                                        //   ),
                                        // const SizedBox(
                                        //   height: 20,
                                        // ),
                                        if (_tokshowcontroller
                                                    .currentRoom.value.event ==
                                                false &&
                                            (_tokshowcontroller.currentRoom
                                                        .value.ownerId!.id ==
                                                    currentUser.id ||
                                                _tokshowcontroller
                                                        .currentRoom
                                                        .value
                                                        .invitedSpeakerIds!
                                                        .indexWhere((element) =>
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid ==
                                                            element.id) !=
                                                    -1))
                                          InkWell(
                                            onTap: () async {
                                              await _tokshowcontroller
                                                  .muteUnMute(currentUser,
                                                      engine: _tokshowcontroller
                                                          .engine,
                                                      rtmChannel:
                                                          _tokshowcontroller
                                                              .rtmChannel);
                                            },
                                            child: Column(
                                              children: [
                                                Icon(
                                                  _tokshowcontroller
                                                          .audioMuted.isFalse
                                                      ? Ionicons.mic
                                                      : Ionicons.mic_off,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  _tokshowcontroller
                                                          .audioMuted.isFalse
                                                      ? mute
                                                      : unmute,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.sp),
                                                )
                                              ],
                                            ),
                                          ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        if (_tokshowcontroller
                                                .currentRoom.value.event ==
                                            false)
                                          InkWell(
                                            onTap: () {
                                              raisedHandsOnClick(context);
                                            },
                                            child: Column(
                                              children: [
                                                Obx(
                                                  () => Stack(
                                                    clipBehavior: Clip.none,
                                                    children: [
                                                      Icon(
                                                        Ionicons
                                                            .hand_left_sharp,
                                                        color: (_tokshowcontroller
                                                                        .currentRoom
                                                                        .value
                                                                        .raisedHands!
                                                                        .indexWhere((element) =>
                                                                            element.id ==
                                                                            FirebaseAuth
                                                                                .instance.currentUser!.uid) !=
                                                                    -1) ||
                                                                ((_tokshowcontroller
                                                                            .currentRoom
                                                                            .value
                                                                            .ownerId!
                                                                            .id ==
                                                                        FirebaseAuth
                                                                            .instance
                                                                            .currentUser!
                                                                            .uid &&
                                                                    _tokshowcontroller
                                                                        .currentRoom
                                                                        .value
                                                                        .raisedHands!
                                                                        .isNotEmpty))
                                                            ? Colors.red
                                                            : _tokshowcontroller
                                                                        .currentRoom
                                                                        .value
                                                                        .event ==
                                                                    true
                                                                ? Colors.grey
                                                                : Colors.white,
                                                        size: 25,
                                                      ),
                                                      if ((_tokshowcontroller
                                                                  .currentRoom
                                                                  .value
                                                                  .ownerId!
                                                                  .id ==
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid &&
                                                          _tokshowcontroller
                                                              .currentRoom
                                                              .value
                                                              .raisedHands!
                                                              .isNotEmpty))
                                                        Positioned(
                                                          top: -10,
                                                          right: -9,
                                                          child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(6),
                                                              decoration: const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Colors
                                                                      .white),
                                                              child: Text(
                                                                _tokshowcontroller
                                                                    .currentRoom
                                                                    .value
                                                                    .raisedHands!
                                                                    .length
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              )),
                                                        )
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "$raise${_tokshowcontroller.currentRoom.value.ownerId!.id == FirebaseAuth.instance.currentUser!.uid ? "d" : ""} $hands",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.sp),
                                                  textAlign: TextAlign.center,
                                                )
                                              ],
                                            ),
                                          ),
                                        if (_tokshowcontroller.currentRoom.value
                                                    .ownerId!.id ==
                                                FirebaseAuth.instance
                                                    .currentUser!.uid &&
                                            _tokshowcontroller
                                                    .currentRoom.value.event ==
                                                false)
                                          const SizedBox(
                                            height: 20,
                                          ),
                                        if (_tokshowcontroller.currentRoom.value
                                                    .ownerId!.id ==
                                                FirebaseAuth.instance
                                                    .currentUser!.uid &&
                                            _tokshowcontroller
                                                    .currentRoom.value.event ==
                                                false)
                                          InkWell(
                                            onTap: () {
                                              showRoomSettingsBottomSheet(
                                                  context);
                                            },
                                            child: Column(
                                              children: [
                                                const Icon(
                                                  Icons.stream,
                                                  color: Colors.white,
                                                  size: 25,
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  stream,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.sp),
                                                  textAlign: TextAlign.center,
                                                )
                                              ],
                                            ),
                                          ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            _tokshowcontroller
                                                .shareSheetLoading.value = true;
                                            await DynamicLinkService()
                                                .generateShareLink(
                                                    _tokshowcontroller
                                                        .currentRoom.value.id!,
                                                    type: "room",
                                                    title:
                                                        "$join ${_tokshowcontroller.currentRoom.value.title} $tokShows",
                                                    msg:
                                                        "$products_being_discussed ${_tokshowcontroller.currentRoom.value.productIds!.map((e) => e.name).toList()}",
                                                    imageurl: _tokshowcontroller
                                                            .currentRoom
                                                            .value
                                                            .productIds![0]
                                                            .images!
                                                            .isNotEmpty
                                                        ? _tokshowcontroller
                                                            .currentRoom
                                                            .value
                                                            .productIds![0]
                                                            .images![0]
                                                        : "")
                                                .then((value) async {
                                              _tokshowcontroller
                                                  .shareSheetLoading
                                                  .value = false;
                                              await Share.share(value);
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              const Icon(
                                                Icons.share,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                share,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10.sp),
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        InkWell(
                                          onTap:
                                              _tokshowcontroller.currentRoom
                                                          .value.event ==
                                                      true
                                                  ? null
                                                  : () {
                                                      showFilterBottomSheet(
                                                          context,
                                                          Column(
                                                            children: [
                                                              const SizedBox(
                                                                height: 20,
                                                              ),
                                                              if (_tokshowcontroller
                                                                      .currentRoom
                                                                      .value
                                                                      .ownerId!
                                                                      .id ==
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid)
                                                                InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    await _tagMoreProducts(
                                                                        context);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        color:
                                                                            kPrimaryColor,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            10),
                                                                    child:
                                                                        const Text(
                                                                      tag_more_products,
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          15),
                                                                  child: Obx(
                                                                    () => _tokshowcontroller
                                                                            .currentRoom
                                                                            .value
                                                                            .productIds!
                                                                            .isEmpty
                                                                        ? const Center(
                                                                            child:
                                                                                Text(
                                                                              no_products_in_your_live_stream,
                                                                              style: TextStyle(color: primarycolor, fontSize: 18),
                                                                            ),
                                                                          )
                                                                        : ListView(
                                                                            children: _tokshowcontroller.currentRoom.value.productIds!
                                                                                .map((e) => ProductListSingleItem(
                                                                                      product: e,
                                                                                      rtmChannel: _tokshowcontroller.rtmChannel,
                                                                                      from: "roompage",
                                                                                    ))
                                                                                .toList(),
                                                                          ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ));
                                                    },
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    border: Border.all(
                                                        color: kPrimaryColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100)),
                                                child: const Icon(
                                                  Icons.shopping_cart,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                              Positioned(
                                                right: 0,
                                                top: -10,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.white),
                                                  child: Text(
                                                    _tokshowcontroller
                                                        .currentRoom
                                                        .value
                                                        .productIds!
                                                        .length
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            if (_tokshowcontroller
                                        .currentRoom.value.allowchat ==
                                    true ||
                                checkOwner() == true)
                              Obx(
                                () => Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 0.5.sw,
                                      decoration: BoxDecoration(
                                          color: Colors.black12,
                                          border:
                                              Border.all(color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, right: 10),
                                          child: FocusScope(
                                            child: Focus(
                                              onFocusChange: (focus) {
                                                _tokshowcontroller
                                                    .commentFieldFocus
                                                    .value = focus;
                                              },
                                              child: TextField(
                                                controller: messageController,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.done,
                                                maxLines: 10,
                                                minLines: 1,
                                                autofocus: false,
                                                decoration: InputDecoration(
                                                  hintText: "$say_something...",
                                                  hintStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11.sp,
                                                  ),
                                                  border: InputBorder.none,
                                                  disabledBorder:
                                                      InputBorder.none,
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                ),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14.sp),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 0.01.sw),
                                    if (_tokshowcontroller
                                            .commentFieldFocus.value ==
                                        true)
                                      InkWell(
                                          onTap: () {
                                            if (messageController
                                                .text.isNotEmpty) {
                                              _chatController.saveToFirestore(
                                                  messageController.text.trim(),
                                                  widget.roomId);
                                              messageController.clear();
                                            }
                                          },
                                          child: Container(
                                            width: 0.12.sw,
                                            height: 0.05.sh,
                                            color: Colors.transparent,
                                            child: const Center(
                                              child: Icon(
                                                Ionicons.send_sharp,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                          )),
                                  ],
                                ),
                              ),
                            Obx(() => _tokshowcontroller
                                        .currentRoom.value.activeauction ==
                                    null
                                ? Container()
                                : _actionWidgetView()),
                            _pinnedWidgetView()
                          ],
                        ),
                      ),
                    ),
                    if (_tokshowcontroller.currentRoom.value.event == true)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Wait for the host to start the show",
                              style:
                                  TextStyle(fontSize: 21, color: Colors.white),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.only(top: 3.0, right: 4.0),
                              child: Text(
                                  date(_tokshowcontroller
                                      .currentRoom.value.eventDate),
                                  style: const TextStyle(
                                      fontSize: 16, color: kPrimaryColor)),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            if (_tokshowcontroller
                                    .currentRoom.value.ownerId!.id ==
                                FirebaseAuth.instance.currentUser!.uid)
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: DefaultButton(
                                  text: "Start tokshow",
                                  press: () async {
                                    await _tokshowcontroller
                                        .createRoomFromEvent(_tokshowcontroller
                                            .currentRoom.value.id!);
                                  },
                                  color: kPrimaryColor,
                                  txtcolor: Colors.white,
                                ),
                              )
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _tagMoreProducts(BuildContext context) async {
    showProductBottomSheet(context, callback: (Product product) {
      if (_tokshowcontroller.currentRoom.value.productIds!
              .indexWhere((element) => element.id == product.id) ==
          -1) {
        _tokshowcontroller.currentRoom.value.productIds!.add(product);
        _tokshowcontroller.currentRoom.refresh();

        RoomAPI().updateRoomById({
          "title": _tokshowcontroller.currentRoom.value.title ?? " ",
          "productIds": [product.id],
          "token": _tokshowcontroller.currentRoom.value.token
        }, _tokshowcontroller.currentRoom.value.id!).then((v) => {
              _tokshowcontroller.sendChannelMessage({"productid": product.id},
                  action: "updateproducts")
            });
      }
      Get.back();
    });
    await productController.getAllroducts(
        userid: FirebaseAuth.instance.currentUser!.uid);
  }

  Future<void> raisedHandsOnClick(BuildContext context) async {
    if ((_tokshowcontroller.currentRoom.value.hostIds!.indexWhere(
            (e) => e.id == FirebaseAuth.instance.currentUser!.uid) !=
        -1)) {
      Audiences(
          context, _tokshowcontroller.rtmChannel, _tokshowcontroller.engine);
    } else {
      if ((_tokshowcontroller.currentRoom.value.raisedHands!.indexWhere(
              (e) => e.id == FirebaseAuth.instance.currentUser!.uid) !=
          -1)) {
        _tokshowcontroller.removeUserFromInvitedSpeakers(currentUser,
            _tokshowcontroller.engine, _tokshowcontroller.rtmChannel);
      } else {
        await _tokshowcontroller.raiseHand(
            context, _tokshowcontroller.rtmChannel);
      }
    }
  }

  _actionWidgetView() {
    Auction? auction = _tokshowcontroller.currentRoom.value.activeauction;
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (auction!.winning != null && auction.ended == false)
            Text(
              "${auction.winning!.firstName} $is_winning",
              style: const TextStyle(
                  color: kPrimaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          if (auction.winner != null && auction.ended == true)
            InkWell(
              onTap: () {
                userController.getUserProfile(auction.winner!.id!);
              },
              child: Text(
                "${auction.winner!.id == FirebaseAuth.instance.currentUser!.uid ? "You" : auction.winner!.firstName} $won",
                style: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  Get.to(() => ProductDetails(product: auction.product));
                },
                child: Text(
                  auction.product.name!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              if (auction.ended == false) const Spacer(),
              if (auction.ended == false)
                Container(
                    margin: const EdgeInsets.only(right: 15),
                    child: Text(auctionController.formatedTimeString.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 30)))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          if (_tokshowcontroller.currentRoom.value.ownerId!.id ==
                  FirebaseAuth.instance.currentUser!.uid &&
              auction.started == false)
            InkWell(
              onTap: () async {
                var startedtime = DateTime.now().millisecondsSinceEpoch;
                _startTime(startedtime);
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: 15, right: 10, bottom: 10),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10)),
                child: const Center(
                  child: Text(
                    start_auction,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          if (_tokshowcontroller.currentRoom.value.ownerId!.id ==
                  FirebaseAuth.instance.currentUser!.uid &&
              auction.started == true)
            InkWell(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(top: 15, right: 10, bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Text(
                      "${auction.bids!.length} $bids, ($highest_bid $currencySymbol${auction.getHighestBid()})",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  )),
              onTap: () {
                BidsView(context);
              },
            ),
          if (_tokshowcontroller.currentRoom.value.ownerId!.id !=
                  FirebaseAuth.instance.currentUser!.uid &&
              auction.ended == false &&
              auction.started == false)
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(top: 15, right: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10)),
              child: const Center(
                child: Text(
                  auction_will_start_soon,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (_tokshowcontroller.currentRoom.value.ownerId!.id !=
                  FirebaseAuth.instance.currentUser!.uid &&
              auction.ended == true)
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(right: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                  color: Styles.textButton.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10)),
              child: const Center(
                child: Text(
                  auction_has_ended,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (_tokshowcontroller.currentRoom.value.ownerId!.id !=
                  FirebaseAuth.instance.currentUser!.uid &&
              auction.started == true)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      margin:
                          const EdgeInsets.only(top: 15, right: 10, bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                          border: Border.all(color: kPrimaryColor),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Center(
                        child: Text(
                          custom,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                  onTap: () async {
                    showModalBottomSheet(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25.0))),
                        backgroundColor: Color(0Xfff4f5fa),
                        context: Get.context!,
                        isScrollControlled: true,
                        builder: (context) => Padding(
                              padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(Get.context!)
                                      .viewInsets
                                      .bottom),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      provide_custom_bid,
                                      style: TextStyle(
                                          color: primarycolor, fontSize: 18.sp),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(enter_price,
                                            style: TextStyle(
                                                color: primarycolor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.sp)),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        CustomTextFormField(
                                          controller:
                                              auctionController.custombidprice,
                                          txtType: TextInputType.number,
                                          txtColor: primarycolor,
                                          prefix: Text(
                                            currencySymbol,
                                            style: const TextStyle(
                                                color: primarycolor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Center(
                                      child: InkWell(
                                        onTap: () {
                                          if (int.parse(auctionController
                                                  .custombidprice.text) <
                                              auction.getNextAmountBid()) {
                                            Get.snackbar("",
                                                "$you_can_not_bid_less_than $currencySymbol${auction.getNextAmountBid()}",
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white);
                                            return;
                                          }
                                          if (authController.usermodel.value!
                                                      .address ==
                                                  null ||
                                              authController.usermodel.value!
                                                      .defaultpaymentmethod ==
                                                  null) {
                                            showAlert();
                                          } else {
                                            auctionController.bid(
                                                currentUser,
                                                int.parse(auctionController
                                                    .custombidprice.text));
                                            Get.back();
                                          }
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 40, vertical: 10),
                                          decoration: BoxDecoration(
                                              color: primarycolor,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Center(
                                            child: Text(
                                              bid,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.sp),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ));
                  },
                ),
                InkWell(
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      margin:
                          const EdgeInsets.only(top: 15, right: 15, bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(
                        child: Text(
                          "$bid_with \$${auction.getNextAmountBid().toString()}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                  onTap: () async {
                    if (authController.usermodel.value!.address == null ||
                        authController.usermodel.value!.defaultpaymentmethod ==
                            null) {
                      showAlert();
                    } else {
                      auctionController.bid(
                          currentUser, auction.getNextAmountBid());
                    }
                  },
                ),
              ],
            ),
          if (_tokshowcontroller.checkIfhavebid(currentUser))
            Center(
              child: Text(
                "$your_bid $currencySymbol${auction.getCurrentUserBid().amount}",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
        ],
      ),
    );
  }

  void _startTime(int startedtime) async {
    var timedifference = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(startedtime))
        .inSeconds;
    _tokshowcontroller.currentRoom.value.activeauction!.duration =
        _tokshowcontroller.currentRoom.value.activeauction!.duration -
            timedifference;

    _tokshowcontroller.currentRoom.value.activeauction!.started = true;
    _tokshowcontroller.currentRoom.value.activeauction!.startedTime =
        startedtime;

    await _tokshowcontroller.emitRoom(
        action: "start_auction",
        currentUser: currentUser.toJson(),
        otherdata: {
          "started": true,
          "startedTime": startedtime,
        },
        roomId: _tokshowcontroller.currentRoom.value.id!,
        extra: true,
        agoraRtmChannel: _tokshowcontroller.rtmChannel);
    Get.find<AuctionController>().startTimer();

    AuctinAPI().updateAuction(
        _tokshowcontroller.currentRoom.value.activeauction!.id!, {
      "started": true,
      "startedTime": startedtime,
    }).then((value) {
      _tokshowcontroller.currentRoom.value.activeauction =
          Auction.fromJson(value);
    });
  }

  void getTimeRemainingAuction(int startedtime) {
    var timedifference = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(startedtime))
        .inSeconds;
    _tokshowcontroller.currentRoom.value.activeauction!.duration =
        _tokshowcontroller.currentRoom.value.activeauction!.duration -
            timedifference;
    Get.find<AuctionController>().startTimer();
  }

  _pinnedWidgetView() {
    return Obx(
      () => _tokshowcontroller.currentRoom.value.pinned == null
          ? Container()
          : Container(
              height:
                  _tokshowcontroller.currentRoom.value.pinned != null ? 40 : 0,
              margin: const EdgeInsets.only(top: 25),
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  Get.to(() => ProductDetails(
                      product: _tokshowcontroller.currentRoom.value.pinned!));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _tokshowcontroller.currentRoom.value.pinned!.name!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            if (_tokshowcontroller
                                    .currentRoom.value.ownerId!.id ==
                                FirebaseAuth.instance.currentUser!.uid) {
                              _tokshowcontroller.removePinned();
                            }
                          },
                          child: const Icon(
                            Icons.push_pin_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<dynamic> showRoomSettingsBottomSheet(BuildContext context) async {
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
              initialChildSize: 0.62,
              expand: false,
              builder: (BuildContext productContext,
                  ScrollController scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Container(
                        height: 0.01.sh,
                        width: 0.15.sw,
                        decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(20.0)),
                      ),
                      SizedBox(
                        height: 0.02.sh,
                      ),
                      Text(
                        "Room settings",
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      SizedBox(
                        height: 0.01.sh,
                      ),
                      Obx(() {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Text Chat",
                                    style: TextStyle(fontSize: 16.sp),
                                  ),
                                  Switch(
                                      activeColor: kPrimaryColor,
                                      activeTrackColor:
                                          kPrimaryColor.withOpacity(0.50),
                                      value: (_tokshowcontroller
                                          .currentRoom.value.allowchat!),
                                      onChanged: (value) async {
                                        _tokshowcontroller.currentRoom.value
                                            .allowchat = value;
                                        _tokshowcontroller.currentRoom
                                            .refresh();
                                        await _tokshowcontroller.emitRoom(
                                            action: "allow_chat",
                                            currentUser: currentUser.toJson(),
                                            extra: _tokshowcontroller
                                                .currentRoom.value.allowchat,
                                            roomId: _tokshowcontroller
                                                .currentRoom.value.id!);
                                        await RoomAPI().updateRoomId(
                                            {
                                              "allowchat": _tokshowcontroller
                                                  .currentRoom.value.allowchat
                                            },
                                            _tokshowcontroller
                                                .currentRoom.value.id!);
                                      })
                                ],
                              ),
                            ),
                            Text(
                                "allow people to chat in the talkshow discussion?",
                                style: TextStyle(
                                    color: kTextColor, fontSize: 12.sp)),
                            SizedBox(
                              height: 0.02.sh,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Youtube Live Stream",
                                    style: TextStyle(fontSize: 16.sp),
                                  ),
                                  Switch(
                                      activeColor: kPrimaryColor,
                                      activeTrackColor:
                                          kPrimaryColor.withOpacity(0.50),
                                      value: (_tokshowcontroller
                                              .currentRoom.value.streamOptions!
                                              .indexWhere((element) =>
                                                  element == "yt") !=
                                          -1),
                                      onChanged: (value) async {
                                        if (value) {
                                          await _tokshowcontroller
                                              .addToStreamOptions("yt");
                                          _tokshowcontroller.currentRoom
                                              .refresh();
                                        } else {
                                          _tokshowcontroller
                                              .currentRoom.value.streamOptions!
                                              .removeWhere(
                                                  (element) => element == "yt");
                                          _tokshowcontroller.currentRoom
                                              .refresh();
                                          _tokshowcontroller
                                              .leaveStreamChannels("yt");
                                          await RoomAPI().updateRoomId(
                                              {
                                                "streamOptions":
                                                    _tokshowcontroller
                                                        .currentRoom
                                                        .value
                                                        .streamOptions
                                              },
                                              _tokshowcontroller
                                                  .currentRoom.value.id!);
                                        }
                                      })
                                ],
                              ),
                            ),
                            Text(
                                "your tokshow will be broadcasted to your youtube channel",
                                style: TextStyle(
                                    color: kTextColor, fontSize: 12.sp)),
                            SizedBox(
                              height: 0.02.sh,
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Allow Facebook Live",
                                    style: TextStyle(fontSize: 16.sp),
                                  ),
                                  Switch(
                                      activeColor: kPrimaryColor,
                                      activeTrackColor:
                                          kPrimaryColor.withOpacity(0.50),
                                      value: (_tokshowcontroller
                                              .currentRoom.value.streamOptions!
                                              .indexWhere((element) =>
                                                  element == "fb") !=
                                          -1),
                                      onChanged: (value) async {
                                        if (value) {
                                          await _tokshowcontroller
                                              .addToStreamOptions("fb");
                                          _tokshowcontroller.currentRoom
                                              .refresh();
                                        } else {
                                          _tokshowcontroller
                                              .currentRoom.value.streamOptions!
                                              .removeWhere(
                                                  (element) => element == "fb");
                                          _tokshowcontroller.currentRoom
                                              .refresh();
                                          await _tokshowcontroller
                                              .leaveStreamChannels("fb");
                                          await RoomAPI().updateRoomId(
                                              {
                                                "streamOptions":
                                                    _tokshowcontroller
                                                        .currentRoom
                                                        .value
                                                        .streamOptions
                                              },
                                              _tokshowcontroller
                                                  .currentRoom.value.id!);
                                        }
                                      })
                                ],
                              ),
                            ),
                            Text(
                                "your tokshow will be broadcasted to your facebook timeline",
                                style: TextStyle(
                                    color: kTextColor, fontSize: 12.sp)),
                          ],
                        );
                      })
                    ],
                  ),
                );
              });
        });
      },
    );
  }
}

checkOwner() =>
    FirebaseAuth.instance.currentUser!.uid ==
    Get.find<TokShowController>().currentRoom.value.ownerId!.id;
Widget _videoView(view) {
  return Container(child: view);
}

showAlert() {
  showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      backgroundColor: const Color(0Xfff4f5fa),
      context: Get.context!,
      isScrollControlled: true,
      builder: (context) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: Text(
                      to_purchase_live_tokshows_need_payment,
                      style: TextStyle(color: primarycolor, fontSize: 18.sp),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    welcome_to_tokshow_in_order_to_bid_on_auctions,
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      purchaseInfo();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      decoration: BoxDecoration(
                          color: primarycolor,
                          borderRadius: BorderRadius.circular(15)),
                      child: Center(
                        child: Text(
                          add_info,
                          style:
                              TextStyle(color: Colors.white, fontSize: 13.sp),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ));
}
