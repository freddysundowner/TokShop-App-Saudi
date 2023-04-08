import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:tokshop/controllers/shop_controller.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/models/channel.dart';
import 'package:tokshop/screens/home/create_room.dart';
import 'package:tokshop/screens/profile/profile_all_products.dart';
import 'package:tokshop/screens/profile/user_profile.dart';
import 'package:tokshop/screens/shops/apply_to_sell.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/channel_controller.dart';
import '../../../controllers/room_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/upcoming_tokshow.dart';
import '../../../models/product.dart';
import '../../../models/tokshow_image.dart';
import '../../../models/user.dart';
import '../../../services/local_files_access_service.dart';
import '../../../utils/text.dart';
import '../../../utils/utils.dart';
import '../../../widgets/widgets.dart';

class NewUpcomingTokshow extends StatelessWidget {
  final UpcomingTokshow? roomModel;
  NewUpcomingTokshow({Key? key, this.roomModel}) : super(key: key) {
    homeController.roomPickedImages.value = [];
    homeController.roomHosts.value = [];
    homeController.eventTitleController.text = "";
    homeController.eventDate.value = null;
    homeController.roomPickedProduct.clear();
    homeController.eventDescriptiion.text = "";
    homeController.newRoomType.value = "";
    homeController.roomPickedChannel.value = [];

    if (roomModel == null) {
      homeController.roomHosts.add(Get.find<AuthController>().usermodel.value!);
    } else {
      homeController.eventTitleController.text = roomModel!.title!;
      homeController.eventDescriptiion.text = roomModel!.description!;
      homeController.roomPickedProduct.value = roomModel!.productIds!;
      homeController.eventDate.value =
          DateTime.fromMillisecondsSinceEpoch(roomModel!.eventDate!);
      homeController.newRoomType.value = roomModel!.roomType!;
      homeController.roomHosts.value = roomModel!.invitedhostIds!
          .map((e) => UserModel(
              profilePhoto: e.profilePhoto,
              bio: e.bio,
              id: e.id,
              firstName: e.firstName,
              lastName: e.lastName,
              userName: e.userName,
              email: e.email))
          .toList();
      homeController.roomOriginalHosts.value =
          roomModel!.invitedhostIds!.map((e) => e.id).toList();
      homeController.roomPickedChannel.value = roomModel!.channel ?? [];
    }
  }
  final TokShowController homeController = Get.find<TokShowController>();

  final ChannelController channelController = Get.find<ChannelController>();

  void toggleSwitch(bool value) {
    if (value == false) {
      homeController.newRoomType.value = "public";
    } else {
      homeController.newRoomType.value = "private";
    }
    homeController.isSwitched.value = value;
  }

