import 'tokshow.dart';

class Transaction {
  Transaction(
      {required this.date,
      required this.id,
      this.from,
      required this.to,
      required this.reason,
      required this.amount,
      required this.type,
      required this.deducting,
      required this.shopId,
      required this.orderId,
      required this.status,
      required this.stripeBankAccount});

  int date;
  String id;
  OwnerId? from;
  OwnerId to;
  String reason;
  double amount;
  String type;
  bool deducting;
  String shopId;
  String orderId;
  String status;
  String stripeBankAccount;

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        date: json["date"],
        id: json["_id"],
        from: OwnerId.fromJson(json["from"] ?? {}),
        to: OwnerId.fromJson(json["to"]),
        reason: json["reason"],
        amount: isInteger(json["amount"]) == true
            ? json["amount"].toDouble()
            : json["amount"],
        type: json["type"],
        deducting: json["deducting"],
        shopId: json["shopId"] ?? "",
        orderId: json["orderId"] ?? "",
        status: json["status"] ?? "Completed",
        stripeBankAccount: json["stripeBankAccount"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "_id": id,
        "from": from,
        "to": to,
        "reason": reason,
        "amount": amount,
        "type": type,
        "deducting": deducting,
        "shopId": shopId,
        "orderId": orderId,
        "stripeBankAccount": stripeBankAccount
      };
}
