import 'dart:convert';

import 'package:tokshop/models/shippingMethods.dart';

import 'product.dart';
import 'user.dart';

class Order {
  Order({
    this.status,
    this.quantity,
    this.date,
    this.id,
    this.invoice,
    this.shippingMethd,
    this.customerId,
    this.shippingId,
    this.shopId,
    this.subTotal,
    this.tax,
    this.paymentMethod,
    this.shippingFee,
    this.servicefee,
    this.itemId,
    this.productId,
    this.totalCost,
  });

  String? status;
  int? quantity;
  int? date;
  int? invoice;
  String? id;
  String? shippingMethd;
  UserModel? customerId;
  ShippingId? shippingId;
  ShopId? shopId;
  String? paymentMethod;
  double? subTotal;
  int? tax;
  int? shippingFee;
  ItemId? itemId;
  String? productId;
  double? servicefee;
  double? totalCost;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      status: json["status"],
      quantity: json["quantity"],
      paymentMethod: json["paymentMethod"] ?? "cc",
      invoice: json["invoice"] ?? 00000,
      date: json["date"],
      id: json["_id"],
      shippingMethd: json["shippingMethd"] ?? "",
      customerId: UserModel.fromJson(json["customerId"] ?? {}),
      shippingId: json["shippingId"] == null
          ? null
          : ShippingId.fromJson(json["shippingId"]),
      shopId: json["shopId"].toString().length > 40
          ? ShopId.fromJson(json["shopId"] ?? {})
          : null,
      subTotal: isInteger(json["subTotal"]) == true
          ? json["subTotal"].toDouble()
          : json["subTotal"],
      tax: json["tax"],
      servicefee: json["servicefee"] == null
          ? 0.0
          : isInteger(json["servicefee"]) == true
              ? json["servicefee"].toDouble()
              : json["servicefee"],
      shippingFee: json["shippingFee"],
      itemId: ItemId.fromJson(json["itemId"] ?? {}),
      productId: json["productId"],
      totalCost: isInteger(json["totalCost"]) == true
          ? json["totalCost"].toDouble()
          : json["totalCost"],
    );
  }

  ShippingMethods getShippingMethod(var sm) {
    return ShippingMethods.fromJson(jsonDecode(shippingMethd!));
  }

  getPaymentMethod() {
    switch (paymentMethod) {
      case "cc":
        return "Credit Card";
      case "cod":
        return "Cash On Delivery";
      case "fw":
        return "Flutter Wave";
      default:
        return "Cash On Delivery";
    }
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "quantity": quantity,
        "date": date,
        "_id": id,
        "customerId": customerId,
        "shippingId": shippingId?.toJson(),
        "shopId": shopId,
        "subTotal": subTotal,
        "tax": tax,
        "shippingFee": shippingFee,
        "itemId": itemId?.toJson(),
        "productId": productId,
        "totalCost": totalCost,
      };
}

class ItemId {
  ItemId({
    this.id,
    this.productId,
    this.quantity,
    this.orderId,
    this.variation,
  });

  String? id;
  Product? productId;
  int? quantity;
  String? orderId;
  String? variation;

  factory ItemId.fromJson(Map<String, dynamic> json) => ItemId(
      id: json["_id"],
      productId: json["productId"] == null
          ? null
          : Product.fromJson(json["productId"]),
      quantity: json["quantity"],
      orderId: json["orderId"],
      variation: json["variation"] ?? "");

  Map<String, dynamic> toJson() => {
        "_id": id,
        "productId": productId?.toJson(),
        "quantity": quantity,
        "orderId": orderId,
        "variation": variation
      };
}

class ShippingId {
  ShippingId({
    this.addrress2,
    this.state,
    this.id,
    this.name,
    this.addrress1,
    this.city,
    this.phone,
    this.userId,
  });

  String? addrress2;
  String? state;
  String? id;
  String? name;
  String? addrress1;
  String? city;
  String? phone;
  String? userId;

  factory ShippingId.fromJson(Map<String, dynamic> json) => ShippingId(
        addrress2: json["addrress2"] == "" ? "" : json["addrress2"],
        state: json["state"] ?? "",
        id: json["_id"] ?? "",
        name: json["name"],
        addrress1: json["addrress1"] ?? "",
        city: json["city"] ?? "",
        phone: json["phone"] ?? "",
        userId: json["userId"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "addrress2": addrress2,
        "state": state,
        "_id": id,
        "name": name,
        "addrress1": addrress1,
        "city": city,
        "phone": phone,
        "userId": userId,
      };
}

bool isInteger(num value) => value is int || value == value.roundToDouble();
