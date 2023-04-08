import 'package:flutter_svg/flutter_svg.dart';
import 'package:tokshop/controllers/global.dart';
import 'package:tokshop/controllers/wishlist_controller.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/models/tokshow.dart';
import 'package:tokshop/models/user.dart';
import 'package:tokshop/screens/chats/all_chats_page.dart';
import 'package:tokshop/screens/chats/chat_room_page.dart';
import 'package:tokshop/screens/home/main_page.dart';
import 'package:tokshop/screens/home/market_place_products.dart';
import 'package:tokshop/screens/orders/orders.dart';
import 'package:tokshop/screens/orders/purchases.dart';
import 'package:tokshop/screens/products/components/product_list_single_item.dart';
import 'package:tokshop/screens/profile/components/profile_image.dart';
import 'package:tokshop/screens/profile/components/user_actions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:share/share.dart';
import 'package:tokshop/screens/profile/components/user_reviews_card.dart';
import 'package:tokshop/screens/profile/edit_profile.dart';
import 'package:tokshop/screens/profile/followers_following_page.dart';
import 'package:tokshop/screens/profile/profile_all_products.dart';
import 'package:tokshop/screens/profile/user_review_dialog.dart';
import 'package:tokshop/screens/room/all_tokshows.dart';
import 'package:tokshop/screens/room/components/room_card.dart';
import 'package:tokshop/screens/room/previous_shows.dart';
import 'package:tokshop/screens/menu/menu_page.dart';
import 'package:tokshop/screens/shops/apply_to_sell.dart';
import 'package:tokshop/screens/wallet/wallet_page.dart';
import 'package:tokshop/screens/wishlist/wishlist.dart';
import 'package:tokshop/utils/size_config.dart';
import 'package:tokshop/widgets/single_product_item.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/channel_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/room_controller.dart';
import '../../controllers/shop_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/recording.dart';
import '../../services/dynamic_link_services.dart';
import '../../services/recordings_api.dart';
import '../../services/user_api.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';
import '../room/play_recording_page.dart';

