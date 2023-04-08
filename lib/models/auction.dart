import 'package:firebase_auth/firebase_auth.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/models/tokshow.dart';
import 'package:tokshop/models/user.dart';

class Auction {
  OwnerId? winner;
  UserModel? owner;
  String? id;
  int? higestbid;
  OwnerId? winning;
  List<Bid>? bids;
  Product product;
  String tokshow;
  int? increaseBidBy;
  int baseprice;
  int duration;
  int? startedTime;
  bool? sudden;
  bool? started;
  bool? ended;

  Auction(
      {this.winner,
      this.increaseBidBy,
      this.higestbid,
      this.owner,
      this.winning,
      this.bids,
      required this.tokshow,
      this.sudden,
      required this.baseprice,
      required this.duration,
      this.startedTime,
      this.id,
      this.started,
      required this.product,
      this.ended});

  factory Auction.fromJson(var json) {
    return Auction(
        id: json["_id"],
        winner:
            json["winner"] != null ? OwnerId.fromJson(json["winner"]) : null,
        higestbid: json["higestbid"] ?? 0,
        winning:
            json["winning"] != null ? OwnerId.fromJson(json["winning"]) : null,
        bids: json["bids"] != null
            ? List<Bid>.from(json["bids"].map((x) => Bid.fromJson(x)))
            : [],
        owner: json["owner"] == null ? null : UserModel.fromJson(json["owner"]),
        tokshow: json["tokshow"],
        sudden: json["sudden"] ?? false,
        increaseBidBy: json["increaseBidBy"] ?? 0,
        baseprice: json["baseprice"] ?? 0,
        product: Product.fromJson(json["product"]),
        duration: json["duration"] ?? 30,
        startedTime: json["startedTime"] ?? 0,
        started: json["started"] ?? false,
        ended: json["ended"] ?? false);
  }

  toMap() {
    return {
      "_id": id,
      "winner": winner,
      "higestbid": higestbid,
      "winning": winning,
      "bids": bids!.map((e) => e.toJson()).toList(),
      "tokshow": tokshow,
      "sudden": sudden,
      "owner": owner,
      "increaseBidBy": increaseBidBy,
      "baseprice": baseprice,
      "product": product.toJson(),
      "duration": duration,
      "startedTime": startedTime,
      "started": started,
      "ended": ended
    };
  }

  int getHighestBid() {
    if (bids!.isEmpty) return 0;
    List allbids = [];
    for (var element in bids!) {
      allbids.add(element.amount);
    }
    return allbids.reduce((curr, next) => curr > next ? curr : next);
  }

  int getNextAmountBid() {
    if (bids!.isEmpty) return baseprice;
    List allbids = [];
    for (var element in bids!) {
      allbids.add(element.amount);
    }
    return allbids.reduce((curr, next) => curr > next ? curr : next) +
        increaseBidBy;
  }

  int getHighestBidder() {
    if (bids!.isEmpty) return 0;
    List allbids = [];
    for (var element in bids!) {
      allbids.add(element.amount);
    }
    return allbids.reduce((curr, next) => curr > next ? curr : next);
  }

  Bid getCurrentUserBid() {
    return bids!.firstWhere(
        (e) => e.bidder.id == FirebaseAuth.instance.currentUser!.uid);
  }
}

class Bid {
  OwnerId bidder;
  int amount;

  Bid({required this.bidder, required this.amount});

  factory Bid.fromJson(var json) {
    return Bid(
      amount: json["amount"] ?? 0,
      bidder: OwnerId.fromJson(json["bidder"]),
    );
  }

  toJson() {
    return {
      "bidder": bidder.toJson(),
      "amount": amount,
    };
  }
}
