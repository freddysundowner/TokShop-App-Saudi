import 'package:tokshop/models/auction.dart';
import 'package:tokshop/models/channel.dart';

import 'product.dart';
import 'shop.dart';

class Tokshow {
  Tokshow({
    this.activeauction,
    this.pinned,
    this.productIds,
    this.hostIds,
    this.userIds,
    this.raisedHands,
    this.eventDate,
    this.speakerIds,
    this.invitedIds,
    this.status,
    this.event,
    this.id,
    this.ownerId,
    this.title,
    this.shopId,
    this.token,
    this.roomType,
    this.speakersSentNotifications,
    this.invitedhostIds,
    this.recordingIds,
    this.activeTime,
    this.resourceId,
    this.recordingsid,
    this.description,
    this.streamOptions,
    this.recordingUid,
    this.toBeNotified,
    this.ended,
    this.recordedRoom,
    this.channel,
    this.allowchat,
    this.allowrecording,
    this.invitedSpeakerIds,
  });

  double? discount = 0.0;
  List<Product>? productIds;
  Auction? activeauction;
  Product? pinned;
  List<OwnerId>? hostIds = [];
  List<String>? invitedhostIds = [];
  List<OwnerId>? userIds = [];
  List<OwnerId>? raisedHands = [];
  List<OwnerId>? speakerIds = [];
  List<OwnerId>? invitedSpeakerIds = [];
  List<OwnerId>? invitedIds = [];
  List<String>? toBeNotified = [];
  bool? event;
  bool? status;
  String? id;
  int? activeTime;
  OwnerId? ownerId;
  Brand? shop;
  List<Channel>? channel;
  String? title = "";
  int? eventDate = 0;
  String? recordingUid = "";
  String? resourceId = "";
  List<String>? recordingIds = [];
  List<String>? speakersSentNotifications = [];
  String? description = "";
  String? recordingsid = "";
  List<dynamic>? streamOptions = [];
  Brand? shopId;
  List<dynamic>? productPrice;
  String? roomType;
  dynamic token;
  bool? ended;
  bool? recordedRoom;
  bool? allowrecording;
  bool? allowchat;

  factory Tokshow.fromJson(Map<String, dynamic> json) {
    if (json["ownerId"] != null && json["ownerId"].toString().length > 40) {
      json["ownerId"]["joinedclubs"] = [];
    }

    return Tokshow(
      hostIds: json["hostIds"] == null
          ? []
          : List<OwnerId>.from(json["hostIds"].map((x) =>
              x.toString().length > 40 ? OwnerId.fromJson(x) : OwnerId(id: x))),
      userIds: json["userIds"] == null
          ? []
          : List<OwnerId>.from(json["userIds"].map((x) =>
              x.toString().length > 50 ? OwnerId.fromJson(x) : OwnerId(id: x))),
      raisedHands: json["raisedHands"] == null
          ? []
          : List<OwnerId>.from(json["raisedHands"].map((x) =>
              x.toString().length > 40 ? OwnerId.fromJson(x) : OwnerId(id: x))),
      speakerIds: json["speakerIds"] == null
          ? []
          : List<OwnerId>.from(json["speakerIds"].map((x) =>
              x.toString().length > 40 ? OwnerId.fromJson(x) : OwnerId(id: x))),
      invitedSpeakerIds: json["invitedSpeakerIds"] == null
          ? []
          : List<OwnerId>.from(json["invitedSpeakerIds"].map((x) =>
              x.toString().length > 40 ? OwnerId.fromJson(x) : OwnerId(id: x))),
      invitedIds: json["invitedIds"] == null
          ? []
          : List<OwnerId>.from(json["invitedIds"].map((x) =>
              x.toString().length > 40 ? OwnerId.fromJson(x) : OwnerId(id: x))),
      status: json["status"],
      id: json["_id"] ?? "",
      ownerId: json["ownerId"] == null
          ? null
          : json["ownerId"].toString().length > 40
              ? OwnerId.fromJson(json["ownerId"])
              : OwnerId(id: json["ownerId"]),
      title: json["title"] ?? "",
      shopId: json["shopId"] == null || json["ownerId"].toString().length < 40
          ? null
          : Brand.fromJson(json["shopId"]),
      invitedhostIds: json["invitedhostIds"] == null
          ? []
          : List<String>.from(json["invitedhostIds"].map((x) => x)),
      recordingIds: json["recordingIds"] == null ||
              json["recordingIds"].toString().length > 30
          ? []
          : List<String>.from(json["recordingIds"].map((x) => x)),
      speakersSentNotifications: json["speakersSentNotifications"] == null
          ? []
          : List<String>.from(json["speakersSentNotifications"].map((x) => x)),
      toBeNotified: json["toBeNotified"] == null
          ? []
          : List<String>.from(json["toBeNotified"].map((x) => x)),
      token: json["token"],
      recordingsid: json["recordingsid"] ?? "",
      description: json["description"] ?? "",
      recordingUid: json["recordingUid"] ?? "",
      streamOptions: json["streamOptions"] ?? [],
      resourceId: json["resourceId"] ?? "",
      eventDate: json["eventDate"] ?? 0,
      activeTime: json["activeTime"] ?? DateTime.now().millisecondsSinceEpoch,
      roomType: json["roomType"],
      event: json["event"],
      productIds: json["productIds"] == null
          ? []
          : List<Product>.from(json["productIds"].map((x) =>
              x.toString().length > 40 ? Product.fromJson(x) : Product(id: x))),
      activeauction: json["activeauction"] == null ||
              json["activeauction"].toString().length < 40
          ? null
          : Auction.fromJson(json["activeauction"]),
      pinned: json["pin"] == null ? null : Product.fromJson(json["pin"]),
      ended: json["ended"] ?? false,
      channel: json["channel"] == null
          ? []
          : List<Channel>.from(json["channel"].map((x) =>
              x.toString().length > 40 ? Channel.fromJson(x) : Channel(id: x))),
      recordedRoom: json["recordedRoom"] ?? false,
      allowchat: json["allowchat"] ?? true,
      allowrecording: json["allowrecording"] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        "productIds": productIds == []
            ? []
            : List<dynamic>.from(productIds!.map((x) => x.toJson())),
        "hostIds": hostIds == null
            ? []
            : List<dynamic>.from(hostIds!.map((x) => x.toJson())),
        "userIds": userIds == null
            ? []
            : List<dynamic>.from(userIds!.map((x) => x.toJson())),
        "raisedHands": raisedHands == []
            ? []
            : List<dynamic>.from(raisedHands!.map((x) => x.toJson())),
        "speakerIds": speakerIds == []
            ? []
            : List<dynamic>.from(speakerIds!.map((x) => x)),
        "invitedIds": invitedIds == []
            ? []
            : List<dynamic>.from(invitedIds!.map((x) => x)),
        "status": status,
        "toBeNotified": toBeNotified == []
            ? []
            : List<dynamic>.from(toBeNotified!.map((x) => x)),
        "_id": id,
        "ownerId": ownerId == null ? null : ownerId!.toJson(),
        "title": title,
        "shopId": shopId == null ? null : shopId!.toJson(),
        "productPrice": productPrice,
        "token": token,
        "roomType": roomType,
        "recordingsid": recordingsid,
        "recordingUid": recordingUid,
        "eventDate": eventDate,
        "resourceId": resourceId,
        "event": event,
        "allowrecording": allowrecording ?? true,
        "allowchat": allowchat ?? true,
      };
}

class OwnerId {
  OwnerId(
      {this.followers,
      this.following,
      this.wallet,
      this.currentRoom,
      this.facebook,
      this.instagram,
      this.linkedIn,
      this.twitter,
      this.id,
      this.firstName,
      this.lastName,
      this.bio,
      this.userName,
      this.email,
      this.password,
      this.phonenumber,
      this.createdAt,
      this.shopId,
      this.updatedAt,
      this.profilePhoto,
      this.memberShip,
      this.upgradedDate,
      this.followersCount,
      this.followingCount,
      this.agorauid,
      this.muted});

