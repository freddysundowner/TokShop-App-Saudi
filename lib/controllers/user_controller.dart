import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/controllers/wishlist_controller.dart';
import 'package:tokshop/models/UserReview.dart';
import 'package:tokshop/models/address.dart';
import 'package:tokshop/models/order.dart';
import 'package:tokshop/screens/home/create_room.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user.dart';
import '../services/recordings_api.dart';
import '../services/user_api.dart';
import '../utils/utils.dart';
import 'auth_controller.dart';
import 'product_controller.dart';

enum SingingCharacter { bank, paypal, mobile }

class UserController extends GetxController with GetTickerProviderStateMixin {
  var currentProfile = UserModel().obs;
  var profileLoading = false.obs;
  var updateInterests = false.obs;
  var ordersLoading = false.obs;
  var loadingReview = false.obs;
  RxList userOrders = RxList([]);
  RxList shopOrders = RxList([]);
  var userFollowersFollowing = [].obs;
  var gettingFollowers = false.obs;
  var gettingAddress = false.obs;
  RxList<Address> myAddresses = RxList([]);
  var userOrdersPageNumber = 1.obs;
  var loadingMoreUserOrders = false.obs;
  final userOrdersScrollController = ScrollController();
  var shopOrdersPageNumber = 1.obs;
  var loadingMoreShopOrders = false.obs;
  final shopOrdersScrollController = ScrollController();
  var userRecordings = [].obs;
  Rxn usersummary = Rxn(null);
  var userRecordingsLoading = false.obs;
  var userFollowingIndex = 0.obs;
  var userBeingFollowingId = "".obs;
  Rxn<List<UserReview>> curentUserReview = Rxn([]);
  Rxn<SingingCharacter> payOutOptions = Rxn(SingingCharacter.bank);
  var page = 1.obs;
  var limit = 15.obs;
  var tabIndex = 0.obs;
  var totalUsers = 0.obs;
  var ratingvalue = 0.obs;
  var ratingError = "".obs;
  TextEditingController review = TextEditingController();

  var moreUsersLoading = false.obs;
  var allUsers = [].obs;
  var friendsToInvite = [].obs;
  var searchedfriendsToInvite = [].obs;
  var searchedUsers = [].obs;
  var canreview = false.obs;
  var allUsersLoading = false.obs;
  TextEditingController searchUsersController = TextEditingController();
  final usersScrollController = ScrollController();
  Rxn<TabController> tabController = Rxn(null);

  @override
  void onInit() {
    super.onInit();

    tabController.value = TabController(
      initialIndex: tabIndex.value,
      length: 2,
      vsync: this,
    );
    orderScrollControllerListener();
    scrollControllerListener();
  }

  void scrollControllerListener() {
    usersScrollController.addListener(() {
      if (usersScrollController.position.atEdge) {
        bool isTop = usersScrollController.position.pixels == 0;
        printOut(
            'current position controller ${usersScrollController.position.pixels}');
        if (isTop) {
          printOut('At the top');
        } else {
          printOut('At the bottom');
          page.value += 1;
          loadMoreUsers();
        }
      }
    });
  }

  searchUser() async {
    try {
      allUsersLoading.value = true;
      searchedUsers.clear();
      var response = await UserAPI().getAllUsers("1",
          title: searchUsersController.text.trim().toString());
      for (var i = 0; i < response["users"].length; i++) {
        if (response["users"][i]['_id'] !=
            FirebaseAuth.instance.currentUser!.uid) {
          searchedUsers.add(response["users"][i]);
        }
      }
      searchedUsers.refresh();
      allUsersLoading.value = false;
    } finally {
      allUsersLoading.value = false;
    }
  }

  checkCanReview(UserModel userModel) async {
    canreview.value = false;

    if (userModel.id != FirebaseAuth.instance.currentUser!.uid) {
      var response = await UserAPI().checkCanReview(userModel);
      canreview.value = response["canreview"] == true &&
          (curentUserReview.value?.indexWhere((e) =>
                      e.from!.id == FirebaseAuth.instance.currentUser!.uid) ==
                  -1 ||
              curentUserReview.value == null);
    }
  }

  searchUsersWeAreFriends(String text) async {
    if (searchUsersController.text.trim().isNotEmpty) {
      try {
        allUsersLoading.value = true;
        var results = await UserAPI.searchFriends(text);
        searchedfriendsToInvite.assignAll(results);
        allUsersLoading.value = false;
      } catch (e) {
        printOut(e.toString());
        allUsersLoading.value = false;
      }
    }
  }

