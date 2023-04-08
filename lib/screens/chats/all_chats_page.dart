import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../../controllers/chat_controller.dart';
import '../../controllers/global.dart';
import '../../controllers/room_controller.dart';
import '../../models/inbox.dart';
import '../../models/user.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';
import 'chat_room_page.dart';
import 'new_chat_page.dart';

class AllChatsPage extends StatelessWidget {
  final ChatController _chatController = Get.find<ChatController>();
  final TokShowController _homeController = Get.find<TokShowController>();
  final GlobalController _global = Get.find<GlobalController>();

  AllChatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _homeController.onChatPage.value = false;
    _homeController.onTokShowChatPage.value = false;
    _chatController.getUserChats();
    return WillPopScope(
      onWillPop: () async {
        _homeController.onChatPage.value = false;
        _homeController.onTokShowChatPage.value = false;
        _global.tabPosition.value = 0;
        Get.back();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: const [
              Text(chats),
            ],
          ),
          centerTitle: false,
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Obx(() {
            return _chatController.gettingChats.isFalse
                ? RefreshIndicator(
                    onRefresh: () {
                      _chatController.allUserChats.value = [];
                      return _chatController.getUserChats();
                    },
                    child: _chatController.allUserChats.isNotEmpty
                        ? ListView.builder(
                            itemCount: _chatController.allUserChats.length,
                            itemBuilder: (context, index) {
                              Inbox allChatsModel =
                                  _chatController.allUserChats.elementAt(index);
                              return InkWell(
                                onTap: () {
                                  _chatController.currentChatId.value =
                                      allChatsModel.id;
                                  _chatController.currentChatUsers.value =
                                      allChatsModel.users;
                                  _chatController.currentChatUsersIds.value =
                                      allChatsModel.userIds;
                                  _chatController.allUserChats
                                      .elementAt(index)
                                      .unread = 0;
                                  _chatController.allUserChats.refresh();
                                  _homeController.onChatPage.value = true;
                                  Get.to(ChatRoomPage(
                                      getOtherUser(allChatsModel),
                                      inbox: allChatsModel));
                                  _chatController.getChatById(allChatsModel.id);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: getOtherUser(allChatsModel)
                                                        .profilePhoto ==
                                                    "" ||
                                                getOtherUser(allChatsModel)
                                                        .profilePhoto ==
                                                    null
                                            ? const CircleAvatar(
                                                radius: 20,
                                                backgroundColor:
                                                    Colors.transparent,
                                                backgroundImage: AssetImage(
                                                    "assets/icons/profile_placeholder.png"))
                                            : CircleAvatar(
                                                radius: 20,
                                                backgroundColor:
                                                    Colors.transparent,
                                                backgroundImage: NetworkImage(
                                                    getOtherUser(allChatsModel)
                                                        .profilePhoto!),
                                              ),
                                      ),
                                      SizedBox(
                                        width: 0.03.sw,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 0.7.sw,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    getOtherUser(allChatsModel)
                                                            .firstName ??
                                                        "",
                                                    style: TextStyle(
                                                        color: primarycolor,
                                                        fontSize: 12.sp),
                                                  ),
                                                ),
                                                Text(
                                                  convertTime(allChatsModel
                                                      .lastMessageTime),
                                                  style: TextStyle(
                                                      color: allChatsModel
                                                                  .unread >
                                                              0
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Colors.grey,
                                                      fontSize: 11.sp),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 0.7.sw,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      allChatsModel
                                                                  .lastSender ==
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid
                                                          ? "You: "
                                                          : "${getOtherUser(allChatsModel).firstName!}: ",
                                                      style: TextStyle(
                                                          color: Styles
                                                              .dullGreyColor,
                                                          fontSize: 12.sp),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    Text(
                                                      allChatsModel.lastMessage,
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12.sp),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                                allChatsModel.unread > 0
                                                    ? Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10,
                                                                right: 10,
                                                                bottom: 4,
                                                                top: 4),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100),
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                        child: Center(
                                                            child: Text(
                                                          allChatsModel.unread
                                                              .toString(),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10.sp),
                                                        )),
                                                      )
                                                    : Container()
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            })
                        : ListView(
                            children: [
                              SizedBox(
                                height: 0.6.sh,
                                child: Center(
                                  child: Text(
                                    no_chats_yet,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16.sp),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
          }),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: kPrimaryColor,
          onPressed: () => Get.to(NewChatPage()),
          child: const Icon(
            Ionicons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  UserModel getOtherUser(Inbox allChatsModel) {
    UserModel user = UserModel.fromJson({});

    for (var i = 0; i < allChatsModel.users.length; i++) {
      if (allChatsModel.userIds.elementAt(i) !=
          FirebaseAuth.instance.currentUser!.uid) {
        user = UserModel.fromJson(allChatsModel.users.elementAt(i));
        user.id = allChatsModel.users.elementAt(i)["id"];
      }
    }
    return user;
  }
}
