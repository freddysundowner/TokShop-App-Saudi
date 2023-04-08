import 'package:flutter_svg/flutter_svg.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/screens/notifications/notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/screens/profile/user_profile.dart';
import 'package:tokshop/screens/room/upcomingTokShow/new_upcoming_tokshow.dart';
import 'package:tokshop/screens/home/search_results.dart';
import 'package:tokshop/widgets/bottom_sheet_dialog.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/global.dart';
import '../../controllers/room_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../models/tokshow.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';
import 'create_room.dart';
import 'home_page.dart';

//ignore: must_be_immutable
class MainPage extends StatelessWidget {
  MainPage({Key? key}) : super(key: key);

  final GlobalController _global = Get.find<GlobalController>();
  AuthController authController = Get.find<AuthController>();

  final TokShowController _homeController = Get.find<TokShowController>();
  ShopController shopController = Get.find<ShopController>();

  OwnerId currentUser = OwnerId(
      id: Get.find<AuthController>().usermodel.value!.id,
      bio: Get.find<AuthController>().usermodel.value!.bio,
      email: Get.find<AuthController>().usermodel.value!.email,
      firstName: Get.find<AuthController>().usermodel.value!.firstName,
      lastName: Get.find<AuthController>().usermodel.value!.lastName,
      userName: Get.find<AuthController>().usermodel.value!.userName,
      profilePhoto: Get.find<AuthController>().usermodel.value!.profilePhoto);

  final List<Widget> _pages = [
    HomePage(),
    SearchResults(),
    Notifications(),
    UserProfile()
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: _pages[_global.tabPosition.value],
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: primarycolor,
                width: 0.5,
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    _global.tabPosition.value = 0;
                  },
                  child: Image.asset(
                    "assets/icons/home.png",
                    color: _global.tabPosition.value == 0
                        ? kPrimaryColor
                        : kTextColor,
                    width: 30,
                  ),
                ),
                InkWell(
                  onTap: () {
                    _global.tabPosition.value = 1;
                  },
                  child: SvgPicture.asset(
                    "assets/icons/SearchIcon.svg",
                    color: _global.tabPosition.value == 1
                        ? kPrimaryColor
                        : kTextColor,
                    width: 30,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    showFilterBottomSheet(
                        context,
                        Container(
                          color: const Color(0Xfff4f5fa),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  homeController.createRoomView();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 30),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        go_live_now,
                                        style: TextStyle(fontSize: 21),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.grey,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Divider(),
                              InkWell(
                                onTap: () {
                                  Get.to(() => NewUpcomingTokshow());
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 30),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        schedule_a_live_show,
                                        style: TextStyle(fontSize: 21),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: Colors.grey,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        initialChildSize: 0.25);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: kPrimaryColor),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: const Text(
                      go_live,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _global.tabPosition.value = 2;
                  },
                  child: SvgPicture.asset(
                    "assets/icons/Bell.svg",
                    color: _global.tabPosition.value == 2
                        ? kPrimaryColor
                        : kTextColor,
                    width: 23,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.find<UserController>()
                        .getUserProfile(authController.currentuser!.id!);
                    _global.tabPosition.value = 3;
                  },
                  child: Obx(() {
                    return CachedNetworkImage(
                      imageUrl: authController.usermodel.value!.profilePhoto!,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 0.08.sw,
                        height: 0.05.sh,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) => Transform.scale(
                          scale: 0.3,
                          child: const CircularProgressIndicator(
                            color: Colors.black,
                          )),
                      errorWidget: (context, url, error) => Image.asset(
                        "assets/icons/profile.png",
                        color: _global.tabPosition.value == 3
                            ? kPrimaryColor
                            : kTextColor,
                        width: 0.08.sw,
                        height: 0.05.sh,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
