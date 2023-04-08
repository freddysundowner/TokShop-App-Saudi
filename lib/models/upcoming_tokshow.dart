import 'package:tokshop/models/channel.dart';

import 'product.dart';
import 'tokshow.dart';
import 'shop.dart';
import 'user.dart';

class UpcomingTokshow {
  UpcomingTokshow(
      {this.productIds,
      this.hostIds,
      this.userIds,
      this.raisedHands,
      this.eventDate,
      this.speakerIds,
      this.invitedIds,
      this.status,
      this.event,
      this.productImages,
      this.id,
      this.ownerId,
      this.title,
      this.shopId,
      this.productPrice,
      this.v,
      this.token,
      this.roomType,
      this.invitedhostIds,
      this.activeTime,
      this.resourceId,
      this.recordingsid,
      this.description,
      this.recordingUid,
      this.toBeNotified,
      this.channel});

  List<Product>? productIds;
  List<OwnerId>? hostIds = [];
  List<OwnerId>? invitedhostIds = [];
  List<OwnerId>? userIds = [];
  List<OwnerId>? raisedHands = [];
  List<OwnerId>? speakerIds = [];
  List<OwnerId>? invitedIds = [];
  List<OwnerId>? toBeNotified = [];
  bool? event;
  bool? status;
  List<dynamic>? productImages = [];
  String? id;
  int? activeTime;
  UserModel? ownerId;
  String? title = "";
  int? eventDate = 0;
  String? recordingUid = "";
  String? resourceId = "";
  String? description = "";
  String? recordingsid = "";
  Brand? shopId;
  List<String>? productPrice;
  int? v;
  String? roomType;
  dynamic token;
  List<Channel>? channel;

  factory UpcomingTokshow.fromJson(Map<String, dynamic> json) {
    return UpcomingTokshow(
        productIds: json["productIds"] == null
            ? []
            : List<Product>.from(
                json["productIds"].map((x) => Product.fromJson(x))),
        hostIds: json["hostIds"] == null
            ? []
            : List<OwnerId>.from(
                json["hostIds"].map((x) => OwnerId.fromJson(x))),
        userIds: json["userIds"] == null
            ? []
            : List<OwnerId>.from(
                json["userIds"].map((x) => OwnerId.fromJson(x))),
        raisedHands: json["raisedHands"] == null
            ? []
            : List<OwnerId>.from(
                json["raisedHands"].map((x) => OwnerId.fromJson(x))),
        speakerIds: json["speakerIds"] == null
            ? []
            : List<OwnerId>.from(
                json["speakerIds"].map((x) => OwnerId.fromJson(x))),
        invitedIds: json["invitedIds"] == null
            ? []
            : List<OwnerId>.from(
                json["invitedIds"].map((x) => OwnerId.fromJson(x))),
        status: json["status"],
        productImages: json["productImages"] == null
            ? []
            : List<String>.from(json["productImages"].map((x) => x.toString())),
        toBeNotified:
            json["toBeNotified"] == null || json["toBeNotified"].toString().length < 40
                ? []
                : List<OwnerId>.from(
                    json["toBeNotified"].map((x) => OwnerId.fromJson(x))),
        id: json["_id"] ?? "",
        ownerId: json["ownerId"] == null
            ? null
            : UserModel.fromJson(json["ownerId"]),
        title: json["title"] ?? "",
        shopId: json["ownerId"] == null
            ? null
            : UserModel.fromJson(json["ownerId"]).shopId,
        invitedhostIds: json["invitedhostIds"] == null ? [] : List<OwnerId>.from(json["invitedhostIds"].map((x) => OwnerId.fromJson(x))),
        productPrice: json["productPrice"] == null ? [] : List<String>.from(json["productPrice"].map((x) => x.toString())),
        token: json["token"],
        recordingsid: json["recordingsid"] ?? "",
        description: json["description"] ?? "",
        recordingUid: json["recordingUid"] ?? "",
        resourceId: json["resourceId"] ?? "",
        eventDate: json["eventDate"] ?? "",
        activeTime: json["activeTime"] ?? DateTime.now().millisecondsSinceEpoch,
        roomType: json["roomType"],
        event: json["event"],
        channel: json["channel"] == null ? [] : List<Channel>.from(json["channel"].map((x) => Channel.fromJson(x)))); //json["channel"] != null ? Channel.fromJson(json["channel"]) : null);
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
        "productImages": productImages == []
            ? []
            : List<dynamic>.from(productImages!.map((x) => x)),
        "toBeNotified": toBeNotified == []
            ? []
            : List<dynamic>.from(toBeNotified!.map((x) => x)),
        "_id": id,
        "ownerId": ownerId == null ? null : ownerId!.toJson(),
        "title": title,
        "shopId": shopId == null ? null : shopId!.toJson(),
        "productPrice": productPrice,
        "__v": v,
        "token": token,
        "roomType": roomType,
        "recordingsid": recordingsid,
        "recordingUid": recordingUid,
        "eventDate": eventDate,
        "resourceId": resourceId,
        "event": event,
      };
}
