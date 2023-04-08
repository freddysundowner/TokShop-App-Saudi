import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tokshop/controllers/auction_controller.dart';
import 'package:tokshop/controllers/shop_controller.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/models/auction.dart';
import 'package:tokshop/models/channel.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';

import 'package:agora_rtm/agora_rtm.dart';
import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/screens/auth/welcome_screen.dart';
import 'package:tokshop/screens/payments/payout_settings.dart';
import 'package:tokshop/screens/profile/components/profile_image.dart';
import 'package:tokshop/screens/profile/profile_all_products.dart';
import 'package:tokshop/screens/room/create_show_dialog.dart';
import 'package:tokshop/screens/room/live_tokshows.dart';
import 'package:tokshop/screens/shops/apply_to_sell.dart';
import 'package:tokshop/services/auction_api.dart';
import 'package:tokshop/services/notifications_api.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';
import '../models/upcoming_tokshow.dart';
import '../models/product.dart';
import '../models/recording.dart';
import '../models/tokshow.dart';
import '../models/user.dart';
import '../screens/home/main_page.dart';
import '../screens/room/components/invited_friends.dart';
import '../services/client.dart';
import '../services/end_points.dart';
import '../services/recordings_api.dart';
import '../services/room_api.dart';
import '../services/user_api.dart';
import '../utils/text.dart';
import '../utils/utils.dart';
import 'auth_controller.dart';
import 'chat_controller.dart';

import 'package:agora_rtc_engine/rtc_engine.dart' as rtcengine;

