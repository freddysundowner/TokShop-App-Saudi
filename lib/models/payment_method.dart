import 'package:tokshop/models/user.dart';

class UserPaymentMethod {
  String? name;
  String? card;
  String? last4;
  String? customerid;
  String? cardid;
  String? token;
  bool? primary;
  String? id;
  String? userid;

  UserPaymentMethod(
      {this.name,
      this.card,
      this.last4,
      this.cardid,
      this.customerid,
      this.token,
      this.primary,
      this.id,
      this.userid});

  factory UserPaymentMethod.toJson(var json) => UserPaymentMethod(
        name: json["name"] ?? "",
        card: json["card"] ?? "",
        last4: json["last4"] ?? "",
        cardid: json["cardid"] ?? "",
        customerid: json["customerid"] ?? "",
        token: json["token"] ?? "",
        primary: json["primary"] ?? false,
        id: json["_id"] ?? "",
        userid: json["userid"],
      );
}
