import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:ionicons/ionicons.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/controllers/user_controller.dart';

import '../../controllers/room_controller.dart';
import '../../models/product.dart';
import '../../models/tokshow_image.dart';
import '../../models/user.dart';
import '../../services/local_files_access_service.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';

final TokShowController homeController = Get.find<TokShowController>();
final UserController userController = Get.find<UserController>();
final ProductController productController = Get.find<ProductController>();

Future<dynamic> showRoomTypeBottomSheet(BuildContext context) {
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
            initialChildSize: 0.6,
            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      color: Theme.of(context).primaryColor,
                      height: 0.01.sh,
                      width: 0.15.sw,
                    ),
                    SizedBox(
                      height: 0.02.sh,
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            showAddTitleDialog(context);
                          },
                          child: Text(
                            "+ $add_title",
                            style:
                                TextStyle(color: Colors.red, fontSize: 16.sp),
                          ),
                        )),
                    SizedBox(
                      height: 0.03.sh,
                    ),
                    Obx(() {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              homeController.newRoomType.value = "public";
                            },
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: homeController
                                                      .newRoomType.value ==
                                                  "public"
                                              ? Theme.of(context).primaryColor
                                              : Colors.black38,
                                          width: homeController
                                                      .newRoomType.value ==
                                                  "public"
                                              ? 5
                                              : 1),
                                      color: Colors.white),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Icon(
                                      Ionicons.earth,
                                      color: Theme.of(context).primaryColor,
                                      size: 80,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 0.01.sh,
                                ),
                                Text(
                                  public_room,
                                  style: TextStyle(
                                      color: Colors.black87, fontSize: 18.sp),
                                )
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              homeController.newRoomType.value = "private";
                            },
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: homeController
                                                      .newRoomType.value ==
                                                  "private"
                                              ? Theme.of(context).primaryColor
                                              : Colors.black38,
                                          width: homeController
                                                      .newRoomType.value ==
                                                  "private"
                                              ? 5
                                              : 1),
                                      color: Colors.white),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Icon(
                                      Ionicons.shield_checkmark_outline,
                                      color: Theme.of(context).primaryColor,
                                      size: 80,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 0.01.sh,
                                ),
                                Text(
                                  private_room,
                                  style: TextStyle(
                                      color: Colors.black87, fontSize: 18.sp),
                                )
                              ],
                            ),
                          )
                        ],
                      );
                    }),
                    SizedBox(
                      height: 0.04.sh,
                    ),
                    Obx(() {
                      return InkWell(
                          onTap: () async {
                            if (homeController.newRoomType.value == "private") {
                              showAddCoHostBottomSheet(context, private: true);
                            } else {
                              showProductBottomSheet(context);
                              await productController.fetchUserProducts();
                            }
                          },
                          child: Container(
                            width: 0.8.sw,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Theme.of(context).primaryColor),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Text(
                                  homeController.newRoomType.value == "private"
                                      ? pick_friends_to_chat_with
                                      :proceed,
                                  style: TextStyle(
                                      fontSize: 18.sp, color: Colors.white),
                                ),
                              ),
                            ),
                          ));
                    })
                  ],
                ),
              );
            });
      });
    },
  );
}

Future<dynamic> showAddTitleDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            room_title,
            style: TextStyle(color: Colors.black, fontSize: 16.sp),
          ),
          children: [
            TextField(
              controller: homeController.roomTitleController,
              autofocus: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: const InputDecoration(
                border: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: enter_room_title,
              ),
              style: TextStyle(color: Colors.black, fontSize: 12.sp),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Text(
                      "$cancel".toUpperCase(),
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12.sp),
                    ),
                  ),
                  SizedBox(
                    width: 0.03.sw,
                  ),
                  InkWell(
                    onTap: () {
                      Get.closeAllSnackbars();
                      Get.back();
                    },
                    child: Text(
                      "$okay".toUpperCase(),
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12.sp),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      });
}