  Future<void> _saveEvent(BuildContext context) async {
    if (homeController.eventTitleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(tokshow_title_is_required),
        ),
      );
      return;
    }
    if (homeController.roomPickedProduct.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(product_is_required),
        ),
      );
      return;
    }
    if (homeController.roomHosts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(add_atleast_one_host),
        ),
      );
      return;
    }
    if (homeController.eventDate.value?.millisecondsSinceEpoch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(date_is_required),
        ),
      );

      return;
    }
    if (homeController.eventDate.value!.difference(DateTime.now()).inMinutes <
        15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(date_must_be_greater),
        ),
      );
      return;
    }

    try {
      dynamic response;
      if (roomModel != null) {
        response = homeController.updateEvent(roomModel!.id!);
      } else {
        response = homeController.createEvent();
      }

      await showDialog(
        context: context,
        builder: (context) {
          return AsyncProgressDialog(
            response,
            message: Text(roomModel != null ? updating_event : creating_event),
            onError: (e) {},
          );
        },
      );

      homeController.fetchEvents();
      homeController.fetchMyEvents(FirebaseAuth.instance.currentUser!.uid);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            error_happened,
            style: TextStyle(color: Colors.red),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } finally {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            roomModel != null ? updated_successfully : saved_successfully,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var formatter = DateFormat('yyyy/MM/dd hh:mm');

    return Scaffold(
      appBar: AppBar(
        title:
            Text(roomModel != null ? liveShow_details : schedule_a_live_show),
        actions: [
          InkWell(
            onTap: () async {
              _saveEvent(context);
            },
            child: Container(
                margin: const EdgeInsets.only(right: 20, top: 15),
                child: Text(
                  roomModel != null ? update : save,
                  style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp),
                )),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Obx(
          () => Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: homeController.eventTitleController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 0.5,
                      ),
                    ),
                    filled: false,
                    hintText: title,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 0.5),
                        borderRadius: BorderRadius.circular(6.0)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 13),
                  ),
                  validator: (_) {
                    if (homeController.eventTitleController.text.isEmpty) {
                      return title_is_required;
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    showAddCoHostBottomSheet(context);
                    userController.searchUser();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: Colors.grey, width: 0.5)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$add_users (${homeController.roomHosts.length})",
                          style:
                              TextStyle(fontSize: 13.sm, color: primarycolor),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.grey,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (homeController.roomHosts.isNotEmpty)
                  ListView(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: homeController.roomHosts
                        .map((element) => InkWell(
                              onTap: () {
                                Get.find<UserController>()
                                    .getUserProfile(element.id!);
                                Get.to(() => UserProfile());
                              },
                              child: Row(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: element.profilePhoto!,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 5.0),
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.fill),
                                      ),
                                    ),
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(
                                      color: primarycolor,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                      Icons.supervised_user_circle_rounded,
                                      size: 40,
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            "${element.firstName!} ${element.lastName!}",
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: primarycolor),
                                          ),
                                        ),
                                        if (homeController.roomHosts.indexWhere(
                                                (e) => element.id! == e.id!) !=
                                            0)
                                          InkWell(
                                            onTap: () {
                                              homeController.roomHosts
                                                  .removeWhere((e) =>
                                                      element.id! == e.id);
                                            },
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                InkWell(
                  onTap: () async {
                    if (authController.usermodel.value!.shopId == null) {
                      showDialog(
                        context: Get.context!,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(confirmation),
                            content: const Text(you_do_not_have_shop),
                            actions: [
                              TextButton(
                                child: const Text(yes),
                                onPressed: () async {
                                  Navigator.pop(context, false);
                                  Get.to(() => ApplyToSell());
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
                      showProductBottomSheet(context);
                      await productController.getAllroducts(
                          userid: FirebaseAuth.instance.currentUser!.uid);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: Colors.grey, width: 0.5)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            homeController.roomPickedProduct.isNotEmpty
                                ? "$change ${homeController.roomPickedProduct.map((element) => element.name).toList()}"
                                : tag_product,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                TextStyle(fontSize: 16.sm, color: primarycolor),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.grey,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 0.01.sh,
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
                  height: 0.01.sh,
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 13, horizontal: 10),
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              border:
                                  Border.all(color: Colors.grey, width: 0.5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                select_Channel,
                                style: TextStyle(
                                  color: primarycolor,
                                  fontSize: 14.sp,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.grey,
                                size: 20,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 0.01.sh,
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
                InkWell(
                  onTap: () {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true,
                        minTime: DateTime(2020, 5, 5, 20, 50),
                        maxTime: DateTime(2030, 6, 7, 05, 09),
                        theme: const DatePickerTheme(
                            backgroundColor: Colors.red,
                            itemStyle: TextStyle(color: Colors.white),
                            cancelStyle: TextStyle(color: Colors.white),
                            doneStyle: TextStyle(color: kPrimaryColor)),
                        onConfirm: (date) {
                      homeController.eventDate.value = date;
                      homeController.eventDateController.text = date.toString();
                    }, locale: LocaleType.en);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: Colors.grey, width: 0.5)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          homeController.eventDate.value != null
                              ? formatter
                                  .format(homeController.eventDate.value!)
                                  .toString()
                              : when_do_you_want_to_go_live,
                          style:
                              TextStyle(fontSize: 16.sm, color: primarycolor),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.grey,
                          size: 20,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 0.01.sh,
                ),
                Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        text_chat,
                        style: TextStyle(color: primarycolor, fontSize: 16.sp),
                      ),
                      Switch(
                          activeColor: kPrimaryColor,
                          activeTrackColor: kPrimaryColor.withOpacity(0.50),
                          value: (homeController.allowchat.value),
                          onChanged: (value) async {
                            homeController.allowchat.value = value;
                            homeController.allowchat.refresh();
                          })
                    ],
                  ),
                ),
                Text(can_audience_send_messages,
                    style: TextStyle(color: kTextColor, fontSize: 12.sp)),
                SizedBox(
                  height: 0.01.sh,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                            invite_users,
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          IconButton(
                              onPressed: () async {
                                Get.back();
                                if (private != null &&
                                    private == true &&
                                    homeController.roomHosts.length > 1) {
                                  showProductBottomSheet(context);
                                  await productController.getAllroducts(
                                      userid: FirebaseAuth
                                          .instance.currentUser!.uid);
                                }
                              },
                              icon: const Icon(
                                Icons.done,
                              ))
                        ],
                      ),
                      SizedBox(
                        height: 0.01.sh,
                      ),
                      Center(
                        child: TextField(
                          controller: userController.searchUsersController,
                          autofocus: false,
                          autocorrect: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.visiblePassword,
                          onChanged: (text) {
                            if (text.isNotEmpty) {
                              userController.searchUsersWeAreFriends(
                                  userController.searchUsersController.text);
                            } else {
                              userController.friendsToInviteCall();
                            }
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 13),
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            hintText: search_friends,
                            border: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                          ),
                          style: TextStyle(
                              fontSize: 16.sp, decoration: TextDecoration.none),
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
                                                      .indexWhere((element) =>
                                                          element.id! ==
                                                          user.id) ==
                                                  -1) {
                                                homeController.roomHosts
                                                    .add(user);
                                              } else {
                                                homeController.roomHosts
                                                    .removeWhere((element) =>
                                                        element.id! ==
                                                        user.id!);
                                              }
                                            },
                                            child: Column(
                                              children: [
                                                Obx(() {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Center(
                                                      child: user.profilePhoto ==
                                                                  "" ||
                                                              user.profilePhoto ==
                                                                  null
                                                          ? CircleAvatar(
                                                              radius: 30,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              foregroundImage: homeController
                                                                          .roomHosts
                                                                          .indexWhere((element) =>
                                                                              element.id! ==
                                                                              user
                                                                                  .id!) !=
                                                                      -1
                                                                  ? const AssetImage(
                                                                      "assets/icons/picked.png")
                                                                  : const AssetImage(
                                                                      "assets/icons/profile_placeholder.png"),
                                                              backgroundImage:
                                                                  const AssetImage(
                                                                      "assets/icons/profile_placeholder.png"))
                                                          : CircleAvatar(
                                                              radius: 30,
                                                              onBackgroundImageError: (object,
                                                                      stackTrace) =>
                                                                  const Icon(Icons
                                                                      .error),
                                                              backgroundColor:
                                                                  Colors
                                                                      .black38,
                                                              foregroundImage: homeController.roomHosts.indexWhere((element) =>
                                                                          element
                                                                              .id! ==
                                                                          user
                                                                              .id!) !=
                                                                      -1
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
                                    : const Text(
                                        no_users_to_add,
                                        style: TextStyle(
                                            color: Styles.dullGreyColor),
                                      ))
                            : const CircularProgressIndicator(
                                color: primarycolor,
                              );
                      }),
                    ],
                  ),
                );
              });
        });
      },
    );
  }

  List<Widget> listMyWidgets(items, StateSetter setState) {
    List<Widget> list = [];

    for (var item in items) {
      list.add(GestureDetector(
        child: Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            decoration: BoxDecoration(
              color: getColor(item.title!) ? kPrimaryColor : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                  color: getColor(item.title!) ? kPrimaryColor : primarycolor),
              boxShadow: getColor(item.title!)
                  ? [
                      const BoxShadow(
                        color: primarycolor,
                        blurRadius: 4,
                      ),
                    ]
                  : [],
            ),
            child: Text(
              item.title!,
              style: TextStyle(
                  fontSize: 15,
                  color: getColor(item.title!) ? Colors.white : Colors.black),
            ),
          ),
        ),
        onTap: () {
          int i = homeController.roomPickedChannel
              .indexWhere((element) => element.id == item.id);
          if (i == -1) {
            homeController.roomPickedChannel.add(item);
          } else {
            homeController.roomPickedChannel.removeAt(i);
          }
          setState(() => {});
        },
      ));
    }
    return list;
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

    homeController.roomPickedImages.insert(
        homeController.roomPickedImages.indexWhere(
            (element) => element.isReal == false && element.isPath == false),
        TokshowImage(path, false, true));
  }
}