class TokShowController extends FullLifeCycleController
    with GetTickerProviderStateMixin {
  AgoraRtmClient? client;
  rtcengine.RtcEngine? engine;
  AgoraRtmChannel? rtmChannel;
  FirebaseFirestore db = FirebaseFirestore.instance;
  RxList<int> activeUsers = RxList([]);
  var onChatPage = false.obs;
  var roomPageInitialPage = 1.obs;
  late PageController pageController;
  var onTokShowChatPage = false.obs;
  var inAppProducts = [].obs;
  dynamic videoPlayerController;

  dynamic chewieController;
  var videoPlaying = false.obs;
  var expandableFabOpen = false.obs;
  late AnimationController expandableFabAnimationController;
  var tabIndex = 0.obs;
  Rxn<TabController> tabController = Rxn(null);

  var hideProduct = false.obs;
  var currentProfile = "".obs;
  var profileLoading = false.obs;
  var isLoading = false.obs;
  var isSwitched = false.obs;
  var allowchat = true.obs;
  var isCurrentRoomLoading = false.obs;
  RxList<Tokshow> allroomsList = RxList([]);
  RxList<Tokshow> userRoomsList = RxList([]);
  RxList<Tokshow> channelRoomsList = RxList([]);
  RxList<UpcomingTokshow> myUpcomingEvents = RxList([]);
  RxList<UpcomingTokshow> allUpcomingEvents = RxList([]);
  var myChannelRoomList = [].obs;
  var currentRoom = Tokshow().obs;
  var currentRecordedRoom = Tokshow().obs;
  var isCurrentRecordedRoomLoading = false.obs;
  var isCreatingRoom = false.obs;
  var newRoom = Tokshow().obs;
  var toInviteUsers = [].obs;
  var audioMuted = true.obs;
  var shareSheetLoading = false.obs;
  var shareLinkLoading = false.obs;

  var newRoomTitle = " ".obs;
  Rxn<DateTime> eventDate = Rxn<DateTime>(null);
  var resourceIdV = "".obs;
  var resourceSid = "".obs;
  var recordinguid = "".obs;
  var errorroomtitle = "".obs;
  var errorRoomDiscount = "".obs;
  var newRoomType = "public".obs;
  var selectedEvents = "all".obs;
  var allowrecording = false.obs;
  var agoraToken = "".obs;
  var users = [].obs;
  var commentFieldFocus = false.obs;
  var roomChatViewInFocus = false.obs;

  var roomPickedProduct = [].obs;
  RxList<Channel> roomPickedChannel = RxList([]);

  var roomHosts = <UserModel>[].obs;
  var roomOriginalHosts = [].obs;
  var roomShopId = "".obs;
  var roomProductImages = [].obs;

  var userJoinedRoom = false.obs;
  var isSearching = false.obs;
  var roomsPageNumber = 0.obs;
  final roomsScrollController = ScrollController();

  var roomPickedImages = [].obs;
  var peopleTalkingInRoom = 0.obs;
  var userBeingMoved = "".obs;

  TextEditingController roomTitleController = TextEditingController();
  TextEditingController eventTitleController = TextEditingController();
  TextEditingController eventDateController = TextEditingController();
  TextEditingController eventDescriptiion = TextEditingController();
  TextEditingController roomProductDiscount = TextEditingController();

  final ChatController _chatController =
      Get.put<ChatController>(ChatController());
  final UserController userController =
      Get.put<UserController>(UserController());
  final AuctionController auctionController =
      Get.put<AuctionController>(AuctionController());

  void onResumed() async {
    if (currentRoom.value.id != null &&
        currentRoom.value.ownerId!.id ==
            FirebaseAuth.instance.currentUser!.uid) {
      engine?.muteLocalVideoStream(false);
      engine?.enableLocalVideo(true);
      engine?.enableVideo();
    }
  }

  dynamic headers;
  @override
  void onClose() {
    leaveRoomWhenKilled();
    disposeVideoPlayer();
    super.onClose();
  }

  @override
  void onInit() {
    tabController.value = TabController(
      initialIndex: tabIndex.value,
      length: 3,
      vsync: this,
    );
    super.onInit();

    scrollControllerListener();
  }

  sendChannelMessage(Map<dynamic, dynamic> user,
      {String action = "",
      bool extra = false,
      AgoraRtmChannel? rtmChannell,
      String? roomId,
      Map<dynamic, dynamic>? otherdata}) async {
    try {
      await rtmChannel?.sendMessage(AgoraRtmMessage.fromText(jsonEncode({
        "action": action,
        "userData": user,
        "otherdata": otherdata,
        "roomId": currentRoom.value.id,
        "extra": extra
      })));
    } catch (errorCode) {
      printOut('Send channel message error: $errorCode');
    }
  }

  void roomListeners(decodedData, String roomId, AgoraRtmClient? rtmClient,
      RtcEngine? engine, AgoraRtmChannel? rtmChannel) {
    OwnerId currentUser = OwnerId(
        id: Get.find<AuthController>().usermodel.value!.id,
        bio: Get.find<AuthController>().usermodel.value!.bio,
        email: Get.find<AuthController>().usermodel.value!.email,
        firstName: Get.find<AuthController>().usermodel.value!.firstName,
        lastName: Get.find<AuthController>().usermodel.value!.lastName,
        userName: Get.find<AuthController>().usermodel.value!.userName,
        profilePhoto: Get.find<AuthController>().usermodel.value!.profilePhoto);

    if (decodedData["roomId"] == roomId) {
      var user = OwnerId.fromJson(decodedData["userData"]);
      if (decodedData["action"] == "bid") {
        Bid bid = Bid.fromJson(decodedData["otherdata"]);
        int i = currentRoom.value.activeauction!.bids!
            .indexWhere((element) => element.bidder.id == user.id);
        if (i != -1) {
          currentRoom.value.activeauction!.bids![i] = bid;
        } else {
          currentRoom.value.activeauction!.bids!.add(bid);
        }
        currentRoom.refresh();
      } else if (decodedData["action"] == "updateproducts") {
        var product = decodedData["userData"];
        if (product["productid"] != null) {
          if (currentRoom.value.activeauction != null &&
              product["productid"] ==
                  currentRoom.value.activeauction!.product.id) {
            currentRoom.value.activeauction = null;
          }
          fetchRoom(roomId).then((value) {
            currentRoom.refresh();
          });
        }
      } else if (decodedData["action"] == "pinned") {
        var product = decodedData["userData"];
        if (product["productid"] != null) {
          auctionController.formatedTimeString.value = "00:00";
          auctionController.removeAuction();
          if (currentRoom.value.pinned == null) {
            int i = currentRoom.value.productIds!
                .indexWhere((element) => element.id == product["productid"]);
            //if product doesnt not exist in the room products, fetch room data again
            if (i == -1) {
              fetchRoom(roomId).then((value) {
                int i = currentRoom.value.productIds!.indexWhere(
                    (element) => element.id == product["productid"]);
                currentRoom.value.pinned = currentRoom.value.productIds![i];
                currentRoom.refresh();
              });
            } else {
              currentRoom.value.pinned = currentRoom.value.productIds![i];
              currentRoom.refresh();
            }
          } else {
            currentRoom.refresh();
          }
        }
      } else if (decodedData["action"] == "activeauction") {
        var product = decodedData["userData"];
        var otherdata = decodedData["otherdata"];
        if (product["productid"] != null) {
          auctionController.formatedTimeString.value = "00:00";
          currentRoom.value.pinned = null;

          int i = currentRoom.value.productIds!
              .indexWhere((element) => element.id == product["productid"]);
          //if product doesnt not exist in the room products, fetch room data again
          if (i == -1) {
            fetchRoom(roomId).then((value) {
              currentRoom.refresh();
            });
          } else {
            otherdata["product"] = currentRoom.value.productIds![i].toJson();
            currentRoom.value.activeauction = Auction.fromJson(otherdata);
            currentRoom.refresh();
          }

          AuctinAPI().getAuctionsByRoomId(roomId).then((value) {
            Auction auction = Auction.fromJson(value);
            print(auction.ended);
            currentRoom.value.activeauction = auction;
            currentRoom.refresh();
          });
        }
      } else if (decodedData["action"] == "removepinned") {
        var product = decodedData["userData"];
        if (product["productid"] != null) {
          currentRoom.value.pinned = null;
          currentRoom.refresh();
        }
      } else if (decodedData["action"] == "removeauction") {
        auctionController.formatedTimeString.value = "00:00";
        auctionController.timer.cancel();
        currentRoom.value.activeauction!.ended = true;
        currentRoom.value.activeauction!.started = false;
        currentRoom.value.activeauction?.winner =
            findWinner(currentRoom.value.activeauction)?.bidder;
        currentRoom.refresh();
      } else if (decodedData["action"] == "streaming") {
        var option = decodedData["otherdata"]["option"];
        currentRoom.value.streamOptions!.add(option);
        currentRoom.refresh();
      } else if (decodedData["action"] == "stopstreaming") {
        var option = decodedData["otherdata"]["option"];
        currentRoom.value.streamOptions!.remove(option);
        currentRoom.refresh();
      } else if (decodedData["action"] == "leave") {
        try {
          currentRoom.value.userIds!
              .removeWhere((element) => element.id == user.id);
          currentRoom.value.speakerIds!
              .removeWhere((element) => element.id == user.id);
          currentRoom.value.hostIds!
              .removeWhere((element) => element.id == user.id);
          currentRoom.value.invitedSpeakerIds!
              .removeWhere((element) => element.id == user.id);
          currentRoom.value.raisedHands!
              .removeWhere((element) => element.id == user.id);
          activeUsers.removeWhere((element) => element == user.agorauid);
          if (user.id == currentRoom.value.ownerId?.id) {
            leaveAgoraEngine(currentRoom.value.id!).then((value) {
              showDialog(
                barrierDismissible: false,
                context: Get.context!,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(tokshow_is_over),
                    content: const Text(this_tokshow_has_been_closed),
                    actions: [
                      TextButton(
                        child: const Text(okay),
                        onPressed: () {
                          Get.offAll(() => MainPage());
                          currentRoom.value = Tokshow();
                          currentRoom.refresh();
                        },
                      ),
                    ],
                  );
                },
              );
            });
          }
        } catch (e, s) {
          printOut("Error removing user who has left from controller $e $s");
        }
        currentRoom.refresh();
      } else if (decodedData["action"] == "room_ended") {
        Get.snackbar('', room_ended,
            backgroundColor: kPrimaryColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 2));

        Future.delayed(const Duration(seconds: 3), () {
          currentRoom.value = Tokshow();
          Get.offAll(MainPage());
        });
        _chatController.currentRoomChat.value = [];
        _chatController.currentChatId.value = "";
      } else if (decodedData["action"] == "add_speaker") {
        user.muted = true;

        //Tell user that they have been added to speaker and update room by adding user to speaker, removing them from raised hands, and from audience
        if (user.id == currentUser.id) {
          currentRoom.value.invitedSpeakerIds!.add(user);
          currentRoom.refresh();
          engine?.setClientRole(ClientRole.Broadcaster);
          engine?.enableLocalVideo(false);
          engine?.enableAudio();
          engine?.muteRemoteAudioStream(
              Get.find<AuthController>().usermodel.value!.agorauid!, true);
          engine?.enableLocalAudio(false);
          audioMuted.value = true;
          Get.find<AuthController>().usermodel.value!.muted = true;
          engine?.muteLocalAudioStream(true);
          audioMuted.refresh();
          Get.snackbar('', added_to_speaker,
              backgroundColor: kPrimaryColor,
              colorText: Colors.white,
              duration: const Duration(seconds: 2));

          //Add user to invited speakers
          RoomAPI().updateRoomId({
            "invitedSpeakerIds": [user.id],
          }, currentRoom.value.id!);
        }
      } else if (decodedData["action"] == "remove_speaker") {
        currentRoom.value.invitedSpeakerIds!
            .removeWhere((element) => element.id == user.id);

        if (user.id == currentUser.id) {
          audioMuted.value = true;
          Get.find<AuthController>().usermodel.value!.muted = true;
          engine?.muteLocalAudioStream(true);
          audioMuted.refresh();
          Get.snackbar('', removed_from_speaking,
              backgroundColor: kPrimaryColor,
              colorText: Colors.white,
              duration: const Duration(seconds: 2));
        }
      } else if (decodedData["action"] == "added_raised_hands") {
        if ((currentRoom.value.raisedHands!
                .indexWhere((element) => element.id == user.id) ==
            -1)) {
          //Show snackBar to the hosts of the room
          Get.snackbar('', '${user.firstName} $has_raised_their_hand',
              backgroundColor: kPrimaryColor,
              colorText: Colors.white,
              duration: const Duration(seconds: 2));
          //Add user to raised hands
          currentRoom.value.raisedHands!.add(user);
          currentRoom.refresh();
        }
      } else if (decodedData["action"] == "muted") {
        var extra = decodedData["extra"];
        if (currentRoom.value.invitedSpeakerIds!
                .indexWhere((element) => element.id == user.id) !=
            -1) {
          currentRoom.value.invitedSpeakerIds!
              .elementAt(currentRoom.value.invitedSpeakerIds!
                  .indexWhere((element) => element.id == user.id))
              .muted = extra;
          currentRoom.refresh();
        }
        if (currentRoom.value.raisedHands!
                .indexWhere((element) => element.id == user.id) !=
            -1) {
          currentRoom.value.raisedHands!
              .elementAt(currentRoom.value.raisedHands!
                  .indexWhere((element) => element.id == user.id))
              .muted = extra;
          currentRoom.refresh();
        }
      } else if (decodedData["action"] == "allow_chat") {
        var extra = decodedData["extra"];

        currentRoom.value.allowchat = extra;

        currentRoom.refresh();
      } else if (decodedData["action"] == "allow_recording") {
        var extra = decodedData["extra"];

        currentRoom.value.allowrecording = extra;

        currentRoom.refresh();
      } else if (decodedData["action"] == "invite_speaker") {
        if (user.id == FirebaseAuth.instance.currentUser!.uid) {
          speakerInvitedAlert(user, rtmChannel!);
        }
        currentRoom.refresh();
      } else if (decodedData["action"] == "remove_invited_speaker") {
        currentRoom.value.invitedSpeakerIds!
            .removeWhere((element) => element.id == user.id);
        currentRoom.value.raisedHands!
            .removeWhere((element) => element.id == user.id);
        currentRoom.refresh();
      } else if (decodedData["action"] == "start_auction") {
        currentRoom.value.activeauction!.started = true;
        currentRoom.value.activeauction!.startedTime =
            decodedData["otherdata"]["startedTime"];
        print(currentRoom.value.activeauction!.ended);

        auctionController.startTimer();
        currentRoom.refresh();
      } else if (decodedData["action"] == "wonalert") {
        Auction auction = Auction.fromJson(decodedData["otherdata"]);
        wornUi(Get.context!, auction.winner!);
      } else if (decodedData["action"] == "stop_auction") {
        auctionController.timer.cancel();
      } else if (decodedData["action"] == "remote_muted") {
        var extra = decodedData["extra"];
        if (currentRoom.value.invitedSpeakerIds!
                .indexWhere((element) => element.id == user.id) !=
            -1) {
          currentRoom.value.invitedSpeakerIds!
              .elementAt(currentRoom.value.invitedSpeakerIds!
                  .indexWhere((element) => element.id == user.id))
              .muted = extra;
          currentRoom.refresh();
        }
        if (currentRoom.value.raisedHands!
                .indexWhere((element) => element.id == user.id) !=
            -1) {
          currentRoom.value.raisedHands!
              .elementAt(currentRoom.value.raisedHands!
                  .indexWhere((element) => element.id == user.id))
              .muted = extra;
          currentRoom.refresh();
        }

        if (user.id == FirebaseAuth.instance.currentUser!.uid) {
          audioMuted.value = extra;
          engine?.muteLocalAudioStream(extra);
          if (audioMuted.value == false) {
            engine?.enableAudio();
          } else {
            // engine?.disableAudio();
          }
        }
      }
    }

    currentRoom.refresh();
  }

  Future<dynamic> wornUi(BuildContext context, OwnerId userModel) async {
    return showModalBottomSheet(
      isDismissible: true,
      context: context,
      backgroundColor: const Color(0Xff252525),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg1.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return DraggableScrollableSheet(
                initialChildSize: 0.5,
                expand: false,
                builder: (BuildContext productContext,
                    ScrollController scrollController) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 0.01.sh,
                          width: 0.15.sw,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        ProfileImage(
                          path: userModel.profilePhoto!,
                          width: 80,
                          height: 80,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "${userModel.firstName!} ${userModel.lastName!}",
                          style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text("WON!",
                            style: TextStyle(
                                fontSize: 26.sp,
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold))
                      ],
                    ),
                  );
                });
          }),
        );
      },
    );
  }

  void removePinned() {
    if (currentRoom.value.pinned != null) {
      sendChannelMessage({"productid": currentRoom.value.pinned!.id},
          action: "removepinned");

      RoomAPI().removeProductFromRoom(
          {"pin": currentRoom.value.pinned!.id}, currentRoom.value.id!);
    }
    currentRoom.value.pinned = null;
    currentRoom.refresh();
  }

  void pinProduct(Product product) {
    if (currentRoom.value.activeauction != null) {
      auctionController.removeAuction();
    }
    currentRoom.value.pinned = product;
    sendChannelMessage({"productid": product.id}, action: "pinned");
    currentRoom.refresh();
    Get.back();
    RoomAPI().updateRoomId({"pin": product.id}, currentRoom.value.id!);
  }

  void returnToStore(Product product) {
    removePinned();
    currentRoom.value.productIds!
        .removeWhere((element) => element.id == product.id);
    currentRoom.refresh();

    RoomAPI().removeProoductFromRoom({
      "product": product.id,
    }, currentRoom.value.id!).then((value) => {
          sendChannelMessage({"productid": product.id},
              action: "updateproducts")
        });
  }

  Future<void> speakerInvitedAlert(
      OwnerId user, AgoraRtmChannel rtmChannel) async {
    try {
      Get.defaultDialog(
        contentPadding: const EdgeInsets.all(10),
        title: "👋 $you_have_been_invited_to_speaker",
        titleStyle: TextStyle(
            fontSize: 16.sp, color: Colors.black, fontFamily: "InterBold"),
        content: Container(
          margin: const EdgeInsets.only(top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () async {
                  Get.back();
                  // await removeUserFromInvitedSpeakers(user);
                },
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text(
                      maybe_later,
                      style: TextStyle(color: Colors.white),
                    )),
              ),
              InkWell(
                onTap: () async {
                  emitRoom(
                      currentUser: user.toJson(),
                      action: "add_speaker",
                      agoraRtmChannel: rtmChannel);
                },
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text(
                      join_as_speaker,
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ],
          ),
        ),
      );
    } catch (e, s) {
      printOut("$e $s");
    }
  }

  void scrollControllerListener() {
    roomsScrollController.addListener(() {
      if (roomsScrollController.position.atEdge) {
        bool isTop = roomsScrollController.position.pixels == 0;
        if (isTop) {
        } else {
          roomsPageNumber.value = roomsPageNumber.value + 1;
          getActiveTokshows();
        }
      }
    });
  }

  createRoomView({Product? product, String title = ""}) {
    AuthController authController = Get.find<AuthController>();
    if (authController.usermodel.value!.accountDisabled == true) {
      Get.snackbar(cannot_create_show, account_deactivated,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
    } else if (authController.usermodel.value!.shopId == null ||
        authController.usermodel.value!.shopId!.open == false) {
      showDialog(
        context: Get.context!,
        builder: (context) {
          return AlertDialog(
            title: const Text(confirmation),
            content: Text(
                "${authController.usermodel.value!.shopId == null ? you_do_not_have_shop : your_shop_is_closed} "),
            actions: [
              TextButton(
                child: const Text(yes),
                onPressed: () async {
                  Navigator.pop(context, false);
                  if (Get.find<AuthController>().usermodel.value!.shopId ==
                      null) {
                    Get.to(() => ApplyToSell());
                  } else if (authController.usermodel.value!.shopId!.open! ==
                      false) {
                    Get.find<ShopController>().currentShop.value =
                        authController.usermodel.value!.shopId!;
                    Get.to(() => ProfileProducts(
                          userid: authController.usermodel.value!.id!,
                        ));
                  }
                },
              ),
              TextButton(
                child: const Text(no),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
            ],
          );
        },
      );
    } else if (Get.find<AuthController>().usermodel.value!.payoutMethod ==
        null) {
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Center(
                        child: Text(
                          set_up_payment_to_golive,
                          style:
                              TextStyle(color: primarycolor, fontSize: 14.sp),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        welcome_to_tokshow_need_to_know_how_pay_you,
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Get.to(() => PayoutSettings());
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
                              setup,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 13.sp),
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
    } else if (agoraAppID.isEmpty) {
      Get.back();
      var snackBar = SnackBar(
        backgroundColor: Colors.red,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text(
                Agora_not_set,
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    child: const Text(
                      dismiss,
                      style: TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(Get.context!).removeCurrentSnackBar(
                          reason: SnackBarClosedReason.dismiss);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
        duration: Duration(minutes: 3565),
      );
      ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
    } else {
      roomTitleController.text = title;
      newRoomType.value = "public";
      roomPickedImages.value = [];
      roomHosts.value = [];
      if (product != null) {
        roomPickedProduct.add(product);
      }
      roomHosts.add(Get.find<AuthController>().usermodel.value!);
      Get.to(() => CreateShowDialog());
    }
  }

  Future<void> createRoom() async {
    isCreatingRoom.value = true;
    roomPageInitialPage.value = 1;

    Get.defaultDialog(
        title: "$go_live...",
        contentPadding: const EdgeInsets.all(10),
        content: const CircularProgressIndicator(),
        barrierDismissible: false);

    var hosts = [];
    for (var element in roomHosts) {
      hosts.add(element.id);
    }

    String roomTitle =
        roomTitleController.text.isEmpty ? " " : roomTitleController.text;

    var roomData = {
      "title": roomTitle,
      "roomType": newRoomType.value,
      "allowrecording": allowrecording.value,
      "allowchat": allowchat.value,
      "discount": roomProductDiscount.text,
      "productIds": roomPickedProduct.map((e) => e.id).toList(),
      "hostIds": hosts,
      "userIds": [],
      "raisedHands": [],
      "speakerIds": [],
      "invitedIds": [],
      "shopId": Get.find<AuthController>().usermodel.value!.shopId!.id,
      "status": true,
      "productPrice": roomPickedProduct.map((e) => e.price).toList(),
      "activeTime": DateTime.now().millisecondsSinceEpoch,
      "channel": roomPickedChannel.map((element) => element.id).toList(),
    };

    var rooms = await RoomAPI().createARoom(roomData);
    if (rooms != null) {
      var roomId = rooms["_id"];
      roomTitleController.text = "";
      Get.back();
      Get.to(() => NewLiveTokshowPage(roomId: roomId));
    } else {
      printOut("error here");
      Get.back();
      Get.snackbar("", error_creating_your_room,
          backgroundColor: kPrimaryColor, colorText: Colors.white);
    }

    isCreatingRoom.value = false;
  }

  createRoomFromEvent(String roomId) async {
    try {
      audioMuted.value = true;

      Get.back();
      Get.defaultDialog(
          title: "$go_live...",
          contentPadding: const EdgeInsets.all(10),
          content: const CircularProgressIndicator(),
          barrierDismissible: false);

      var token = await RoomAPI().generateAgoraToken(roomId, "0");

      if (token != null) {
        await RoomAPI().updateRoomId({
          "token": token,
          "event": false,
          "activeTime": DateTime.now().millisecondsSinceEpoch
        }, roomId);
        Get.back();

        Get.to(NewLiveTokshowPage(
          roomId: roomId,
        ));
      } else {
        Get.offAll(MainPage());
        Get.snackbar(
          "",
          there_was_an_error_creating_your_room,
          backgroundColor: kPrimaryColor,
        );

        endRoom(roomId);
      }
    } catch (e, s) {
      print("e $e");
      Get.back();
      isCreatingRoom.value = false;
    }
  }

  Future<void> getActiveTokshows(
      {String limit = "15", String channel = "", String userid = ""}) async {
    var respose = await RoomAPI()
        .getActiveTokshows(limit: limit, channel: channel, userid: userid);
    List list = respose["rooms"];
    List<Tokshow> rooms = list.map((e) => Tokshow.fromJson(e)).toList();
    if ((channel.isNotEmpty && userid.isNotEmpty) ||
        (channel.isEmpty && userid.isNotEmpty)) {
      userRoomsList.value = rooms;
      userRoomsList.refresh();
    } else if (channel.isNotEmpty && userid.isEmpty) {
      channelRoomsList.value = rooms;
      channelRoomsList.refresh();
    } else if (userid.isEmpty) {
      allroomsList.value = rooms;
      allroomsList.refresh();
    }
  }

  fetchEvents() async {
    try {
      isLoading.value = true;
      // allUpcomingEvents.clear();
      List events = await RoomAPI().getAllEvents();
      allUpcomingEvents.value =
          events.map((e) => UpcomingTokshow.fromJson(e)).toList();
      isLoading.value = false;
      return events;
    } catch (e) {
      printOut("fetchEvents $e");
      isLoading.value = false;
    }
  }

  fetchMyEvents(String userId) async {
    isLoading.value = true;

    myUpcomingEvents.clear();
    List events = await RoomAPI().getAllMyEvents(userId);
    printOut(events);
    myUpcomingEvents.value =
        events.map((e) => UpcomingTokshow.fromJson(e)).toList();
    isLoading.value = false;
    return events;
  }

  Future<void> fetchUserCurrentRoom() async {
    try {
      isLoading.value = true;

      var room = await RoomAPI()
          .getRoomById(Get.find<AuthController>().usermodel.value!.id!);

      if (room != null) {
        currentRoom.value = Tokshow.fromJson(room);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRoom(String roomId) async {
    try {
      isCurrentRoomLoading.value = true;
      var roomResponse = await RoomAPI().getRoomById(roomId);
      if (roomResponse != null) {
        Tokshow room = Tokshow.fromJson(roomResponse);
        currentRoom.value = room;
      } else if (roomResponse == null || roomResponse["ended"] == true) {
        Get.snackbar('', room_has_ended,
            backgroundColor: kPrimaryColor, colorText: Colors.white);
        _chatController.currentRoomChat.value = [];
        _chatController.currentChatId.value = "";
        Get.offAll(() => MainPage());
      }
      isCurrentRoomLoading.value = false;
    } catch (e, s) {
      printOut("Error getting individual room $e $s");
      isCurrentRoomLoading.value = false;
    }
  }

  Future<void> addUserToRoom(String id) async {
    leaveRoomWhenKilled();
    await RoomAPI().addUserrToRoom({
      "users": [FirebaseAuth.instance.currentUser!.uid]
    }, id);
    currentRoom.refresh();
  }

  Future<void> raiseHand(
      BuildContext context, AgoraRtmChannel? rtmChannel) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(raise_hand),
          content: const Text(want_to_raise_your_hand),
          actions: [
            TextButton(
              child: const Text(yes),
              onPressed: () async {
                Navigator.pop(context, true);
                OwnerId user = OwnerId(
                  id: Get.find<AuthController>().usermodel.value!.id,
                  bio: Get.find<AuthController>().usermodel.value!.bio,
                  email: Get.find<AuthController>().usermodel.value!.email,
                  firstName:
                      Get.find<AuthController>().usermodel.value!.firstName,
                  lastName:
                      Get.find<AuthController>().usermodel.value!.lastName,
                  userName:
                      Get.find<AuthController>().usermodel.value!.userName,
                  agorauid:
                      Get.find<AuthController>().usermodel.value!.agorauid,
                  profilePhoto:
                      Get.find<AuthController>().usermodel.value!.profilePhoto,
                  muted: true,
                  followers: Get.find<AuthController>()
                      .usermodel
                      .value!
                      .followers
                      .map((e) => e.id!)
                      .toList(),
                  following: Get.find<AuthController>()
                      .usermodel
                      .value!
                      .following
                      .map((e) => e.id!)
                      .toList(),
                );

                await addUserToRaisedHands(
                    user, Get.find<TokShowController>().rtmChannel!);
              },
            ),
            TextButton(
              child: const Text(no),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> leaveRoomWhenKilled() async {
    if (Get.find<AuthController>().currentuser!.currentRoom! != "") {
      await emitRoom(
          action: "leave",
          roomId: Get.find<AuthController>().currentuser!.currentRoom!,
          currentUser: Get.find<AuthController>().currentuser!.toJson());
      Get.find<AuthController>().currentuser!.currentRoom = "";
    }
  }

  Future<void> inviteToSpeaker(
      OwnerId user, RtcEngine? engine, AgoraRtmChannel? rtmChannel) async {
    await emitRoom(
        currentUser: user.toJson(),
        action: "add_speaker",
        agoraRtmChannel: rtmChannel);
  }

  Future<void> addUserToRaisedHands(
      OwnerId user, AgoraRtmChannel rtmChannel) async {
    currentRoom.value.raisedHands!.add(user);

    Get.snackbar(
      '',
      you_have_raised_hand,
      colorText: Colors.white,
      backgroundColor: kPrimaryColor,
    );

    currentRoom.refresh();

    await emitRoom(
        currentUser: user.toJson(),
        action: "added_raised_hands",
        agoraRtmChannel: rtmChannel);

    //Add user to raisedHands
    await RoomAPI().updateRoomById({
      "title": currentRoom.value.title ?? " ",
      "raisedHands": [user.id],
      "token": currentRoom.value.token
    }, currentRoom.value.id!);
  }

  Future<void> removeUserFromInvitedSpeakers(
      OwnerId user, RtcEngine? engine, AgoraRtmChannel? rtmChannel) async {
    if (currentRoom.value.invitedSpeakerIds!
            .indexWhere((element) => element.id == user.id) !=
        -1) {
      currentRoom.value.invitedSpeakerIds!.removeAt(currentRoom
          .value.invitedSpeakerIds!
          .indexWhere((element) => element.id == user.id));
    }

    currentRoom.value.raisedHands!.removeAt(currentRoom.value.raisedHands!
        .indexWhere((element) => element.id == user.id));

    currentRoom.refresh();

    await emitRoom(
        currentUser: user.toJson(),
        action: "remove_invited_speaker",
        agoraRtmChannel: rtmChannel);

    await emitRoom(
        action: "remote_muted",
        currentUser: user.toJson(),
        roomId: currentRoom.value.id!,
        extra: true,
        agoraRtmChannel: rtmChannel);

    //Add user to speakers
    await RoomAPI().updateRoomById({
      "title": currentRoom.value.title ?? " ",
      "userIds": [user.id],
      "token": currentRoom.value.token
    }, currentRoom.value.id!);

    await RoomAPI().removeUserFromRaisedHandsInRoom({
      "users": [user.id],
      "token": currentRoom.value.token
    }, currentRoom.value.id!);

    //Remove user from audience
    await RoomAPI().removeUserFromInvitedSpeakerInRoom({
      "users": [user.id]
    }, currentRoom.value.id!);
  }

  Future<void> leaveRoom({String? idRoom, AgoraRtmChannel? rtmChannel}) async {
    var roomId = idRoom ?? currentRoom.value.id.toString();
    if (currentRoom.value.id != null) {
      if (FirebaseAuth.instance.currentUser!.uid ==
          currentRoom.value.ownerId!.id) {
        await emitRoom(
            currentUser: Get.find<AuthController>().usermodel.value!.toJson(),
            action: "leave",
            roomId: currentRoom.value.id!,
            agoraRtmChannel: Get.find<TokShowController>().rtmChannel);
        await RoomAPI().deleteARoom(roomId);
      } else {
        await RoomAPI().removeUserFromHostInRoom({
          "users": [FirebaseAuth.instance.currentUser!.uid]
        }, roomId);
      }
      currentRoom.value = Tokshow();
      currentRoom.refresh();
      try {
        Get.find<ChatController>().roomChatStream.cancel();
      } catch (e) {
        printOut("error removing stream");
      }
      leaveAgoraEngine(roomId);
    }
  }

  Future<void> leaveTokshow(OwnerId currentUser, Tokshow tokshow) async {
    try {
      if (currentRoom.value.activeauction != null) {
        auctionController.timer.cancel();
      }
      Wakelock.disable();
      Get.offAll(() => MainPage());
      await emitRoom(
          currentUser: currentUser.toJson(),
          action: "leave",
          roomId: currentRoom.value.id!,
          agoraRtmChannel: rtmChannel);
      await leaveAgoraEngine(tokshow.id!);
      if (currentUser.id == tokshow.ownerId!.id) {
        await RoomAPI().deleteARoom(tokshow.id!);
      } else {
        await RoomAPI().removeUserFromRoom({
          "roomId": tokshow.id!,
          "users": [FirebaseAuth.instance.currentUser!.uid]
        }, tokshow.id!);
      }

      if (currentRoom.value.recordedRoom == true) {
        disposeVideoPlayer();
      } else {
        await _stopRecording();
      }
      currentRoom.value = Tokshow();
      currentRoom.refresh();
    } catch (e) {
      printOut(e);
      Get.offAll(() => MainPage());
      currentRoom.value = Tokshow();
      currentRoom.refresh();
    }
  }

  Future<void> leaveAgoraEngine(String roomId) async {
    if (currentRoom.value.activeauction != null) {
      auctionController.removeAuction();
    }
    try {
      await rtmChannel?.leave();
      await engine?.leaveChannel();
      await engine?.destroy();
      await client?.logout();
      if (client != null) {
        // await client.releaseChannel(roomId);
      }
    } catch (e) {
      printOut("agoora error $e");
    }
  }

  endRoom(String roomId) async {
    try {
      currentRoom.value = Tokshow();
      currentRoom.refresh();
      await RoomAPI().deleteARoom(roomId);
    } catch (e, s) {
      printOut("Error ending room $e $s");
    }
  }

  Future<void> joinRoom(String roomId, {String type = ""}) async {
    print("joinRoom $roomId");
    if (FirebaseAuth.instance.currentUser == null) {
      Get.offAll(() => const WelcomeScreen());
    } else {
      print("joinRoom vv $roomId");
      audioMuted.value = true;
      Get.defaultDialog(
          title: "$joining_room...",
          contentPadding: const EdgeInsets.all(10),
          content: const CircularProgressIndicator(),
          barrierDismissible: false);

      if (currentRoom.value.id != null && currentRoom.value.id != roomId) {
        var prevRoom = currentRoom.value.id;
        currentRoom.value.id = null;
        await leaveRoom(idRoom: prevRoom);
        currentRoom.value = Tokshow();
        currentRoom.refresh();
      }
      Get.back();
      if (type == "notification") {
        Get.back();
      }

      Get.to(() => NewLiveTokshowPage(
            roomId: roomId,
          ));
      await addUserToRoom(roomId);
      currentRoom.refresh();
    }
  }

  Future<void> muteUnMute(OwnerId currentUser,
      {AgoraRtmChannel? rtmChannel, RtcEngine? engine}) async {
    try {
      if (audioMuted.isFalse) {
        audioMuted.value = true;

        engine?.muteLocalAudioStream(true);
        engine?.enableLocalAudio(false);
      } else {
        audioMuted.value = false;
        engine?.enableLocalAudio(true);
        engine?.muteLocalAudioStream(false);
        sendRoomNotification(currentRoom.value);
      }

      await emitRoom(
          action: "remote_muted",
          currentUser: currentUser.toJson(),
          roomId: currentRoom.value.id!,
          extra: audioMuted.value,
          agoraRtmChannel: rtmChannel);
      await UserAPI().updateUser({"muted": audioMuted.value}, currentUser.id!);
    } catch (e) {
      printOut("error to speak $e");
    }
  }

  Future<void> muteUnMuteRemoteUser(
      OwnerId user, AgoraRtmChannel? rtmChannel, RtcEngine engine) async {
    try {
      var userMuted = !user.muted!;

      int i = currentRoom.value.raisedHands!
          .indexWhere((element) => element.id == user.id);
      currentRoom.value.raisedHands![i].muted = userMuted;
      currentRoom.refresh();
      engine.muteRemoteAudioStream(user.agorauid!, userMuted);
      await emitRoom(
          action: "remote_muted",
          currentUser: user.toJson(),
          roomId: currentRoom.value.id!,
          extra: userMuted,
          agoraRtmChannel: rtmChannel);
      await UserAPI().updateUser({"muted": !user.muted!}, user.id!);
    } catch (e) {
      printOut("error to speak $e");
    }
  }

  alertStopRecording() async {
    await showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          title: const Text(stop_recording),
          content: const Text(stop_recording_cannot_record_again),
          actions: [
            TextButton(
              child: const Text(yes),
              onPressed: () {
                Navigator.pop(context, true);
                _stopRecording();
                Get.snackbar('', '$recoding_stopped...',
                    backgroundColor: kPrimaryColor,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2));
                currentRoom.refresh();
              },
            ),
            TextButton(
              child: const Text(no),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> recordStartStop(
    BuildContext context,
    OwnerId? currentUser,
    Tokshow? tokshow,
  ) async {
    Get.defaultDialog(
        title: "$please_wait...",
        contentPadding: const EdgeInsets.all(10),
        content: const CircularProgressIndicator(),
        barrierDismissible: false);
    var roomFromApi = await RoomAPI().getRoomById(currentRoom.value.id!);
    Get.back();

    if (roomFromApi == null) {
      //Remove user from room that has ended, and show them a message.
      Get.snackbar('', tokshop_does_not_exist,
          backgroundColor: kPrimaryColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));

      Future.delayed(const Duration(seconds: 3), () {
        currentRoom.value = Tokshow();
        leaveTokshow(currentUser!, tokshow!);
        Get.offAll(MainPage());
      });
    } else {
      Tokshow roo = Tokshow.fromJson(roomFromApi);
      if (roo.recordingIds!.indexWhere((element) =>
              element ==
              Get.find<AuthController>()
                  .usermodel
                  .value!
                  .recordingUid
                  .toString()) !=
          -1) {
        return alertStopRecording();
      } else {
        var total = activeUsers.length;

        print("activeUsers ${activeUsers.length}");

        if (total > 1) {
          return await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text(start_recording_this_room),
                content: const Text(recorded_audio_wil_be_saved_for_30_days),
                actions: [
                  TextButton(
                    child: const Text(yes),
                    onPressed: () {
                      Navigator.pop(context, true);
                      startrecordingAudio(
                          token: currentRoom.value.token,
                          channelname: currentRoom.value.id);
                    },
                  ),
                  TextButton(
                    child: const Text(no),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                ],
              );
            },
          );
        } else {
          return await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text(recording_cannot_start),
                content: const Text(
                    record_room_need_to_be_more_than_one_person_in_room),
                actions: [
                  TextButton(
                    child: const Text(yes),
                    onPressed: () {
                      Navigator.pop(context, true);
                      invitedFriends(context);
                    },
                  ),
                  TextButton(
                    child: const Text(no),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  _stopRecording() {
    if (currentRoom.value.recordingsid != null) {
      stopRecording(
          channelname: currentRoom.value.id,
          resourceid: currentRoom.value.resourceId,
          recordingUid: currentRoom.value.recordingUid,
          sid: currentRoom.value.recordingsid);
    }
  }

  emitRoom(
      {Map? currentUser,
      required String action,
      String roomId = "",
      bool? extra = false,
      Map<String, dynamic>? otherdata,
      AgoraRtmChannel? agoraRtmChannel}) {
    sendChannelMessage(currentUser!,
        action: action, extra: extra!, roomId: roomId, otherdata: otherdata);
  }

  leaveStreamChannels(String option) async {
    if (currentRoom.value.streamOptions!
            .indexWhere((element) => element == "yt") !=
        1) {
      await engine?.removePublishStreamUrl(
          "rtmp://x.rtmp.youtube.com/live2/$youTubeStreamKey");
    }
    if (currentRoom.value.streamOptions!
            .indexWhere((element) => element == "fb") !=
        1) {
      await engine?.stopRtmpStream(
          "rtmps://live-api-s.facebook.com:443/rtmp/$fbStreamKey");
    }

    emitRoom(
        action: "stopstreaming",
        otherdata: {"option": option},
        currentUser: Get.find<AuthController>().usermodel.value!.toJson(),
        roomId: currentRoom.value.id!,
        agoraRtmChannel: rtmChannel);
  }

  addToStreamOptions(String option) async {
    if (option == "yt") {
      currentRoom.value.streamOptions!.add(option);
      await engine?.addPublishStreamUrl(
          "rtmp://x.rtmp.youtube.com/live2/$youTubeStreamKey", false);
    }
    if (option == "fb") {
      currentRoom.value.streamOptions!.add(option);
      await engine?.startRtmpStreamWithoutTranscoding(
          "rtmps://live-api-s.facebook.com:443/rtmp/$fbStreamKey");
    }
    await RoomAPI().updateRoomId(
        {"streamOptions": currentRoom.value.streamOptions},
        currentRoom.value.id!);

    sendRoomNotification(currentRoom.value,
        type: "liveposted",
        streamtype: option == "yt" ? "Youtube" : "Facebook");

    emitRoom(
        action: "streaming",
        otherdata: {"option": option},
        currentUser: Get.find<AuthController>().usermodel.value!.toJson(),
        roomId: currentRoom.value.id!,
        agoraRtmChannel: rtmChannel);
  }

  stopRecording(
      {String? channelname,
      String? resourceid,
      String? recordingUid,
      String? sid}) async {
    var body = {
      "resourceid": resourceid,
      "channelname": channelname,
      "roomId": currentRoom.value.id,
      "recordingUid": recordingUid,
      "userId": Get.find<AuthController>().usermodel.value!.id
    };
    var response = await DbBase().databaseRequest(
        stoprecording + sid!, DbBase().postRequestType,
        body: body, headers: headers);
    printOut(currentRoom.value.recordingIds);

    if (currentRoom.value.recordingIds != null) {
      currentRoom.value.recordingIds!.removeWhere((element) =>
          element == Get.find<AuthController>().usermodel.value!.id);
      currentRoom.refresh();
    }
    return jsonDecode(response);
  }

  writeToDbRoomActive() async {
    var now = DateTime.now();

    if (currentRoom.value.activeTime != null) {
      var lastUpdated =
          DateTime.fromMillisecondsSinceEpoch(currentRoom.value.activeTime!);
      var duration = now.difference(lastUpdated);

      printOut("last updated ${duration.inMinutes}");

      if (duration.inMinutes > 10) {
        updateActiveTime(now);
      }
    } else {
      updateActiveTime(now);
    }
  }

  updateActiveTime(DateTime now) async {
    currentRoom.value.activeTime = now.millisecondsSinceEpoch;
    if (currentRoom.value.id != null) {
      await RoomAPI().updateRoomById({
        "activeTime": now.millisecondsSinceEpoch,
        "title": currentRoom.value.title,
        "token": currentRoom.value.token
      }, currentRoom.value.id!);
    }
  }

  getUserProfile(String userId) async {
    try {
      profileLoading.value = true;
      var user = await UserAPI().getUserProfile(userId);

      if (user == null) {
        currentProfile.value = "";
      } else {
        currentProfile.value = user;
      }

      profileLoading.value = false;
    } catch (e, s) {
      printOut("Error getting user $userId profile $e $s");
    }
  }

  createEvent() async {
    try {
      isCreatingRoom.value = true;

      var hosts = [];
      for (var element in roomHosts) {
        hosts.add(element.id);
      }

      var roomData = {
        "title": eventTitleController.text,
        "roomType": newRoomType.value.isEmpty ? "public" : newRoomType.value,
        "productIds": roomPickedProduct.map((e) => e.id).toList(),
        "hostIds": hosts,
        "description": eventDescriptiion.text,
        "userIds": [],
        "raisedHands": [],
        "speakerIds": [],
        "event": true,
        "invitedIds": [],
        "shopId": Get.find<AuthController>().usermodel.value!.shopId!.id,
        "status": true,
        "productPrice": roomPickedProduct.value.map((e) => e.price).toList(),
        "activeTime": DateTime.now().millisecondsSinceEpoch,
        "eventDate": eventDate.value!.millisecondsSinceEpoch,
        "channel": roomPickedChannel.map((e) => e.id).toList(),
        "allowrecording": allowrecording.value,
        "allowchat": allowchat.value,
        "discount": roomProductDiscount.text,
      };

      var rooms = await RoomAPI().createEvent(roomData);

      if (rooms != null) {
        Get.back();
        eventTitleController.text = "";
      } else {
        Get.snackbar(
          "",
          error_creating_your_room,
          backgroundColor: kPrimaryColor,
        );
      }
      isCreatingRoom.value = false;
    } catch (e, s) {
      printOut("Error creating room in controller $e $s");
      isCreatingRoom.value = false;
    } finally {
      isCreatingRoom.value = false;
      roomPickedImages.value = [];
      roomPickedChannel.value = [];
      allowrecording.value = false;
      allowchat.value = false;
    }
  }

  updateEvent(String roomId) async {
    var hosts = [];
    var addedHosts = [];
    var removedHosts = [];

    for (var element in roomHosts) {
      hosts.add(element.id);
    }

    if (hosts.length > roomOriginalHosts.length) {
      for (var i = 0; i < hosts.length; i++) {
        if (roomOriginalHosts
                .indexWhere((element) => element == hosts.elementAt(i)) ==
            -1) {
          addedHosts.add(hosts.elementAt(i));
        }
      }
    } else if (hosts.length < roomOriginalHosts.length) {
      for (var i = 0; i < roomOriginalHosts.length; i++) {
        if (!hosts.contains(roomOriginalHosts.elementAt(i))) {
          removedHosts.add(roomOriginalHosts.elementAt(i));
        }
      }
    }

    var roomData = {
      "title": eventTitleController.text,
      "roomType": newRoomType.value,
      "productIds": roomPickedProduct.map((e) => e.id).toList(),
      "invitedhostIds": hosts,
      "description": eventDescriptiion.text,
      "userIds": [],
      "raisedHands": [],
      "speakerIds": [],
      "event": true,
      "invitedIds": [],
      "shopId": Get.find<AuthController>().usermodel.value!.shopId!.id,
      "status": true,
      "activeTime": DateTime.now().millisecondsSinceEpoch,
      "eventDate": eventDate.value!.millisecondsSinceEpoch
    };

    var r = await RoomAPI().updateRoomId(roomData, roomId);
    if (addedHosts.isNotEmpty) {
      List addedHostsToken = [];

      for (var i = 0; i < addedHosts.length; i++) {
        var index = roomHosts
            .indexWhere((element) => element.id == addedHosts.elementAt(i));

        if (index != -1) {
          addedHostsToken.add(roomHosts.elementAt(index));
        }
      }

      NotificationsAPI().sendNotification(
          addedHostsToken,
          "You've been invited",
          "${Get.find<AuthController>().usermodel.value!.firstName}"
              " ${Get.find<AuthController>().usermodel.value!.lastName} "
              "has invited you to be a co-host in their event.",
          "EventScreen",
          roomId);
    } else if (removedHosts.isNotEmpty) {
      await RoomAPI().removeUserFromHostInRoom({"users": removedHosts}, roomId);
    }

    Get.back();
  }

  Future<void> addRemoveToBeNotified(UpcomingTokshow eventModel, int ii) async {
    int i = allUpcomingEvents[ii].invitedhostIds!.indexWhere(
        (element) => element.id == FirebaseAuth.instance.currentUser!.uid);
    if (i == -1) {
      allUpcomingEvents[ii].invitedhostIds!.add(OwnerId(
          firstName: authController.usermodel.value!.firstName,
          lastName: authController.usermodel.value!.lastName,
          id: authController.usermodel.value!.id));
      const GetSnackBar(
        duration: Duration(seconds: 10),
        messageText: Text(
          noticed_when_event_start,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
      ).show();
    } else {
      allUpcomingEvents[ii].invitedhostIds!.removeAt(i);

      const GetSnackBar(
        duration: Duration(seconds: 10),
        messageText: Text(
          not_noticed_when_event_start,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
      ).show();
    }

    allUpcomingEvents.refresh();
    await RoomAPI().updateRoomId(
        {"invitedhostIds": eventModel.invitedhostIds}, eventModel.id!);
  }

  void deleteEvent(String roomId) async {
    Get.defaultDialog(
        title: deleting_event,
        contentPadding: const EdgeInsets.all(10),
        content: const CircularProgressIndicator(),
        barrierDismissible: false);
    await RoomAPI().deleteARoom(roomId);
    fetchEvents();
    fetchMyEvents(FirebaseAuth.instance.currentUser!.uid);
    Get.back();
    Get.back();
  }

  startrecordingAudio({token, String? channelname}) async {
    Map<String, dynamic> response = await RoomAPI().recordRoom(
        channelname!, token, currentRoom.value.ownerId!.agorauid.toString());
    printOut("record response $response");
    if (response.containsKey("message")) {
      Get.snackbar('', start_recording_failed,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
    } else {
      Tokshow roomModel = Tokshow.fromJson(response);
      currentRoom.value.recordingsid = roomModel.recordingsid;
      currentRoom.value.resourceId = roomModel.resourceId;
      currentRoom.value.recordingUid = roomModel.recordingUid;
      currentRoom.value.recordingIds = roomModel.recordingIds;

      currentRoom.refresh();

      Get.snackbar('', '$recoding_started...',
          backgroundColor: kPrimaryColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));
    }
    return response;
  }

  Future<void> sendRoomNotification(Tokshow roomModel,
      {String type = "speaking", String streamtype = ""}) async {
    if (currentRoom.value.userIds!.indexWhere((element) =>
            element.id == Get.find<AuthController>().usermodel.value!.id) ==
        -1) {
      await RoomAPI().sendRoomNotication({
        "user": Get.find<AuthController>().usermodel.value!.toJson(),
        "type": type,
        "streamtypetype": streamtype,
        "room": roomModel.toJson()
      });
    }
  }

  playRecordedRoom(Recording recordingModel) async {
    try {
      isCurrentRecordedRoomLoading.value = true;

      Get.defaultDialog(
          title: "$opening_recording...",
          contentPadding: const EdgeInsets.all(10),
          content: const CircularProgressIndicator(),
          barrierDismissible: false);

      var recording = Recording.fromJson(
          await RecordingsAPI().getRecordingById(recordingModel.id));
      var url = audioRecordingsBaseUrl + recordingModel.fileList;
      print(url);
      await initVideoPlayer(url);

      Get.back();

      Tokshow room = Tokshow.fromJson(
          await RoomAPI().getEndedRoomById(recording.roomId!.id!));

      currentRecordedRoom.value = room;
      currentRecordedRoom.value.recordedRoom = true;
      currentRecordedRoom.refresh();

      // _chatController.getRecordingRoomChatById(currentRecordedRoom.value.id!);
    } catch (e, s) {
      Get.back();
      const GetSnackBar(
        messageText: Text(
          error_getting_recording,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
      );
      printOut("Error playing record $e $s");
    } finally {
      isCurrentRecordedRoomLoading.value = false;
    }
  }

  Future initVideoPlayer(String url) async {
    try {
      videoPlayerController = VideoPlayerController.network(url);

      if (videoPlayerController.value.isInitialized == false) {
        await videoPlayerController.initialize();
      }

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: 5 / 10,
        showOptions: true,
        fullScreenByDefault: true,
        showControls: true,
        showControlsOnInitialize: true,
        allowPlaybackSpeedChanging: true,
        hideControlsTimer: Duration(days: 1),
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
    } catch (e, s) {
      printOut("$e $s");
    }
  }

  void playAudio() {
    chewieController.play();
    videoPlaying.value == true;
  }

  void pauseAudio() {
    chewieController.pause();
    videoPlaying.value == false;
  }

  void seek(Duration position) {
    chewieController.seekTo(position);
  }

  disposeVideoPlayer() async {
    pauseAudio();
    await videoPlayerController.dispose();
    chewieController.videoPlayerController.dispose();
    chewieController.dispose();
  }

  bool checkIfhavebid(OwnerId currentUser) {
    var i = currentRoom.value.activeauction!.bids!
        .indexWhere((element) => element.bidder.id == currentUser.id);
    return i != -1 ? true : false;
  }
}
