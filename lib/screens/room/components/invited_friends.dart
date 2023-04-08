import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/utils/text.dart';
import 'package:tokshop/widgets/text_form_field.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/channel_controller.dart';
import '../../../controllers/room_controller.dart';
import '../../../models/user.dart';
import '../../../services/room_api.dart';
import '../../../utils/styles.dart';

final ChannelController channelController = Get.find<ChannelController>();

Future<dynamic> invitedFriends(BuildContext context) {
  final TokShowController homeController = Get.find<TokShowController>();
  final UserController userController = Get.find<UserController>();
  userController.searchUsersController.text = "";
  homeController.toInviteUsers.value = [];
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
            initialChildSize: 0.81,
            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              userController.friendsToInviteCall();

              return Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10, top: 10, bottom: 2),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Ionicons.people,
                              ),
                              Text(
                                invite_friends,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                          IconButton(
                              onPressed: () async {
                                Get.back();
                                if (homeController.toInviteUsers.isNotEmpty) {
                                  await inviteUsers(homeController);
                                }
                              },
                              icon: const Icon(
                                Icons.done,
                              ))
                        ],
                      ),
                      SizedBox(
                        height: 0.007.sh,
                      ),
                      CustomTextFormField(
                        controller: userController.searchUsersController,
                        onChanged: (data) {
                          userController.searchUser();
                        },
                        hint: search,
                      ),
                      Obx(() => userController.allUsersLoading.isFalse
                          ? GetBuilder<UserController>(builder: (dx) {
                              return dx.friendsToInvite.isNotEmpty
                                  ? GridView.builder(
                                      shrinkWrap: true,
                                      // physics: ScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        childAspectRatio: 0.6,
                                      ),
                                      itemCount: dx.friendsToInvite.length,
                                      itemBuilder: (context, index) {
                                        UserModel user = UserModel.fromJson(dx
                                            .friendsToInvite
                                            .elementAt(index));
                                        return InkWell(
                                          onTap: () {
                                            if (homeController.toInviteUsers
                                                .contains(user.id)) {
                                              homeController.toInviteUsers
                                                  .remove(user.id);
                                            } else {
                                              homeController.toInviteUsers
                                                  .add(user.id);
                                            }
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Obx(() => Center(
                                                    child: user.profilePhoto ==
                                                                "" ||
                                                            user.profilePhoto ==
                                                                null ||
                                                            user.profilePhoto!
                                                                    .length >
                                                                300
                                                        ? CircleAvatar(
                                                            radius: 25,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            foregroundImage: homeController
                                                                    .toInviteUsers
                                                                    .contains(
                                                                        user.id)
                                                                ? const AssetImage(
                                                                    "assets/icons/picked.png")
                                                                : null,
                                                            backgroundImage:
                                                                const AssetImage(
                                                                    "assets/icons/profile_placeholder.png"))
                                                        : CircleAvatar(
                                                            radius: 25,
                                                            onBackgroundImageError: (object,
                                                                    stackTrace) =>
                                                                const AssetImage(
                                                                    "assets/icons/profile_placeholder.png"),
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            foregroundImage: homeController
                                                                    .toInviteUsers
                                                                    .contains(
                                                                        user.id)
                                                                ? const AssetImage(
                                                                    "assets/icons/picked.png")
                                                                : null,
                                                            backgroundImage:
                                                                NetworkImage(user
                                                                    .profilePhoto!),
                                                          ),
                                                  )),
                                              Center(
                                                child: Text(
                                                  "${user.firstName} ${user.lastName}",
                                                  style: TextStyle(
                                                      fontSize: 12.sp),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      })
                                  : Center(
                                      child: Text(
                                        "No users yet",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16.sp),
                                      ),
                                    );
                            })
                          : const CircularProgressIndicator(
                              color: primarycolor))
                    ],
                  ),
                ),
              );
            });
      });
    },
  );
}

Future<void> inviteUsers(TokShowController homeController) async {
  channelController.inviteUser(
      tokshow_invitation,
      "$youve_been_invited ${homeController.currentRoom.value.title} $by "
          "${FirebaseAuth.instance.currentUser!.displayName}",
      "RoomScreen",
      homeController.currentRoom.value.id!,
      homeController.toInviteUsers,
      Get.find<AuthController>().currentuser!.profilePhoto!);

  await RoomAPI().updateRoomById({
    "title": homeController.currentRoom.value.title,
    "token": homeController.currentRoom.value.token,
    "activeTime": homeController.currentRoom.value.activeTime,
    "invitedIds": homeController.toInviteUsers
  }, homeController.currentRoom.value.id!);
}
