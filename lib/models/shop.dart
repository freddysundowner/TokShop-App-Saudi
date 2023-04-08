import 'package:tokshop/models/channel.dart';
import 'package:tokshop/models/interests.dart';
import 'package:tokshop/models/shippingMethods.dart';
import 'package:tokshop/models/user.dart';

class Brand {
  Brand({
    this.open,
    this.id,
    this.name,
    this.email,
    this.ownerId,
    this.allowWcimport,
    this.interests,
    this.followers,
    this.phoneNumber,
    this.paymentOptions,
    this.image,
    this.shippingMethods,
  });

  bool? allowWcimport;
  bool? open;
  String? id;
  String? name;
  String? email;
  List<ShippingMethods>? shippingMethods;
  List<String>? paymentOptions;
  List<String>? followers;
  UserModel? ownerId;
  String? phoneNumber;
  String? image;
  List<Interests>? interests;

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      allowWcimport: json["allowWcimport"] ?? true,
      open: json["open"] ?? true,
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      paymentOptions: json["paymentOptions"] == null
          ? []
          : List<String>.from(json["paymentOptions"].map((x) => x)),
      shippingMethods: json["shippingMethods"] == null
          ? []
          : List<ShippingMethods>.from(
              json["shippingMethods"].map((x) => ShippingMethods.fromJson(x))),
      phoneNumber: json["phoneNumber"] ?? "",
      ownerId: json["userId"] == null || json["userId"].toString().length < 40
          ? null
          : UserModel.fromJson(json["userId"]),
      image: json["image"] ?? "",
      interests:
          json["interest"] == null || json["interest"].toString().length < 40
              ? []
              : List<Interests>.from(
                  json["interest"].map((x) => Interests.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
        "allowWcimport": allowWcimport,
        "paymentOptions": paymentOptions,
        "phoneNumber": phoneNumber,
        "image": image ?? "",
      };
}