class UserProfile extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final UserController _userController = Get.find<UserController>();
  final ShopController shopController = Get.find<ShopController>();
  final ProductController productController = Get.find<ProductController>();
  final ChannelController channelController =
      Get.put<ChannelController>(ChannelController());
  final ChatController _chatController = Get.find<ChatController>();
  final GlobalController globalController = Get.find<GlobalController>();

  final TokShowController _homeController = Get.find<TokShowController>();
  WishListController favproductController = Get.find<WishListController>();
  final nameError = "";

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  UserProfile({Key? key}) : super(key: key);

  List<String> tabs = [shop, reviews];
  bool _owner() {
    return FirebaseAuth.instance.currentUser!.uid ==
        _userController.currentProfile.value.id;
  }

  Future<void> _applyToSell() async {
    Get.to(() => ApplyToSell());
  }

  Obx _checkShopStatus() {
    return Obx(() {
      return _owner() && _userController.currentProfile.value.shopId == null
          ? InkWell(
              onTap: () async {
                await _applyToSell();
              },
              child: Center(
                  child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                    color: primarycolor,
                    borderRadius: BorderRadius.circular(30)),
                child: Row(
                  children: [
                    Text(
                      "Apply to sell",
                      style: TextStyle(fontSize: 11.sp, color: Colors.white),
                    ),
                  ],
                ),
              )),
            )
          : Container();
    });
  }

  @override
  Widget build(BuildContext context) {
    _homeController.onChatPage.value = false;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          _checkShopStatus(),
          SizedBox(
            width: 15.w,
          ),
          Obx(() =>
              _userController.currentProfile.value.shopId != null && _owner()
                  ? InkWell(
                      onTap: () async {
                        addProduct(context);
                      },
                      child: const Icon(
                        Icons.add,
                        color: primarycolor,
                      ),
                    )
                  : Container()),
          SizedBox(
            width: 15.w,
          ),
          InkWell(
            onTap: () async {
              DynamicLinkService()
                  .generateShareLink(_userController.currentProfile.value.id!,
                      type: "profile",
                      title:
                          "Check ${_userController.currentProfile.value.firstName} profile on Mazadakt",
                      imageurl:
                          _userController.currentProfile.value.profilePhoto)
                  .then((value) async {
                await Share.share(value,
                    subject:
                        "Share ${_userController.currentProfile.value.firstName!} Profile");
              });
            },
            child: const Icon(
              Icons.ios_share,
              color: primarycolor,
            ),
          ),
          SizedBox(
            width: 15.w,
          ),
          Obx(() {
            if (FirebaseAuth.instance.currentUser!.uid !=
                _userController.currentProfile.value.id) {
              return InkWell(
                onTap: () {
                  userActionSheet(context,
                      user: _userController.currentProfile.value);
                },
                child: const Icon(
                  Icons.more_vert,
                  color: primarycolor,
                ),
              );
            }
            return Container();
          }),
          Obx(() {
            if (FirebaseAuth.instance.currentUser!.uid ==
                _userController.currentProfile.value.id) {
              return InkWell(
                onTap: () {
                  Get.to(() => MenuPage());
                },
                child: const Icon(
                  Icons.filter_list,
                  color: primarycolor,
                ),
              );
            }
            return Container();
          }),
          SizedBox(
            width: 15.w,
          ),
        ],
      ),
      body: Obx(
        () {
          if (_userController.profileLoading.isTrue) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 90,
                collapsedHeight: 90,
                automaticallyImplyLeading: false,
                flexibleSpace: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            ProfileImage(
                              path: _userController
                                  .currentProfile.value.profilePhoto!,
                              width: 60,
                              height: 60,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "${_userController.currentProfile.value.firstName} ${_userController.currentProfile.value.lastName}",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          color: primarycolor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Icon(
                                      Icons.verified_user_outlined,
                                      size: 18,
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    buildProductRatingWidget(_userController
                                                    .curentUserReview.value ==
                                                null ||
                                            _userController
                                                .curentUserReview.value!.isEmpty
                                        ? 0.toDouble()
                                        : _userController
                                                .curentUserReview.value!
                                                .map((e) => e.rating)
                                                .toList()
                                                .reduce((value, element) =>
                                                    value + element) /
                                            _userController.curentUserReview
                                                .value!.length),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    if (_userController.canreview.value)
                                      InkWell(
                                        onTap: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return UserReviewDialog(
                                                user: _userController
                                                    .currentProfile.value,
                                              );
                                            },
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 7),
                                          child: Center(
                                            child: Text(
                                              "$rate +",
                                              style: TextStyle(
                                                  color: kPrimaryColor,
                                                  fontSize: 12.sp),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(
                                  height: 0.005.sh,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        _userController.getUserFollowing(
                                            _userController
                                                .currentProfile.value.id!);
                                        Get.to(FollowersFollowingPage(
                                            "Following"));
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            getShortForm(
                                                double.parse(_userController
                                                    .currentProfile
                                                    .value
                                                    .following
                                                    .length
                                                    .toString()),
                                                decimal: 0),
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: primarycolor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 0.01.sw,
                                          ),
                                          Text(
                                            following,
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: primarycolor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 0.01.sh,
                                    ),
                                    Text("~"),
                                    SizedBox(
                                      width: 0.01.sh,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _userController.getUserFollowers(
                                            _userController
                                                .currentProfile.value.id!);
                                        Get.to(FollowersFollowingPage(
                                            "Followers"));
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            getShortForm(
                                                double.parse(_userController
                                                    .currentProfile
                                                    .value
                                                    .followers
                                                    .length
                                                    .toString()),
                                                decimal: 0),
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                color: primarycolor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 0.01.sw,
                                          ),
                                          Text(
                                            followers,
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: primarycolor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 0.01.sh,
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Column(
                      children: [
                        if (_userController
                            .currentProfile.value.bio!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, top: 10, bottom: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _userController.currentProfile.value.bio!,
                                style: TextStyle(
                                    fontSize: 14.sp, color: Colors.black),
                              ),
                            ),
                          ),
                        SizedBox(
                          height: 0.01.sh,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (_userController.currentProfile.value.id !=
                                  FirebaseAuth.instance.currentUser!.uid)
                                InkWell(
                                  onTap: () async {
                                    if (_userController
                                            .currentProfile.value.followers
                                            .indexWhere((element) =>
                                                element.id ==
                                                FirebaseAuth.instance
                                                    .currentUser!.uid) !=
                                        -1) {
                                      _userController
                                          .currentProfile.value.followers
                                          .removeWhere((element) =>
                                              element.id ==
                                              FirebaseAuth
                                                  .instance.currentUser!.uid);
                                      _userController.currentProfile.refresh();

                                      await UserAPI().unFollowAUser(
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          _userController
                                              .currentProfile.value.id!);
                                    } else {
                                      _userController
                                          .currentProfile.value.followers
                                          .add(UserModel(
                                              id: FirebaseAuth
                                                  .instance.currentUser!.uid));
                                      _userController.currentProfile.refresh();
                                      await UserAPI().followAUser(
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          _userController
                                              .currentProfile.value.id!);
                                    }
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    decoration: BoxDecoration(
                                        color: _userController.currentProfile
                                                    .value.followers
                                                    .indexWhere((element) =>
                                                        element.id ==
                                                        FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid) !=
                                                -1
                                            ? kPrimaryColor
                                            : primarycolor,
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 7, horizontal: 15),
                                      child: Center(
                                        child: Text(
                                          _userController.currentProfile.value
                                                      .followers
                                                      .indexWhere((element) =>
                                                          element.id ==
                                                          FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid) !=
                                                  -1
                                              ? following
                                              : follow,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.sp),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Obx(() => _userController.currentProfile.value
                                              .receivemessages !=
                                          null &&
                                      _userController.currentProfile.value
                                              .receivemessages ==
                                          true
                                  ? InkWell(
                                      onTap: () {
                                        if (_owner()) {
                                          Get.to(AllChatsPage());
                                        } else {
                                          _chatController.currentChat.value =
                                              [];
                                          _chatController.currentChatId.value =
                                              "";
                                          _chatController.getPreviousChat(
                                              _userController
                                                  .currentProfile.value);
                                          _homeController.onChatPage.value =
                                              true;
                                          Get.to(ChatRoomPage(_userController
                                              .currentProfile.value));
                                        }
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        decoration: BoxDecoration(
                                            color: _owner()
                                                ? primarycolor
                                                : Colors.white,
                                            border: Border.all(
                                                color: _owner()
                                                    ? Colors.white
                                                    : primarycolor
                                                        .withOpacity(0.5)),
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 7, horizontal: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Ionicons
                                                    .chatbubble_ellipses_outline,
                                                color: _owner()
                                                    ? Colors.white
                                                    : primarycolor,
                                                size: 18,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Message${_owner() ? "s" : ""}",
                                                style: TextStyle(
                                                    color: _userController
                                                                .currentProfile
                                                                .value
                                                                .id ==
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid
                                                        ? Colors.white
                                                        : primarycolor,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container()),
                              if (_owner())
                                InkWell(
                                  onTap: () async {
                                    Get.to(() => EditProfile(
                                          profile: _userController
                                              .currentProfile.value,
                                        ));
                                  },
                                  child: IntrinsicWidth(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: primarycolor
                                                  .withOpacity(0.5)),
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 7, horizontal: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.edit,
                                              color: Styles.darkColor,
                                              size: 18,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              edit_profile,
                                              style: TextStyle(
                                                  color: primarycolor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: 1, // 1000 list items
                ),
              ),
              if (_owner())
                SliverAppBar(
                    automaticallyImplyLeading: false,
                    toolbarHeight: 80,
                    flexibleSpace: Container(
                      margin:
                          const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Column(
                        children: [
                          const Divider(),
                          Row(
                            children: [
                              const Text(
                                "Switch to profile",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primarycolor),
                              ),
                              Expanded(
                                child: Container(
                                  height: 35,
                                  margin: const EdgeInsets.only(left: 70),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(
                                      25.0,
                                    ),
                                  ),
                                  child: TabBar(
                                    indicatorColor: Colors.blue[100],
                                    controller: globalController
                                        .userSwitchtabController.value,
                                    labelStyle: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    indicator: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        25.0,
                                      ),
                                      color: kPrimaryColor,
                                    ),
                                    labelColor: Colors.black,
                                    unselectedLabelColor: Colors.black,
                                    onTap: (index) {
                                      globalController.switchtabIndex.value =
                                          index;
                                    },
                                    tabs: const [
                                      Tab(
                                        child: Text(
                                          "Buyer",
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      Tab(
                                        child: Text(
                                          "Seller",
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              if (globalController.switchtabIndex.value == 1 &&
                  _userController.currentProfile.value.shopId != null)
                SliverAppBar(
                    automaticallyImplyLeading: false,
                    toolbarHeight: 80,
                    flexibleSpace: Container(
                      margin:
                          const EdgeInsets.only(left: 20, top: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_owner())
                            InkWell(
                              onTap: () {
                                Get.to(() => WalletPage());
                              },
                              child: Column(
                                children: [
                                  Text(
                                    "Account Balance",
                                    style: TextStyle(
                                        color: primarycolor, fontSize: 14.sp),
                                  ),
                                  Obx(() {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "$currencySymbol ${getShortForm(_userController.currentProfile.value.wallet!)}",
                                          style: TextStyle(
                                              color: primarycolor,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        if (_userController.currentProfile.value
                                                    .pendingWallet !=
                                                null &&
                                            _userController.currentProfile.value
                                                    .pendingWallet! >
                                                0)
                                          Text(
                                            " + ${getShortForm(_userController.currentProfile.value.pendingWallet!)} pending",
                                            style: TextStyle(
                                                color: primarycolor,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600),
                                          ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          if (!_owner())
                            Column(
                              children: [
                                Text(
                                  "Tokshows",
                                  style: TextStyle(
                                      color: primarycolor, fontSize: 14.sp),
                                ),
                                Obx(() {
                                  return Text(
                                    "${_userController.currentProfile.value.tokshows}",
                                    style: TextStyle(
                                        color: primarycolor,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold),
                                  );
                                }),
                              ],
                            ),
                          Container(
                            height: 25,
                            color: primarycolor,
                            width: 0.5,
                          ),
                          Column(
                            children: [
                              Text(
                                "Sales",
                                style: TextStyle(
                                    color: primarycolor, fontSize: 14.sp),
                              ),
                              if (_userController.usersummary.value != null)
                                Text(
                                  _userController.usersummary
                                              .value["totalSales"] !=
                                          0
                                      ? ("${currencySymbol + getFormattedCurrent(double.parse(_userController.usersummary.value["totalSales"]["total"].toString()))} (${_userController.usersummary.value["totalSales"]["count"].toString()})")
                                      : _userController
                                          .usersummary.value["totalSales"]
                                          .toString(),
                                  style: TextStyle(
                                      color: primarycolor,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                          Container(
                            height: 25,
                            color: primarycolor,
                            width: 0.5,
                          ),
                          InkWell(
                            onTap: () {
                              shopController.currentShop.value =
                                  _userController.currentProfile.value.shopId!;
                              productController.getAllroducts(
                                  userid:
                                      _userController.currentProfile.value.id!);
                              Get.to(() => ProfileProducts(
                                    userid: _userController
                                        .currentProfile.value.id!,
                                  ));
                            },
                            child: Column(
                              children: [
                                Text(
                                  "Listings",
                                  style: TextStyle(
                                      color: primarycolor, fontSize: 14.sp),
                                ),
                                if (_userController.usersummary.value != null)
                                  Text(
                                    _userController
                                        .usersummary.value["products"]
                                        .toString(),
                                    style: TextStyle(
                                        color: primarycolor,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              if (_userController.currentProfile.value.shopId == null &&
                  _owner() &&
                  globalController.switchtabIndex.value == 1)
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        const Text(interested_in_selling,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: primarycolor)),
                        const SizedBox(
                          height: 15,
                        ),
                        InkWell(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: primarycolor,
                                border: Border.all(color: Colors.grey)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Text(
                              "Create a brand",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onTap: () {
                            Get.to(() => ApplyToSell());
                          },
                        ),
                      ],
                    ),
                  );
                }, childCount: 1)),
              if (globalController.switchtabIndex.value == 1 &&
                      _userController.currentProfile.value.shopId != null ||
                  !_owner())
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        TabBar(
                          indicatorPadding: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          indicatorWeight: 2,
                          isScrollable: true,
                          indicatorColor: Colors.blue[100],
                          controller:
                              globalController.sellertabController.value,
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          labelColor: primarycolor,
                          unselectedLabelColor: Colors.black,
                          tabs: [
                            const Tab(
                              child: Text(shop),
                            ),
                            if (_owner())
                              const Tab(
                                child: Text("Orders"),
                              ),
                            const Tab(
                              child: Text(reviews),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            child: TabBarView(
                                controller:
                                    globalController.sellertabController.value,
                                children: [
                                  ListView(
                                    shrinkWrap: false,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: ShopSilverListItems(),
                                  ),
                                  if (_owner()) OrdersWidget(),
                                  if (_userController.curentUserReview.value !=
                                          null &&
                                      _userController
                                          .curentUserReview.value!.isNotEmpty)
                                    UserReviewsCard(
                                      reviews: _userController
                                          .curentUserReview.value,
                                    ),
                                  if (_userController.curentUserReview.value ==
                                          null ||
                                      _userController
                                          .curentUserReview.value!.isEmpty)
                                    Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const SizedBox(height: 50),
                                          SvgPicture.asset(
                                            "assets/icons/review.svg",
                                            color: kTextColor,
                                            width: 40,
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            no_reviews_yet,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ]),
                          ),
                        )
                      ],
                    ),
                  );
                }, childCount: 1)),
              if (globalController.switchtabIndex.value == 0 && _owner())
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                  return SizedBox(
                    height: 500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        TabBar(
                          indicatorPadding: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          indicatorWeight: 2,
                          isScrollable: true,
                          indicatorColor: Colors.blue[100],
                          controller: globalController.buyertabcontroller.value,
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          labelColor: primarycolor,
                          unselectedLabelColor: Colors.black,
                          tabs: const [
                            Tab(
                              child: Text("Wishlist"),
                            ),
                            Tab(
                              child: Text("Purchases"),
                            )
                          ],
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            child: TabBarView(
                                controller:
                                    globalController.buyertabcontroller.value,
                                children: [
                                  favproductController.products.isNotEmpty
                                      ? ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          padding: const EdgeInsets.all(8),
                                          itemCount: favproductController
                                              .products.length,
                                          itemBuilder: (context, index) {
                                            Product product =
                                                favproductController
                                                    .products[index];
                                            return ProductListSingleItem(
                                                product: product,
                                                from: "wishlist");
                                          })
                                      : Column(
                                          children: [
                                            const SizedBox(
                                              height: 50,
                                            ),
                                            Text(
                                              "Your wishlist is empty",
                                              style: TextStyle(
                                                  color: primarycolor,
                                                  fontSize: 18.sp),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                productController
                                                    .selectedChannel
                                                    .value = null;
                                                productController
                                                    .selectedInterest
                                                    .value = null;
                                                productController
                                                    .getAllroducts();
                                                Get.to(() =>
                                                    MarketPlaceProducts(
                                                        channels:
                                                            productController
                                                                .categories
                                                                .value));
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    color: primarycolor),
                                                child: Text(
                                                  "Browse more listings",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.sp),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                  PurchasesWidget()
                                ]),
                          ),
                        )
                      ],
                    ),
                  );
                }, childCount: 1)),
            ],
          );
        },
      ),
    );
  }

  Widget _shopProducts() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (productController.profileproducts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              listings,
              style: TextStyle(
                  fontSize: 18.0.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
        Obx(() {
          if (productController.loading.value == true) {
            return const Center(
              child: CircularProgressIndicator(
                color: primarycolor,
              ),
            );
          }

          return productController.profileproducts.isNotEmpty
              ? Column(
                  children: [
                    GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: productController.profileproducts.length,
                      itemBuilder: (context, index) {
                        return SingleproductItem(
                          element: productController.profileproducts[index],
                          imageHeight: 130,
                          action: true,
                        );
                      },
                    ),
                    if (productController.allProductsCount.value >
                        productController.profileproducts.length)
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          width: MediaQuery.of(Get.context!).size.width * 0.9,
                          child: const Text(
                            see_all_listings,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: primarycolor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        onTap: () {
                          Get.to(() => ProfileProducts(
                                userid: _userController.currentProfile.value.id,
                              ));
                        },
                      ),
                  ],
                )
              : Column(
                  children: [
                    if (_userController.currentProfile.value.shopId == null &&
                        _userController
                                .currentProfile.value.shopId?.ownerId?.id ==
                            FirebaseAuth.instance.currentUser!.uid)
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(interested_in_selling,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: primarycolor)),
                            const SizedBox(
                              height: 15,
                            ),
                            InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: const Text(
                                  apply_to_sell,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: primarycolor),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              onTap: () {
                                Get.to(() => ApplyToSell());
                              },
                            ),
                          ],
                        ),
                      ),
                    if (_userController.currentProfile.value.shopId == null &&
                        _userController
                                .currentProfile.value.shopId?.ownerId?.id !=
                            FirebaseAuth.instance.currentUser!.uid)
                      const Center(
                          child: Text(
                        we_are_taking_some_cool_pictures,
                        style: TextStyle(
                            color: Styles.dullGreyColor, fontSize: 15.0),
                        textAlign: TextAlign.center,
                      )),
                    if (_userController.currentProfile.value.shopId != null &&
                        _userController
                                .currentProfile.value.shopId?.ownerId?.id ==
                            FirebaseAuth.instance.currentUser!.uid)
                      Center(
                          child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: const Text(
                          "You have not listed any product",
                          style: TextStyle(color: primarycolor, fontSize: 15.0),
                          textAlign: TextAlign.center,
                        ),
                      ))
                  ],
                );
        }),
      ],
    );
  }

  List<Widget> ShopSilverListItems() {
    return [userShows(), _shopProducts(), previousShows()];
  }

  userSocialAccounts() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (_userController.currentProfile.value.twitter
              .toString()
              .isNotEmpty)
            InkWell(
              onTap: () {
                launchURL(
                    _userController.currentProfile.value.twitter.toString());
              },
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/twitter.png",
                    width: 30,
                  ),
                  SizedBox(
                    width: 0.01.sw,
                  ),
                  Text(
                    twitter,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: primarycolor,
                    ),
                  ),
                  SizedBox(
                    width: 0.01.sw,
                  ),
                ],
              ),
            ),
          if (_userController.currentProfile.value.instagram
              .toString()
              .isNotEmpty)
            InkWell(
              onTap: () {
                launchURL(
                    _userController.currentProfile.value.instagram.toString());
              },
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/instagram.png",
                    width: 26,
                  ),
                  SizedBox(
                    width: 0.01.sw,
                  ),
                  Text(
                    instagram,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: primarycolor,
                    ),
                  ),
                  SizedBox(
                    width: 0.01.sw,
                  ),
                ],
              ),
            ),
          if (_userController.currentProfile.value.facebook
              .toString()
              .isNotEmpty)
            InkWell(
              onTap: () {
                launchURL(
                    _userController.currentProfile.value.facebook.toString());
              },
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/facebook.png",
                    width: 30,
                  ),
                  SizedBox(
                    width: 0.01.sw,
                  ),
                  Text(
                    facebook,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: primarycolor,
                    ),
                  ),
                  SizedBox(
                    width: 0.01.sw,
                  ),
                ],
              ),
            ),
          if (_userController.currentProfile.value.linkedIn
              .toString()
              .isNotEmpty)
            InkWell(
              onTap: () {
                launchURL(
                    _userController.currentProfile.value.linkedIn.toString());
              },
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/linkedin.png",
                    width: 30,
                  ),
                  SizedBox(
                    width: 0.01.sw,
                  ),
                  Text(
                    linkedIn,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: primarycolor,
                    ),
                  ),
                  SizedBox(
                    width: 0.01.sw,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  userShows() {
    return Obx(
      () => _homeController.userRoomsList.isEmpty
          ? Container()
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    shows,
                    style: TextStyle(
                        fontSize: 18.0.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Obx(
                  () {
                    if (_homeController.userRoomsList.isEmpty) {
                      return Center(
                        child: Text(
                          no_active_shows,
                          style:
                              TextStyle(color: primarycolor, fontSize: 18.sp),
                        ),
                      );
                    }
                    return _homeController.isLoading.isFalse
                        ? SizedBox(
                            height: 190,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _homeController.userRoomsList.length,
                                itemBuilder: (context, index) {
                                  Tokshow roomModel =
                                      _homeController.userRoomsList[index];

                                  var hosts = [];
                                  hosts = roomModel.hostIds!.length > 10
                                      ? roomModel.hostIds!.sublist(0, 10)
                                      : roomModel.hostIds!;
                                  return RoomCard(
                                      roomModel: roomModel,
                                      hosts: hosts,
                                      showChannel: false);
                                }),
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                            color: primarycolor,
                          ));
                  },
                ),
                Center(
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.white,
                          border: Border.all(color: Colors.grey)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      width: MediaQuery.of(Get.context!).size.width * 0.9,
                      child: const Text(
                        see_all_Shows,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primarycolor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onTap: () {
                      Get.to(() => AllTokShows(
                            userid: _userController.currentProfile.value.id,
                          ));
                    },
                  ),
                ),
              ],
            ),
    );
  }

  previousShows() {
    return Obx(
      () => _userController.userRecordings.isEmpty
          ? Container()
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    previous_shows,
                    style: TextStyle(
                        fontSize: 18.0.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Obx(
                  () {
                    if (_userController.userRecordings.isEmpty) {
                      return Center(
                        child: Text(
                          no_recorded_shows,
                          style:
                              TextStyle(color: primarycolor, fontSize: 18.sp),
                        ),
                      );
                    }
                    return _userController.userRecordingsLoading.isFalse
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: _userController.userRecordings.length,
                            itemBuilder: (context, index) {
                              Recording recordModel = Recording.fromJson(
                                  _userController.userRecordings
                                      .elementAt(index));
                              return InkWell(
                                onTap: () async {
                                  if (_homeController.currentRoom.value.id !=
                                      null) {
                                    await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: Colors.white,
                                            title:
                                                const Text(leave_current_room),
                                            content: const Text(
                                                to_play_recorded_leave_current_room),
                                            actions: [
                                              TextButton(
                                                child: const Text(leave),
                                                onPressed: () async {
                                                  _homeController
                                                      .leaveRoom(
                                                          idRoom:
                                                              _homeController
                                                                  .currentRoom
                                                                  .value
                                                                  .id)
                                                      .then((value) {
                                                    Get.offAll(MainPage());
                                                    _userController
                                                        .getUserProfile(
                                                            _userController
                                                                .currentProfile
                                                                .value
                                                                .id!);
                                                    Get.to(UserProfile());
                                                    Get.to(PlayRecordingPage(
                                                        roomId: recordModel
                                                            .roomId!.id!));
                                                    _homeController
                                                        .playRecordedRoom(
                                                            recordModel);
                                                  });
                                                },
                                              ),
                                              TextButton(
                                                child: const Text(not_now),
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  } else {
                                    Get.to(PlayRecordingPage(
                                        roomId: recordModel.roomId!.id!));
                                    _homeController
                                        .playRecordedRoom(recordModel);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFF5F6F9),
                                      borderRadius: BorderRadius.circular(20.0),
                                      border: Border.all(
                                          color: Colors.grey, width: 0.3)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Styles.smallButton
                                                    .withOpacity(0.12),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 3),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.record_voice_over,
                                                    color: Colors.red,
                                                  ),
                                                  Text(recorded_shows,
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 12.sp,
                                                          fontWeight:
                                                              FontWeight.w400))
                                                ],
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              Get.to(PlayRecordingPage(
                                                  roomId:
                                                      recordModel.roomId!.id!));
                                              _homeController.playRecordedRoom(
                                                  recordModel);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Styles.smallButton
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 5),
                                                child: Text(
                                                  replay,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 0.01.sh,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            recordModel.roomId!.title!,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Spacer(),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Theme(
                                              data: ThemeData.light(),
                                              child: PopupMenuButton<String>(
                                                color: Colors.white,
                                                itemBuilder:
                                                    (BuildContext context) {
                                                  return (FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid ==
                                                          _userController
                                                              .currentProfile
                                                              .value
                                                              .id)
                                                      ? {'Share', "Delete"}
                                                          .map((String choice) {
                                                          return PopupMenuItem<
                                                              String>(
                                                            onTap: () async {
                                                              Future.delayed(
                                                                  const Duration(
                                                                      seconds:
                                                                          0),
                                                                  () async {
                                                                if (choice ==
                                                                    "Share") {
                                                                  await shareRecording(
                                                                      recordModel);
                                                                } else if (choice ==
                                                                    "Delete") {
                                                                  var confirmation =
                                                                      await showConfirmationDialog(
                                                                          context,
                                                                          want_to_delete_recording);

                                                                  if (confirmation) {
                                                                    RecordingsAPI()
                                                                        .deleteRecording(recordModel
                                                                            .id)
                                                                        .then(
                                                                            (value) {
                                                                      if (value ==
                                                                          true) {
                                                                        const GetSnackBar(
                                                                          messageText:
                                                                              Text(
                                                                            recording_deleted,
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          ),
                                                                          backgroundColor:
                                                                              kPrimaryColor,
                                                                        );
                                                                      }
                                                                    });
                                                                    _userController.getUserRecordings(_userController
                                                                        .currentProfile
                                                                        .value
                                                                        .id
                                                                        .toString());
                                                                    _userController
                                                                        .userRecordings
                                                                        .refresh();
                                                                  }
                                                                }
                                                              });
                                                            },
                                                            value: choice,
                                                            child: Text(choice),
                                                          );
                                                        }).toList()
                                                      : {
                                                          'Share',
                                                        }.map((String choice) {
                                                          return PopupMenuItem<
                                                              String>(
                                                            onTap: () async {
                                                              await shareRecording(
                                                                  recordModel);
                                                            },
                                                            value: choice,
                                                            child: Text(choice),
                                                          );
                                                        }).toList();
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Stack(
                                            children: recordModel
                                                .roomId!.hostIds!
                                                .map((e) {
                                              var index = recordModel
                                                  .roomId!.hostIds!
                                                  .indexOf(e);
                                              return Padding(
                                                  padding: EdgeInsets.only(
                                                      left: (30.0 * index)),
                                                  child: e.profilePhoto == "" ||
                                                          e.profilePhoto == null
                                                      ? const CircleAvatar(
                                                          radius: 18,
                                                          backgroundImage:
                                                              AssetImage(
                                                                  "assets/icons/profile_placeholder.png"))
                                                      : CircleAvatar(
                                                          radius: 18,
                                                          onBackgroundImageError: (object,
                                                                  stacktrace) =>
                                                              const AssetImage(
                                                                  "assets/icons/profile_placeholder.png"),
                                                          backgroundImage:
                                                              NetworkImage(e
                                                                  .profilePhoto!),
                                                        ));
                                            }).toList(),
                                          ),
                                          Row(
                                            children: [
                                              InkWell(
                                                  onTap: () async {
                                                    DynamicLinkService()
                                                        .generateShareLink(
                                                            recordModel
                                                                .roomId!.id!,
                                                            type: "room",
                                                            title:
                                                                "$join ${recordModel.roomId!.title} $tokShows",
                                                            msg:
                                                                "$products_being_discussed ${recordModel.roomId!.productIds!.map((e) => e.name).toList()}",
                                                            imageurl: recordModel
                                                                .roomId!
                                                                .productIds![0]
                                                                .images![0])
                                                        .then((value) async =>
                                                            await Share.share(
                                                                value));
                                                  },
                                                  child: Image.asset(
                                                    "assets/icons/arrow.png",
                                                    color: Colors.black,
                                                  )),
                                              SizedBox(width: 0.03.sw),
                                              const Icon(
                                                Ionicons.people,
                                                color: Colors.black,
                                                size: 20,
                                              ),
                                              Text(
                                                recordModel
                                                    .roomId!.hostIds!.length
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              SizedBox(width: 0.03.sw),
                                              Text(
                                                recordModel
                                                    .roomId!.userIds!.length
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              SizedBox(width: 0.006.sw),
                                              const Icon(
                                                Ionicons.chatbubble_outline,
                                                color: Colors.black,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 0.01.sh,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              showActualTime(
                                                  recordModel.date.toString()),
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: primarycolor),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                            color: primarycolor,
                          ));
                  },
                ),
                InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    width: MediaQuery.of(Get.context!).size.width * 0.9,
                    child: const Text(
                      see_all_previous_shows,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primarycolor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onTap: () {
                    Get.to(() => PreviousTokshows(
                          userid: _userController.currentProfile.value.id,
                        ));
                  },
                ),
              ],
            ),
    );
  }
}

Widget buildProductRatingWidget(num rating) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "$rating",
        style: TextStyle(
          color: Colors.amber,
          fontWeight: FontWeight.w900,
          fontSize: getProportionateScreenWidth(12),
        ),
      ),
      Icon(
        Icons.star,
        color: Colors.amber,
      ),
    ],
  );
}
