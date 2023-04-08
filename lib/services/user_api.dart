import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tokshop/services/notifications_api.dart';

import '../controllers/auth_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../models/address.dart';
import '../models/user.dart';
import '../utils/utils.dart';
import 'api.dart';
import 'client.dart';
import 'end_points.dart';

class UserAPI {
  getAllUsers(String page, {String title = ""}) async {
    try {
      var users = await DbBase().databaseRequest(
          '$allUsers?page=$page&limit=$limit&title=$title',
          DbBase().getRequestType);
      var decodedUsers = jsonDecode(users);
      return decodedUsers;
    } catch (e, s) {
      printOut("$e $s");
    }
  }

  addUserReview(String id, String review, int rating) async {
    var reviews = await DbBase()
        .databaseRequest(userreviews + id, DbBase().postRequestType, body: {
      "id": FirebaseAuth.instance.currentUser!.uid,
      "rating": rating,
      "review": review,
    });
    return jsonDecode(reviews);
  }

  getUserReviews(String uid) async {
    var reviews = await DbBase()
        .databaseRequest(userreviews + uid, DbBase().getRequestType);
    return jsonDecode(reviews);
  }

  Future checkCanReview(UserModel userModel) async {
    var response = await DbBase().databaseRequest(
        checkcanreview + FirebaseAuth.instance.currentUser!.uid,
        DbBase().postRequestType,
        body: {"id": userModel.shopId?.id});
    if (response == null) {
      return null;
    } else {
      return jsonDecode(response);
    }
  }

  getUserProfile(String uid) async {
    var user =
        await DbBase().databaseRequest(userById + uid, DbBase().getRequestType);

    if (user == null) {
      return null;
    } else {
      return jsonDecode(user);
    }
  }

  getUserFollowers(String uid) async {
    var users = await DbBase()
        .databaseRequest(userFollowers + uid, DbBase().getRequestType);

    if (users == null) {
      return null;
    } else {
      return jsonDecode(users);
    }
  }

  getUserFollowing(String uid) async {
    var users = await DbBase()
        .databaseRequest(userFollowing + uid, DbBase().getRequestType);

    if (users == null) {
      return null;
    } else {
      return jsonDecode(users);
    }
  }

  getOrderById(String orderId) async {
    var order = await DbBase()
        .databaseRequest(oneOrder + orderId, DbBase().getRequestType);
    return jsonDecode(order);
  }

  getUserOrders(String uid) async {
    var orders = await DbBase()
        .databaseRequest(userOrders + uid, DbBase().getRequestType);

    return jsonDecode(orders);
  }