  Future<void> friendsToInviteCall() async {
    try {
      allUsersLoading.value = true;

      var users = await UserAPI.friendsToInvite();
      var list = [];

      if (users != null) {
        for (var i = 0; i < users.length; i++) {
          if (users.elementAt(i)["_id"] !=
              FirebaseAuth.instance.currentUser!.uid) {
            list.add(users.elementAt(i));
          }
        }
        friendsToInvite.value = list;
      } else {
        friendsToInvite.value = [];
      }
      searchedfriendsToInvite.value = friendsToInvite;

      friendsToInvite.refresh();
      allUsersLoading.value = false;
    } catch (e) {
      printOut(e);
      allUsersLoading.value = false;
    }
  }

  Future<void> loadMoreUsers() async {
    try {
      moreUsersLoading.value = true;
      var response = await UserAPI().getAllUsers(page.value.toString());
      List users = response["users"];
      if (users.isNotEmpty) {
        allUsers.addAll(users);
        searchedUsers.addAll(users);
        allUsers.refresh();
        moreUsersLoading.value = false;
      } else {
        moreUsersLoading.value = false;
        searchedUsers = allUsers;
      }
    } finally {
      moreUsersLoading.value = false;
    }
  }

  void orderScrollControllerListener() {
    userOrdersScrollController.addListener(() {
      if (userOrdersScrollController.position.atEdge) {
        bool isTop = userOrdersScrollController.position.pixels == 0;
        if (isTop) {
          printOut('At the top');
        } else {
          userOrdersPageNumber.value = userOrdersPageNumber.value + 1;
          getMoreUserOrders();
        }
      }
    });

    shopOrdersScrollController.addListener(() {
      if (shopOrdersScrollController.position.atEdge) {
        bool isTop = shopOrdersScrollController.position.pixels == 0;
        if (isTop) {
          printOut('At the top');
        } else {
          shopOrdersPageNumber.value = shopOrdersPageNumber.value + 1;
          getMoreShopOrders();
        }
      }
    });
  }

  getUserProfile(String userId) async {
    try {
      profileLoading.value = true;
      var user = await UserAPI().getUserProfile(userId);
      if (user == null) {
        currentProfile.value = UserModel();
      } else {
        UserModel userFromAPi = UserModel.fromJson(user);
        userFromAPi.followers
            .removeWhere((element) => element.accountDisabled == true);
        userFromAPi.following
            .removeWhere((element) => element.accountDisabled == true);
        currentProfile.value = userFromAPi;

        Get.find<TokShowController>()
            .getActiveTokshows(limit: "3", userid: userId);
        curentUserReview.value = [];
        productController.profileproducts.clear();
        if (currentProfile.value.shopId != null) {
          getUserReviews(userId);
          getUserSummary(currentProfile.value.shopId!.id!);
          productController.selectedInterest.value = null;
          productController.selectedChannel.value = null;
          productController.getAllroducts(
              userid: currentProfile.value.id!, type: "profile", limit: "4");
        }
        Get.find<TokShowController>().fetchMyEvents(userId);
        Get.find<WishListController>().getFavoriteProducts();
      }
      profileLoading.value = false;
    } catch (e) {
      profileLoading.value = false;
    }
  }

  Future<void> followUser(UserModel profile) async {
    currentProfile.value.followers
        .add(UserModel(id: FirebaseAuth.instance.currentUser!.uid));
    currentProfile.value.followersCount =
        currentProfile.value.followersCount == null
            ? 0
            : currentProfile.value.followersCount! + 1;

    if (currentProfile.value.id == FirebaseAuth.instance.currentUser!.uid) {
      currentProfile.value.followingCount =
          currentProfile.value.followingCount == null
              ? 0
              : currentProfile.value.followingCount! + 1;
    }
    currentProfile.refresh();

    await UserAPI()
        .followAUser(FirebaseAuth.instance.currentUser!.uid, profile.id!);
  }

  Future<void> updateUserInterests(List<String> interests) async {
    updateInterests.value = true;
    await UserAPI()
        .updateUserInterests(interests, FirebaseAuth.instance.currentUser!.uid);
    updateInterests.value = false;
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    updateInterests.value = true;
    var response = await UserAPI()
        .updateUser(data, FirebaseAuth.instance.currentUser!.uid);
    Get.find<AuthController>().usermodel.value = UserModel.fromJson(response);
    Get.find<AuthController>().usermodel.refresh();
    updateInterests.value = false;
  }

  Future<void> unFollowUser(UserModel profile) async {
    currentProfile.value.followers
        .removeWhere((e) => e.id == FirebaseAuth.instance.currentUser!.uid);

    currentProfile.value.followersCount =
        currentProfile.value.followersCount == null
            ? 0
            : currentProfile.value.followersCount! - 1;

    if (currentProfile.value.id == FirebaseAuth.instance.currentUser!.uid) {
      currentProfile.value.followingCount =
          currentProfile.value.followingCount == null
              ? 0
              : currentProfile.value.followingCount! - 1;
    }

    currentProfile.refresh();

    await UserAPI()
        .unFollowAUser(FirebaseAuth.instance.currentUser!.uid, profile.id!);

    if (homeController.roomHosts
            .indexWhere((element) => element.id == profile.id) !=
        -1) {
      homeController
          .roomHosts[homeController.roomHosts
              .indexWhere((element) => element.id == profile.id)]
          .followersCount = homeController
              .roomHosts[homeController.roomHosts
                  .indexWhere((element) => element.id == profile.id)]
              .followersCount! -
          1;
    }
  }

