import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tokshop/models/address.dart';
import 'package:tokshop/models/interests.dart';
import 'package:tokshop/models/payment_method.dart';
import 'package:tokshop/models/payout_method.dart';

import 'channel.dart';
import 'shop.dart';

class UserModel {
  List<UserModel> followers = [];
  List<String> blocked = [];
  List<UserModel> following = [];
  Address? address;
  List<Interests> interests = [];
  List<Channel>? channels = [];
  double? wallet;
  double? pendingWallet;
  String? logintype;
  String? roomuid;
  String? recordingUid;
  String? currentRoom;
  String? facebook;
  String? instagram;
  int? agorauid;
  String? linkedIn;
  String? twitter;
  String? fwAccount;
  String? id;
  PayoutMethod? payoutMethod;
  UserPaymentMethod? defaultpaymentmethod;
  String? firstName;
  String? lastName;
  String? bio;
  String? userName;
  String? email;
  String? fwId;
  String? phonenumber;
  int? followersCount;
  int? followingCount;
  String? profilePhoto;
  Brand? shopId;
  int? memberShip;
  int? upgradedDate;
  bool? receivemessages;
  bool? renewUpgrade;
  bool? muted;
  String? accessToken;
  int? tokshows;
  String? authtoken;
  String? mpesaNumber;
  bool? accountDisabled;

  UserModel({
    this.address,
    this.defaultpaymentmethod,
    this.recordingUid,
    this.followersCount,
    this.followingCount,
    this.blocked = const [],
    this.followers = const [],
    this.following = const [],
    this.interests = const [],
    this.wallet,
    this.fwId,
    this.logintype,
    this.pendingWallet,
    this.currentRoom,
    this.mpesaNumber,
    this.facebook,
    this.payoutMethod,
    this.fwAccount,
    this.agorauid,
    this.instagram,
    this.linkedIn,
    this.twitter,
    this.id,
    this.firstName,
    this.lastName,
    this.bio,
    this.userName,
    this.email,
    this.accessToken,
    this.authtoken,
    this.channels,
    this.receivemessages,
    this.phonenumber,
    this.shopId,
    this.profilePhoto,
    this.tokshows,
    this.memberShip,
    this.upgradedDate,
    this.renewUpgrade,
    this.muted,
    this.accountDisabled,
  });

  UserModel.fromPlayer(this.id, this.firstName, this.lastName, this.bio,
      this.userName, this.phonenumber, this.profilePhoto);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      followers: json["followers"] == null
          ? []
          : List<UserModel>.from(json["followers"].map((x) =>
              x.toString().length > 40
                  ? UserModel.fromJson(x)
                  : UserModel(id: x))),
      blocked: json["blocked"] == null
          ? []
          : List<String>.from(json["blocked"].map((x) => x)),
      following: json["following"] == null
          ? []
          : List<UserModel>.from(json["following"].map((x) =>
              x.toString().length > 40
                  ? UserModel.fromJson(x)
                  : UserModel(id: x))),
      interests: json["interests"] == null
          ? []
          : List<Interests>.from(json["interests"].map((x) =>
              x.toString().length < 40
                  ? Interests(id: x)
                  : Interests.fromJson(x))),
      channels: json["channels"] == null
          ? []
          : List<Channel>.from(json["channels"].map((x) =>
              x.toString().length < 40 ? Channel(id: x) : Channel.fromJson(x))),
      wallet: 0.0,
      defaultpaymentmethod: json["defaultpaymentmethod"] != null &&
              json["defaultpaymentmethod"].toString().length > 40
          ? UserPaymentMethod.toJson(json["defaultpaymentmethod"])
          : null,
      receivemessages: json["receivemessages"] ?? false,
      fwAccount: json["fw_subacoount"] ?? "",
      fwId: json["fw_id"] ?? "",
      address: json["address"] == null || json["address"].toString().length < 40
          ? null
          : Address.fromJson(json["address"]),
      mpesaNumber: json["mpesaNumber"] ?? "",
      payoutMethod: json["payoutmethod"] != null &&
              json["payoutmethod"].toString().length > 40
          ? PayoutMethod.toJson(json["payoutmethod"])
          : null,
      pendingWallet: 0.0,
      logintype: json["logintype"] ?? "emailpassword",
      tokshows: json["tokshows"] ?? 0,
      agorauid: json["agorauid"] ?? 0,
      currentRoom: json["currentRoom"] ?? "",
      recordingUid: (Random().nextInt(900000) + 100000).toString(),
      facebook: json["facebook"],
      instagram: json["instagram"],
      linkedIn: json["linkedIn"],
      twitter: json["twitter"],
      id: json["_id"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      bio: json["bio"],
      userName: json["userName"],
      email: json["email"],
      shopId: json["shopId"] != null && json["shopId"] != ""
          ? json["shopId"].toString().length > 40
              ? Brand.fromJson(json["shopId"])
              : Brand(id: json["shopId"])
          : null,
      phonenumber: json["phonenumber"],
      profilePhoto: json["profilePhoto"],
      memberShip: json["memberShip"],
      upgradedDate: json["upgradedDate"],
      followersCount: json["followersCount"],
      followingCount: json["followingCount"],
      renewUpgrade: json["renewUpgrade"] ?? true,
      muted: json["muted"] ?? true,
      authtoken: json["authtoken"] ?? "",
      accessToken: json["accessToken"] ?? "",
      accountDisabled: json["accountDisabled"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "followingCount": followingCount,
        "followersCount": followersCount,
        "wallet": wallet,
        "currentRoom": currentRoom,
        "facebook": facebook,
        "instagram": instagram,
        "linkedIn": linkedIn,
        "twitter": twitter,
        "_id": id,
        "roomuid": roomuid,
        "firstName": firstName,
        "lastName": lastName,
        "bio": bio,
        "shopId": shopId!.toJson(),
        "userName": userName,
        "email": email,
        "phonenumber": phonenumber,
        "profilePhoto": profilePhoto,
        "memberShip": memberShip,
        "upgradedDate": upgradedDate,
        "renewUpgrade": renewUpgrade,
        "muted": muted ?? true,
        "accountDisabled": accountDisabled,
      };

  getCurrentShop() => shopId;
}

class ShopId {
  ShopId({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.location,
    required this.image,
    required this.description,
  });

  String id;
  String name;
  String email;
  String phoneNumber;
  String location;
  String image;
  String description;

  factory ShopId.fromJson(Map<String, dynamic> json) => ShopId(
        id: json["_id"],
        name: json["name"] ?? "",
        email: json["email"] ?? "",
        phoneNumber: json["phoneNumber"] ?? "",
        location: json["location"] ?? "",
        image: json["image"] ?? "",
        description: json["description"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "location": location,
        "email": email,
        "phoneNumber": phoneNumber,
        "image": image,
        "description": description,
      };
}