  getUserBalances() async {
    var orders = await DbBase().databaseRequest(
        "$stripeBalance/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().getRequestType);

    return jsonDecode(orders);
  }

  getOrders(String filterparams) async {
    var orders = await DbBase()
        .databaseRequest("$allorders?$filterparams", DbBase().getRequestType);
    return jsonDecode(orders);
  }

  Future blockUser(String toblock, String id) async {
    try {
      var updated = await DbBase()
          .databaseRequest("$block$id/$toblock", DbBase().patchRequestType);

      return jsonDecode(updated);
    } catch (e, s) {
      printOut("Error updating user $e $s");
    }
  }

  Future unblockUser(String toblock, String id) async {
    try {
      var updated = await DbBase()
          .databaseRequest("$unblock$id/$toblock", DbBase().patchRequestType);
      return jsonDecode(updated);
    } catch (e, s) {
      printOut("Error updating user $e $s");
    }
  }

  Future updateUser(Map<String, dynamic> body, String id) async {
    try {
      var updated = await DbBase().databaseRequest(
          editUser + id, DbBase().patchRequestType,
          body: body);

      return jsonDecode(updated)["user"];
    } catch (e, s) {
      printOut("Error updating user $e $s");
    }
  }

  Future updateUserInterests(List<String> body, String id) async {
    try {
      var updated = await DbBase().databaseRequest(
          '${updateinterests}/$id', DbBase().patchRequestType,
          body: {"interests": body});

      return jsonDecode(updated);
    } catch (e, s) {
      printOut("Error updating user $e $s");
    }
  }

  Future savePayoutMethod(Map<String, dynamic> body, String id) async {
    try {
      var updated = await DbBase().databaseRequest(
          payoutmethods + id, DbBase().postRequestType,
          body: body);

      return jsonDecode(updated);
    } catch (e, s) {
      printOut("Error updating user $e $s");
    }
  }

  Future getPayoutMethodByUserId(String id) async {
    try {
      var updated = await DbBase()
          .databaseRequest(payoutmethods + id, DbBase().getRequestType);

      return jsonDecode(updated);
    } catch (e, s) {
      printOut("Error updating user $e $s");
    }
  }

  Future createStripeCardToken(Map<String, dynamic> body, String id) async {
    try {
      var updated = await DbBase().databaseRequest(
          paymentmethods + id, DbBase().postRequestType,
          body: body);

      return jsonDecode(updated);
    } catch (e, s) {
      printOut("Error updating user $e $s");
    }
  }

  followAUser(String myId, String toFollowId) async {
    try {
      var updated = await DbBase().databaseRequest(
          "$followUser$myId/$toFollowId", DbBase().patchRequestType);

      await NotificationsAPI().sendNotification(
          [toFollowId],
          "New follower",
          "${Get.find<AuthController>().usermodel.value!.firstName} started following you",
          "ProfileScreen",
          myId);
    } catch (e, s) {
      printOut("Error following user $e $s");
    }
  }

  unFollowAUser(String myId, String toUnFollowId) async {
    try {
      await DbBase().databaseRequest(
          "$unFollowUser$myId/$toUnFollowId", DbBase().patchRequestType);
    } catch (e, s) {
      printOut("Error following user $e $s");
    }
  }

  static socialAuthentication(data) async {
    print(data);
    var response = await DbBase().databaseRequest(
        authenticationsocial, DbBase().postRequestType,
        body: data);
    return jsonDecode(response);
  }

  static Future getUserById() async {
    try {
      var response = await DbBase().databaseRequest(
          "$user/${FirebaseAuth.instance.currentUser!.uid}",
          DbBase().getRequestType);
      if (response != null) {
        UserModel userModel = UserModel.fromJson(jsonDecode(response));

        Get.find<AuthController>().usermodel.value = userModel;

        Get.find<AuthController>().usermodel.refresh();

        PackageInfo.fromPlatform().then((value) {
          PackageInfo packageInfo = value;
          String code = packageInfo.buildNumber;
          UserAPI().updateUser(
              {"appVersion": code}, FirebaseAuth.instance.currentUser!.uid);
        });

        return userModel;
      } else {
        return response;
      }
    } catch (e) {
      print("get user error $e");
      Get.find<AuthController>().signOut();
    }
  }

  static Future<List<Address>> getAddressesFromUserId() async {
    List<dynamic> response = await Api.callApi(
        method: DbBase().getRequestType,
        endpoint: addressForUser + FirebaseAuth.instance.currentUser!.uid);
    return response.map((e) => Address.fromJson(e)).toList();
  }

  static Future addAddressForCurrentUser(Address newAddress) async {
    var response = await DbBase().databaseRequest(
        address, DbBase().postRequestType,
        body: newAddress.toJson());
    return jsonDecode(response);
  }

  String getPathForCurrentUserDisplayPicture() {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    return "user/display_picture/$currentUserUid";
  }

  static updateAddressForCurrentUser(Address newAddress, String id) async {
    var response = await Api.callApi(
        method: DbBase().patchRequestType,
        endpoint: address + id,
        body: newAddress.toJson());
    return response;
  }

  static uploadDisplayPictureForCurrentUser(String downloadUrl) async {
    await DbBase().databaseRequest(
        "$user/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().patchRequestType,
        body: {"profilePhoto": downloadUrl});

    return true;
  }

  static getMyFavorites() async {
    var response = await DbBase().databaseRequest(
      favorite + FirebaseAuth.instance.currentUser!.uid,
      DbBase().getRequestType,
    );
    return jsonDecode(response);
  }

  static getUserSummary(String shopid) async {
    var response = await DbBase().databaseRequest(
      usersummary + shopid,
      DbBase().getRequestType,
    );
    return jsonDecode(response);
  }

  static saveFovite(String productId) async {
    var response = await DbBase().databaseRequest(
        favorite + FirebaseAuth.instance.currentUser!.uid,
        DbBase().postRequestType,
        body: {
          "productId": [productId]
        });
    return jsonDecode(response);
  }

  static deleteFromFavorite(String productId) async {
    var response = await DbBase().databaseRequest(
        favorite + Get.find<WishListController>().favoritekey.value,
        DbBase().deleteRequestType,
        body: {"productId": productId});
    return jsonDecode(response);
  }

  static friendsToInvite() async {
    var response = await DbBase().databaseRequest(
        followersfollowing + FirebaseAuth.instance.currentUser!.uid,
        DbBase().getRequestType);
    return jsonDecode(response);
  }

  static searchFriends(String searchText) async {
    var response = await DbBase().databaseRequest(
        "$followersfollowingsearch${FirebaseAuth.instance.currentUser!.uid}/$searchText",
        DbBase().getRequestType);
    return jsonDecode(response);
  }

  static getConnectedStripeBanks() async {
    var response = await DbBase().databaseRequest(
      "$stripeAccounts/${FirebaseAuth.instance.currentUser!.uid}",
      DbBase().getRequestType,
    );
    return jsonDecode(response)["banks"];
  }

  static getUserCheckByEmail(String email) async {
    var response = await DbBase().databaseRequest(
        userExists, DbBase().getRequestType,
        body: {"email": email});
    return jsonDecode(response);
  }

  static getSettings() async {
    var response =
        await DbBase().databaseRequest(settings, DbBase().getRequestType);
    return jsonDecode(response);
  }

  static Future deleteStripeBankAccount() async {
    var response = await DbBase().databaseRequest(
        "$stripeAccountsDelete/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().deleteRequestType,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': "Bearer $stripeSecretKey"
        });
    return jsonDecode(response);
  }
}
