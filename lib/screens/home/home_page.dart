import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:tokshop/controllers/channel_controller.dart';
import 'package:tokshop/controllers/chat_controller.dart';
import 'package:tokshop/controllers/global.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/controllers/shop_controller.dart';
import 'package:tokshop/controllers/wishlist_controller.dart';
import 'package:tokshop/models/shop.dart';
import 'package:tokshop/models/user.dart';
import 'package:tokshop/screens/chats/all_chats_page.dart';
import 'package:tokshop/screens/home/market_place_products.dart';
import 'package:tokshop/screens/profile/user_profile.dart';
import 'package:tokshop/screens/room/all_tokshows.dart';
import 'package:tokshop/screens/room/components/single_tokshow.dart';
import 'package:tokshop/screens/room/upcomingtokshow/new_upcoming_tokshow.dart';
import 'package:tokshop/screens/room/upcomingtokshow/upcoming_tokshows.dart';
import 'package:tokshop/screens/shops/all_shops.dart';
import 'package:tokshop/services/user_api.dart';
import 'package:tokshop/widgets/single_product_item.dart';
import 'package:tokshop/widgets/title.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/room_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/tokshow.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';

//ignore: must_be_immutable
class HomePage extends StatelessWidget {
  AuthController authController = Get.find<AuthController>();

  final UserController userController = Get.put(UserController());
  final ChannelController channelController =
      Get.put<ChannelController>(ChannelController());
  TokShowController roomController = Get.find<TokShowController>();
  final WishListController wishListController = Get.find<WishListController>();
  final ShopController shopController = Get.find<ShopController>();
  final ProductController productController = Get.find<ProductController>();
  ScrollController scrollController = ScrollController(keepScrollOffset: true);

  final ChatController _chatController = Get.find<ChatController>();
  OwnerId currentUser = OwnerId(
      id: Get.find<AuthController>().usermodel.value!.id,
      bio: Get.find<AuthController>().usermodel.value!.bio,
      email: Get.find<AuthController>().usermodel.value!.email,
      firstName: Get.find<AuthController>().usermodel.value!.firstName,
      lastName: Get.find<AuthController>().usermodel.value!.lastName,
      userName: Get.find<AuthController>().usermodel.value!.userName,
      agorauid: Get.find<AuthController>().usermodel.value!.agorauid,
      profilePhoto: Get.find<AuthController>().usermodel.value!.profilePhoto);