Future<dynamic> showAddCoHostBottomSheet(BuildContext context,
    {bool? private = false}) {
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
        userController.friendsToInviteCall();
        return DraggableScrollableSheet(
            initialChildSize: 0.8,
            expand: false,
            builder: (BuildContext productContext,
                ScrollController scrollController) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 0.01.sh,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          add_co_hosts,
                          style:
                              TextStyle(color: Colors.black87, fontSize: 16.sp),
                        ),
                        IconButton(
                            onPressed: () async {
                              Get.back();
                              if (private != null &&
                                  private == true &&
                                  homeController.roomHosts.length > 1) {
                                showProductBottomSheet(context);
                                await productController.fetchUserProducts();
                              }
                            },
                            icon: const Icon(Icons.done))
                      ],
                    ),
                    SizedBox(
                      height: 0.01.sh,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Container(
                        padding: const EdgeInsets.only(left: 15.0, right: 10.0),
                        height: 0.07.sh,
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(30)),
                        child: Row(
                          children: [
                            const Icon(
                              Ionicons.search,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              width: 0.03.sw,
                            ),
                            Expanded(
                              child: Center(
                                child: TextField(
                                  controller:
                                      userController.searchUsersController,
                                  autofocus: false,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  keyboardType: TextInputType.visiblePassword,
                                  onChanged: (text) {
                                    if (text.isNotEmpty) {
                                      userController.searchUsersWeAreFriends(
                                          userController
                                              .searchUsersController.text);
                                    } else {
                                      userController.friendsToInviteCall();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: search,
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16.sp,
                                        decoration: TextDecoration.none),
                                    border: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                      decoration: TextDecoration.none),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 0.01.sh,
                    ),
                    Obx(() {
                      return userController.allUsersLoading.isFalse
                          ? SizedBox(
                              height: 0.55.sh,
                              child: userController
                                      .searchedfriendsToInvite.isNotEmpty
                                  ? GridView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      // physics: ScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 0.9,
                                      ),
                                      itemCount: userController
                                          .searchedfriendsToInvite.length,
                                      itemBuilder: (context, index) {
                                        UserModel user = UserModel.fromJson(
                                            userController
                                                .searchedfriendsToInvite
                                                .elementAt(index));
                                        return InkWell(
                                          onTap: () {
                                            if (homeController.roomHosts
                                                .contains(user)) {
                                              homeController.roomHosts
                                                  .remove(user);
                                            } else {
                                              homeController.roomHosts
                                                  .add(user);
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              Obx(() {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                    child: user.profilePhoto ==
                                                                "" ||
                                                            user.profilePhoto ==
                                                                null
                                                        ? CircleAvatar(
                                                            radius: 35,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            foregroundImage: homeController
                                                                    .roomHosts
                                                                    .contains(
                                                                        user)
                                                                ? const AssetImage(
                                                                    "assets/icons/picked.png")
                                                                : const AssetImage(
                                                                    "assets/icons/profile_placeholder.png"),
                                                            backgroundImage:
                                                                const AssetImage(
                                                                    "assets/icons/profile_placeholder.png"))
                                                        : CircleAvatar(
                                                            radius: 35,
                                                            onBackgroundImageError:
                                                                (object,
                                                                        stackTrace) =>
                                                                    const Icon(Icons
                                                                        .error),
                                                            backgroundColor:
                                                                Colors.black38,
                                                            foregroundImage: homeController
                                                                    .roomHosts
                                                                    .contains(
                                                                        user)
                                                                ? const AssetImage(
                                                                    "assets/icons/picked.png")
                                                                : const AssetImage(
                                                                        "assets/icons/profile_placeholder.png")
                                                                    as ImageProvider,
                                                            backgroundImage:
                                                                NetworkImage(user
                                                                    .profilePhoto!),
                                                          ),
                                                  ),
                                                );
                                              }),
                                              Center(
                                                child: Text(
                                                  "${user.firstName!} ${user.lastName!}",
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 12.sp),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      })
                                  : const Text(no_users_to_add))
                          : const CircularProgressIndicator();
                    }),
                    SizedBox(
                      height: 0.02.sh,
                    ),
                    // InkWell(
                    //     onTap: () async {
                    //       Get.back();
                    //       if (private != null && private == true && _homeController.roomHosts.length > 1) {
                    //         showProductBottomSheet(context);
                    //         await _homeController.fetchUserProducts();
                    //       }
                    //     },
                    //     child: Button(text: "Continue", width: 0.9.sw))
                  ],
                ),
              );
            });
      });
    },
  );
}

generateProductImages(Product product) {
  for (var i = 0; i < product.images!.length; i++) {
    homeController.roomPickedImages
        .add(TokshowImage(product.images!.elementAt(i), true, false));
  }

  do {
    homeController.roomPickedImages
        .add(TokshowImage(imageplaceholder, false, false));
  } while (homeController.roomPickedImages.length < 6);
}

pickImage(BuildContext context) async {
  String path = await choseImageFromLocalFiles(context,
      aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 2));

  printOut("Path to picked image $path");

  homeController.roomPickedImages[homeController.roomPickedImages.indexOf(
          homeController.roomPickedImages.firstWhere((element) =>
              element.isReal == false && element.isPath == false))] =
      TokshowImage(path, false, true);
}