  List<String>? followers = [];
  List<String>? following = [];
  int? followersCount;
  int? followingCount;
  double? wallet;
  String? currentRoom;
  int? agorauid;
  String? facebook;
  String? instagram;
  String? linkedIn;
  String? twitter;
  String? id;
  String? firstName;
  String? lastName;
  String? bio;
  String? userName;
  String? email;
  String? password;
  String? phonenumber;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? profilePhoto;
  String? shopId;
  int? memberShip;
  int? upgradedDate;
  bool? muted;
  String? userTypeInRoom;

  factory OwnerId.fromJson(Map<String, dynamic> json) => OwnerId(
        followers: json["followers"] != null
            ? List<String>.from(json["followers"].map((x) => x))
            : [],
        following: json["following"] != null
            ? List<String>.from(json["following"].map((x) => x))
            : [],
        wallet: json["wallet"] == null
            ? 0.0
            : isInteger(json["wallet"]) == true
                ? json["wallet"].toDouble()
                : json["wallet"],
        currentRoom: json["currentRoom"] ?? "",
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
        password: json["password"],
        shopId: json["shopId"].toString().length > 40
            ? Brand.fromJson(json["shopId"]).id
            : json["shopId"],
        phonenumber: json["phonenumber"],
        profilePhoto: json["profilePhoto"],
        memberShip: json["memberShip"],
        upgradedDate: json["upgradedDate"],
        followersCount: json["followersCount"],
        followingCount: json["followingCount"],
        agorauid: json["agorauid"],
        muted: json["muted"] ?? true,
      );

  Map<String, dynamic> toJson() => {
        "followers": followers == null
            ? []
            : List<dynamic>.from(followers!.map((x) => x)),
        "following": following == null
            ? []
            : List<dynamic>.from(following!.map((x) => x)),
        "wallet": wallet,
        "currentRoom": currentRoom,
        "facebook": facebook,
        "instagram": instagram,
        "linkedIn": linkedIn,
        "twitter": twitter,
        "_id": id,
        "firstName": firstName,
        "lastName": lastName,
        "bio": bio,
        "shopId": shopId,
        "userName": userName,
        "email": email,
        "password": password,
        "phonenumber": phonenumber,
        "profilePhoto": profilePhoto,
        "memberShip": memberShip,
        "upgradedDate": upgradedDate,
        "muted": muted ?? true,
        "agorauid": agorauid,
      };
}

bool isInteger(num value) => value is int || value == value.roundToDouble();
