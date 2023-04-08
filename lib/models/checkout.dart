import 'package:tokshop/models/shippingMethods.dart';

class Checkout {
  String shippingId;
  String productId;
  String shopId;
  String total;
  String tax;
  String shippingFee;
  String? shippingMethd;
  String paymentMethod;
  double servicefee;
  int quantity;
  String productOwnerId;
  String variation;
  String? ordertype;
  String? auctionid;

  Checkout({
    this.auctionid,
    this.ordertype,
    this.shippingMethd,
    required this.shippingId,
    required this.paymentMethod,
    required this.productId,
    required this.shopId,
    required this.total,
    required this.tax,
    required this.servicefee,
    required this.shippingFee,
    required this.quantity,
    required this.productOwnerId,
    required this.variation,
  });

  factory Checkout.fromJson(Map<String, dynamic> json) => Checkout(
      shippingId: json["shippingId"],
      ordertype: json["ordertype"] ?? "",
      auctionid: json["auctionid"],
      shippingMethd: json["shippingMethd"] ?? "",
      productId: json["productId"],
      shopId: json["shopId"],
      servicefee: json["servicefee"],
      total: json["total"],
      paymentMethod: json["paymentMethod"] ?? "cc",
      tax: json["tax"],
      shippingFee: json["shippingFee"],
      quantity: json["quantity"],
      productOwnerId: json["productOwnerId"],
      variation: json["variation"]);

  Map<String, dynamic> toJson() => {
        "shippingId": shippingId,
        "productId": productId,
        "shippingMethd": shippingMethd,
        "paymentMethod": paymentMethod,
        "shopId": shopId,
        "total": total,
        "tax": tax,
        "shippingFee": shippingFee,
        "quantity": quantity,
        "productOwnerId": productOwnerId,
        "variation": variation
      };
}
