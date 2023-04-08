import 'package:tokshop/models/Review.dart';
import 'package:tokshop/models/channel.dart';
import 'package:tokshop/models/interests.dart';

import '../utils/utils.dart';
import 'shop.dart';
import 'user.dart';

class Product {
  List<dynamic>? images;
  List<String>? variations;
  List<Interests>? interest;
  List<Review>? reviews;
  String? id;
  String? type;
  String? name;
  double? price;
  int? quantity;
  int? discountPrice;
  Brand? shopId;
  UserModel? ownerId;
  String? description;
  bool? available;
  bool? deleted;
  double? discountedPrice;

  Product({
    this.images = const [],
    this.interest = const [],
    this.id,
    this.name,
    this.price,
    this.discountPrice,
    this.discountedPrice,
    this.quantity,
    this.shopId,
    this.type,
    this.reviews,
    this.variations,
    this.ownerId,
    this.description,
    this.deleted,
    this.available,
  });

  htmlPrice(price) {
    return currencySymbol + price.toStringAsFixed(0);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      images: json["images"] == null
          ? []
          : List<dynamic>.from(json["images"] ?? [].map((x) => x.toString())),
      id: json["_id"],
      name: json["name"] ?? "",
      deleted: json["deleted"] ?? false,
      price: isInteger(json["price"]) == true
          ? json["price"].toDouble()
          : json["price"],
      quantity: json["quantity"] ?? 0,
      type: json["type"] ?? "tokshop",
      variations: json["variations"] == null
          ? []
          : List<String>.from(json["variations"].map((x) => x.toString())),
      reviews: json["reviews"] == null
          ? []
          : List<Review>.from(json["reviews"].map((x) => Review.fromMap(x))),
      shopId: json["shopId"].toString().length > 40
          ? Brand.fromJson(json["shopId"])
          : json["ownerId"] != null
              ? Brand.fromJson(json["ownerId"]["shopId"] ?? {})
              : Brand(id: json["shopId"]),
      ownerId: UserModel.fromJson(json["ownerId"] ?? {}),
      description: json["description"],
      available: json["available"],
      discountedPrice: json["discountedPrice"] != null
          ? isInteger(json["discountedPrice"]) == true
              ? json["discountedPrice"].toDouble()
              : json["discountedPrice"]
          : json["price"].toDouble(),
      interest:
          json["interest"] == null || json["interest"].toString().length < 40
              ? []
              : List<Interests>.from(
                  json["interest"].map((x) => Interests.fromJson(x))),
    );
  }

  getReviewsAverage() => reviews!.isEmpty
      ? 0.toDouble()
      : reviews!
              .map((e) => e.rating)
              .toList()
              .reduce((value, element) => value + element) /
          reviews!.length;

  Map<String, dynamic> toJson() => {
        "images": images!.map((e) => e).toList(),
        "_id": id,
        "name": name,
        "deleted": deleted,
        "price": price,
        "quantity": quantity,
        "type": type,
        "variations": variations!.map((e) => e).toList(),
        "reviews": reviews!.map((e) => e.toMap()).toList(),
        "shopId": shopId!.toJson(),
        "ownerId": ownerId!.toJson(),
        "description": description,
        "available": available,
        "discountedPrice": discountedPrice,
        "interest": interest!.map((e) => e.toMap()).toList(),
      };

  int calculatePercentageDiscount() {
    int discount =
        (((price! - discountedPrice!) * 100) / discountedPrice!).round();
    return discount;
  }
}

bool isInteger(num value) => value is int || value == value.roundToDouble();

List<Product> getProducts() {
  List<Product> product = [];

  return product;
}
