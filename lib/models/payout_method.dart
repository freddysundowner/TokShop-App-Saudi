import 'package:tokshop/models/user.dart';

class PayoutMethod {
  String? accountname;
  String? type;
  String? userid;
  bool? primary;
  String? id;

  PayoutMethod(
      {this.accountname, this.type, this.primary, this.id, this.userid});

  factory PayoutMethod.toJson(var json) => PayoutMethod(
        accountname: json["accountname"] ?? "",
        primary: json["primary"] ?? false,
        id: json["_id"] ?? "",
        type: json["type"] ?? "",
        userid: json["userid"],
      );

  toJson() => {
        "accountname": accountname,
        "primary": primary,
        "id": id,
        "type": type,
        "userid": userid,
      };
}