  HomePage({Key? key}) : super(key: key);
  Color value = Colors.blueAccent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                text: tok_shop,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                    color: primarycolor),
                children: [
                  TextSpan(
                    text: ".$live",
                    style: TextStyle(
                      color: Styles.red,
                      fontWeight: FontWeight.normal,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Stack(
              clipBehavior: Clip.none,
              children: [
                InkWell(
                  onTap: () {
                    Get.to(AllChatsPage());
                  },
                  child: const Icon(
                    Icons.messenger_outline_outlined,
                    color: primarycolor,
                    size: 20,
                  ),
                ),
                Obx(() {
                  if (_chatController.unReadChats.value > 0) {
                    return Positioned(
                      top: -10,
                      right: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.red,
                        ),
                        child: Text(
                          _chatController.unReadChats.toString(),
                          style:
                              TextStyle(color: Colors.white, fontSize: 10.sp),
                        ),
                      ),
                    );
                  }
                  if (_chatController.unReadChats.value == 0)
                    return Container();
                  return Container();
                })
              ],
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await authController.callInit();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Obx(
            () => ListView(
              children: [
                CustomTitle(
                  linktext: see_All,
                  title: live_tokshows,
                  callBackFunction: () {
                    Get.to(() => AllTokShows(
                        channels: productController.categories.value));
                  },
                ),
                HomepageTokshows(),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    if (roomController.allUpcomingEvents.isNotEmpty) {
                      Get.to(() => UpcomingTokShows());
                    } else {
                      Get.to(() => NewUpcomingTokshow());
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${roomController.allUpcomingEvents.length} Upcoming TokShows",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                            color: primarycolor,
                            borderRadius: BorderRadius.circular(25.0)),
                        child: Text(
                          roomController.allUpcomingEvents.isNotEmpty
                              ? "View shows"
                              : "Add new",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                CustomTitle(
                  linktext: see_All,
                  title: "Popular brands",
                  callBackFunction: () {
                    shopController.getBrands();
                    Get.to(() => AllBrands());
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 230,
                  child: Obx(
                    () => shopController.homeBrandList.isEmpty
                        ? Container()
                        : ScrollSnapList(
                            itemCount: shopController.homeBrandList.length,
                            itemSize: 150,
                            onItemFocus: (index) {},
                            initialIndex: 1,
                            listController: scrollController,
                            endOfListTolerance: 10.0,
                            dynamicItemSize: true,
                            dynamicItemOpacity: 0.7,
                            itemBuilder: (BuildContext context, int index) {
                              Brand brand = shopController.homeBrandList[index];
                              return InkWell(
                                onTap: () {
                                  if (FirebaseAuth.instance.currentUser!.uid ==
                                      brand.ownerId?.id!) {
                                    Get.find<UserController>().getUserProfile(
                                        authController.currentuser!.id!);
                                    Get.find<GlobalController>()
                                        .tabPosition
                                        .value = 3;
                                  } else {
                                    userController
                                        .getUserProfile(brand.ownerId!.id!);
                                    Get.to(UserProfile());
                                  }
                                },
                                child: Container(
                                  height: 80,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      brand.image != null &&
                                              brand.image!.isNotEmpty &&
                                              brand.image!.length > 30
                                          ? ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(15.0),
                                                      topRight: Radius.circular(
                                                          15.0)),
                                              child: CachedNetworkImage(
                                                placeholder: (context, url) =>
                                                    Center(
                                                  child: SizedBox(
                                                      height: 200,
                                                      width: 200,
                                                      child: Image.asset(
                                                          imageplaceholder)),
                                                ),
                                                filterQuality:
                                                    FilterQuality.high,
                                                height: 200,
                                                width: 200,
                                                imageUrl: brand.image!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(15.0),
                                                      topRight: Radius.circular(
                                                          15.0)),
                                              child: Image.asset(
                                                imageplaceholder,
                                                height: 200,
                                                width: 200,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 2),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              flex: 1,
                                              child: Text(
                                                overflow: TextOverflow.fade,
                                                maxLines: 2,
                                                brand.name!,
                                                softWrap: false,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13),
                                              ),
                                            ),
                                            Flexible(
                                              child: InkWell(
                                                onTap: () async {
                                                  if (brand.ownerId!.followers
                                                          .indexWhere((element) =>
                                                              element.id ==
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid) !=
                                                      -1) {
                                                    brand.ownerId!.followers
                                                        .removeWhere((element) =>
                                                            element.id ==
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid);
                                                    shopController.homeBrandList
                                                        .refresh();

                                                    await UserAPI()
                                                        .unFollowAUser(
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid,
                                                            brand.ownerId!.id!);
                                                  } else {
                                                    brand.ownerId!.followers
                                                        .add(UserModel(
                                                            id: FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid));
                                                    shopController.homeBrandList
                                                        .refresh();
                                                    await UserAPI().followAUser(
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                        brand.ownerId!.id!);
                                                  }
                                                },
                                                child: Text(
                                                  brand.ownerId != null &&
                                                          brand.ownerId!
                                                                  .followers
                                                                  .indexWhere((element) =>
                                                                      element
                                                                          .id ==
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid) ==
                                                              -1
                                                      ? "Follow"
                                                      : "Unfollow",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: kPrimaryColor),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                const Divider(),
                if (productController.loadingproducts.isTrue)
                  const Center(
                    child: CircularProgressIndicator(
                      color: primarycolor,
                    ),
                  ),
                if (productController.homeallproducts.isNotEmpty)
                  CustomTitle(
                    linktext: see_All,
                    title: new_collections,
                    callBackFunction: () {
                      productController.selectedChannel.value = null;
                      productController.selectedInterest.value = null;
                      productController.getAllroducts();
                      Get.to(() => MarketPlaceProducts(
                          channels: productController.categories.value));
                    },
                  ),
                Column(
                  children: [
                    GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 2,
                      ),
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: productController.homeallproducts.length,
                      itemBuilder: (context, index) {
                        return SingleproductItem(
                          element: productController.homeallproducts[index],
                          imageHeight: 150,
                          action: true,
                        );
                      },
                    ),
                    if (productController.allProductsCount.value >
                        productController.homeallproducts.length)
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
                          productController.selectedChannel.value = null;
                          productController.selectedInterest.value = null;
                          productController.getAllroducts();
                          Get.to(() => MarketPlaceProducts(
                              channels: productController.categories.value));
                        },
                      ),
                  ],
                ),
                const SizedBox(
                  height: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