  getUserOrders() async {
    try {
      ordersLoading.value = true;
      List response =
          await UserAPI().getUserOrders(FirebaseAuth.instance.currentUser!.uid);

      userOrders.value = response.map((e) => Order.fromJson(e)).toList();

      ordersLoading.value = false;
    } catch (e, s) {
      ordersLoading.value = false;
      printOut("Error getting user orders $e $s");
    }
  }

  getMoreUserOrders() async {
    try {
      loadingMoreUserOrders.value = true;
      var orders = await UserAPI()
          .getOrders("userid=${FirebaseAuth.instance.currentUser!.uid}");
      printOut(orders);

      if (orders != null) {
        userOrders.addAll(orders.map((e) => Order.fromJson(e)).toList());
      }

      loadingMoreUserOrders.value = false;
    } catch (e, s) {
      loadingMoreUserOrders.value = false;
      printOut("Error getting user orders $e $s");
    }
  }

  getOrders([String? filterparams]) async {
    try {
      ordersLoading.value = true;
      var response = await UserAPI().getOrders(filterparams!);

      shopOrders.value =
          response["orders"].map((e) => Order.fromJson(e)).toList();

      ordersLoading.value = false;
    } catch (e, s) {
      ordersLoading.value = false;
      printOut("Error getting user orders $e $s");
    }
  }

  getMoreShopOrders() async {
    try {
      loadingMoreShopOrders.value = true;
      var orders = await UserAPI().getOrders(
          "shopId=${Get.find<AuthController>().usermodel.value!.shopId!.id!}");

      if (orders != null) {
        shopOrders.addAll(orders);
      }

      loadingMoreShopOrders.value = false;
    } catch (e, s) {
      loadingMoreShopOrders.value = false;
    }
  }

  gettingMyAddrresses() async {
    try {
      gettingAddress.value = true;
      var address = await UserAPI.getAddressesFromUserId();

      if (address.isEmpty) {
        myAddresses.value = [];
      } else {
        myAddresses.value = address;
      }

      gettingAddress.value = false;
    } catch (e, s) {
      gettingAddress.value = false;
    }
  }

  getUserFollowers(String uid) async {
    try {
      gettingFollowers.value = true;

      userFollowersFollowing.value = [];

      var users = await UserAPI().getUserFollowers(uid);

      if (users == null) {
        userFollowersFollowing.value = [];
      } else {
        userFollowersFollowing.value = users;
      }

      gettingFollowers.value = false;
    } catch (e, s) {
      gettingFollowers.value = false;
    }
  }

  getUserFollowing(String uid) async {
    try {
      gettingFollowers.value = true;

      userFollowersFollowing.value = [];

      var users = await UserAPI().getUserFollowing(uid);

      if (users == null) {
        userFollowersFollowing.value = [];
      } else {
        userFollowersFollowing.value = users;
      }

      gettingFollowers.value = false;
    } catch (e, s) {
      gettingFollowers.value = false;
    }
  }

  getUserRecordings(String id, {String limit = "15"}) async {
    try {
      userRecordingsLoading.value = true;
      var recordings =
          await RecordingsAPI().getUserRecordings(id, limit: limit);
      print("recordings $recordings");

      if (recordings == null) {
        userRecordings.value = [];
      } else {
        userRecordings.value = recordings["recordings"];
      }

      userRecordingsLoading.value = false;
    } catch (e, s) {
      userRecordingsLoading.value = false;
    }
  }

  void getUserSummary(String shopid) async {
    var response = await UserAPI.getUserSummary(shopid);
    usersummary.value = response;
    usersummary.refresh();
  }

  addUserReview(String userId, String review, int rating) async {
    loadingReview.value = true;
    var response = await UserAPI().addUserReview(userId, review, rating);
    // canreview.value = false;
    getUserReviews(userId);
    loadingReview.value = false;
  }

  getUserReviews(String userId) async {
    loadingReview.value = true;
    var response = await UserAPI().getUserReviews(userId);
    if (response["data"].length > 0) {
      List results = response["data"];
      curentUserReview.value =
          results.map((e) => UserReview.fromMap(e)).toList();
    } else {
      curentUserReview.value = null;
    }
    checkCanReview(currentProfile.value);
    curentUserReview.refresh();
    loadingReview.value = false;
  }
}
