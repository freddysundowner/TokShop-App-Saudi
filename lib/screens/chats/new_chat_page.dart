import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:tokshop/controllers/user_controller.dart';

import '../../controllers/chat_controller.dart';
import '../../controllers/room_controller.dart';
import '../../models/user.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';
import 'chat_room_page.dart';

class NewChatPage extends StatelessWidget {
  final TokShowController _homeController = Get.find<TokShowController>();
  final UserController userController = Get.find<UserController>();
  final ChatController _chatController = Get.find<ChatController>();

  NewChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _homeController.onChatPage.value = false;
    userController.searchUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          choose_friend,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: 5.0, top: 5, right: 10, left: 10),
          child: Obx(() {
            return Column(
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: TextField(
                    cursorColor: Colors.white,
                    controller: userController.searchUsersController,
                    autofocus: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    keyboardType: TextInputType.visiblePassword,
                    onChanged: (text) {
                      if (text.isEmpty) {
                        userController.searchUser();
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: primarycolor.withOpacity(0.25),
                      hintText: "$search...",
                      hintStyle:
                          TextStyle(fontSize: 12.sp, color: primarycolor),
                      suffixIcon: IconButton(
                          iconSize: 25,
                          icon: const Icon(Icons.search),
                          color: primarycolor,
                          onPressed: () async {
                            userController.searchUser();
                          }),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.sm, vertical: 9.sm),
                      border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(3.0)),
                    ),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        decoration: TextDecoration.none),
                  ),
                ),
                SizedBox(
                  height: 0.01.sh,
                ),
                SizedBox(
                    height: 0.78.sh,
                    child: userController.allUsersLoading.isFalse
                        ? GetBuilder<UserController>(builder: (dx) {
                            return dx.searchedUsers.isNotEmpty
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    controller: dx.usersScrollController,
                                    itemCount: dx.searchedUsers.length,
                                    itemBuilder: (context, index) {
                                      UserModel user = UserModel.fromJson(
                                          dx.searchedUsers.elementAt(index));
                                      return Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            child: InkWell(
                                              onTap: () {
                                                _chatController
                                                    .currentChat.value = [];
                                                _chatController
                                                    .currentChatId.value = "";
                                                _chatController
                                                    .getPreviousChat(user);
                                                _homeController
                                                    .onChatPage.value = true;
                                                Get.to(ChatRoomPage(user));
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Center(
                                                        child: user.profilePhoto ==
                                                                    "" ||
                                                                user.profilePhoto ==
                                                                    null
                                                            ? const CircleAvatar(
                                                                radius: 25,
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                backgroundImage:
                                                                    AssetImage(
                                                                        "assets/icons/profile_placeholder.png"))
                                                            : CircleAvatar(
                                                                radius: 25,
                                                                onBackgroundImageError: (o,
                                                                        s) =>
                                                                    Image.asset(
                                                                        "assets/icons/profile_placeholder.png"),
                                                                backgroundColor: Styles
                                                                    .greenTheme
                                                                    .withOpacity(
                                                                        0.50),
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                        user.profilePhoto!),
                                                              ),
                                                      ),
                                                      SizedBox(
                                                        width: 0.04.sw,
                                                      ),
                                                      Text(
                                                        "${user.firstName} ${user.lastName}",
                                                        style: TextStyle(
                                                            fontSize: 16.sp),
                                                      ),
                                                    ],
                                                  ),
                                                  const Icon(
                                                    Ionicons.add,
                                                    color: primarycolor,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          const Divider()
                                        ],
                                      );
                                    })
                                : Center(
                                    child: Text(
                                      no_user_matching_name,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 16.sp),
                                    ),
                                  );
                          })
                        : const Center(
                            child: CircularProgressIndicator(
                                color: Colors.white))),
                if (userController.moreUsersLoading.isTrue)
                  Column(
                    children: [
                      const Center(
                          child: CircularProgressIndicator(
                        color: primarycolor,
                      )),
                      SizedBox(
                        height: 0.01.sh,
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 100,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
