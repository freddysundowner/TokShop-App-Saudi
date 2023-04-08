import 'package:tokshop/utils/configs.dart';

class ShippingMethods {
  String name;
  String amount;
  bool enabled;

  ShippingMethods(this.name, this.amount, this.enabled);

  factory ShippingMethods.fromJson(json) => ShippingMethods(
      json["name"], json["amount"].toString(), json["enabled"] ?? false);

  Map<String, dynamic> toJson() => {
        "name": name,
        "amount": amount,
        "enabled": enabled,
      };

  htmlPrice(price) {
    return currencySymbol + price.toStringAsFixed(0);
  }
}

bool isInteger(num value) => value is int || value == value.roundToDouble();
