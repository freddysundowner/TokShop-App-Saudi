import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:tokshop/screens/profile/user_profile.dart';

import '../../controllers/chat_controller.dart';
import '../../controllers/room_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/chat.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';

//ignore: must_be_immutable
class RoomGroupChatPage extends StatelessWidget {
  final ChatController _chatController = Get.find<ChatController>();
  final TokShowController _homeController = Get.find<TokShowController>();
  final UserController _userController = Get.find<UserController>();
  TextEditingController messageController = TextEditingController();
  final ScrollController _sc = ScrollController();

  RoomGroupChatPage({Key? key}) : super(key: key) {
    _chatController
        .getChatById(_homeController.currentRoom.value.id.toString());
    _chatController.readChats();
  }

  @override
  Widget build(BuildContext context) {
    _chatController
        .getChatById(_homeController.currentRoom.value.id.toString());

    _homeController.onTokShowChatPage.value = true;
    return WillPopScope(
      onWillPop: () async {
        _homeController.pageController.jumpToPage(1);
        _homeController.roomPageInitialPage.value = 1;
        FocusManager.instance.primaryFocus?.unfocus();
        _chatController.currentChat.value = [];
        _chatController.currentChatId.value = "";
        _chatController.currentChatUsers.value = [];
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              _homeController.pageController.jumpToPage(1);
              _homeController.roomPageInitialPage.value = 1;
              FocusManager.instance.primaryFocus?.unfocus();
              _chatController.currentChat.value = [];
              _chatController.currentChatId.value = "";
              _chatController.currentChatUsers.value = [];
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text(
            room_chat,
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Obx(() {
                return _chatController.currentChatLoading.isFalse
                    ? RefreshIndicator(
                        onRefresh: () => _chatController
                            .getChatById(_chatController.currentChatId.value),
                        child: _chatController.currentChat.isNotEmpty
                            ? SingleChildScrollView(
                                reverse: true,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    controller: _sc,
                                    padding: const EdgeInsets.all(8.0),
                                    itemCount:
                                        _chatController.currentChat.length,
                                    itemBuilder: (context, index) {
                                      Chat chat = _chatController.currentChat
                                          .elementAt(index);
                                      return Align(
                                        alignment: chat.sender !=
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4.0, right: 4),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  _userController
                                                      .getUserProfile(
                                                          chat.sender);
                                                  Get.to(UserProfile());
                                                },
                                                child: Row(
                                                  children: [
                                                    chat.senderProfileUrl ==
                                                                null ||
                                                            chat.senderProfileUrl ==
                                                                ""
                                                        ? CircleAvatar(
                                                            radius: 15,
                                                            child: Image.asset(
                                                                "assets/icons/profile_placeholder.png",
                                                                width: 0.10.sw,
                                                                height:
                                                                    0.06.sh),
                                                          )
                                                        : CachedNetworkImage(
                                                            imageUrl: chat
                                                                .senderProfileUrl!,
                                                            imageBuilder: (context,
                                                                    imageProvider) =>
                                                                Container(
                                                              width: 0.08.sw,
                                                              height: 0.05.sh,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                image: DecorationImage(
                                                                    image:
                                                                        imageProvider,
                                                                    fit: BoxFit
                                                                        .cover),
                                                              ),
                                                            ),
                                                            placeholder: (context,
                                                                    url) =>
                                                                const CircularProgressIndicator(),
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                Image.asset(
                                                                    "assets/icons/profile_placeholder.png",
                                                                    width:
                                                                        0.25.sw,
                                                                    height: 0.14
                                                                        .sh),
                                                          ),
                                                    SizedBox(
                                                      width: 0.02.sw,
                                                    ),
                                                    Text(
                                                      chat.senderName
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 14.sp,
                                                          color:
                                                              Colors.grey[400]),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 0.007.sh,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    width: 0.8.sw,
                                                    decoration: BoxDecoration(
                                                        color: chat.sender ==
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid
                                                            ? Styles.greenTheme
                                                                .withOpacity(
                                                                    0.44)
                                                            : Styles.greenTheme,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Text(
                                                        chat.message,
                                                        style: TextStyle(
                                                            color: chat.sender ==
                                                                    FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid
                                                                ? Colors.white
                                                                : Colors.black,
                                                            fontSize: 14.sp),
                                                      ),
                                                    ),
                                                  ),
                                                  Text(convertTime(chat.date))
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              )
                            : Center(
                                child: Text(
                                  nothing_here,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16.sp),
                                ),
                              ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                        color: Colors.white,
                      ));
              }),
            ),
            if (_homeController.currentRoom.value.ended == false)
              Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10, bottom: 10, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 0.8.sw,
                      decoration: BoxDecoration(
                          color: Styles.greenTheme.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10)),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Center(
                            child: TextField(
                              cursorColor: Colors.white,
                              textCapitalization: TextCapitalization.sentences,
                              controller: messageController,
                              maxLines: 10,
                              minLines: 1,
                              autofocus: false,
                              decoration: InputDecoration(
                                hintText: enter_messge_here,
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16.sp,
                                ),
                                border: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (messageController.text.trim().isNotEmpty &&
                            _homeController.currentRoom.value.ended == false) {
                          _chatController.saveToFirestore(
                              messageController.text.trim(),
                              _homeController.currentRoom.value.id!);
                          messageController.text = "";
                        }
                      },
                      child: Obx(() {
                        return Container(
                          height: 0.07.sh,
                          width: 0.12.sw,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30)),
                          child: _chatController.sendingMessage.isFalse
                              ? const Center(
                                  child: Icon(
                                  Ionicons.send,
                                  color: Styles.greenTheme,
                                  size: 35,
                                ))
                              : Transform.scale(
                                  scale: 0.3,
                                  child: const CircularProgressIndicator(
                                    color: primarycolor,
                                  )),
                        );
                      }),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
