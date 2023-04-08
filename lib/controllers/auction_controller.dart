import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/controllers/checkout_controller.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/models/auction.dart';
import 'package:tokshop/models/payment_method.dart';
import 'package:tokshop/models/payout_method.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/models/tokshow.dart';
import 'package:tokshop/screens/room/live_tokshows.dart';
import 'package:tokshop/services/auction_api.dart';
import 'package:tokshop/services/client.dart';
import 'package:tokshop/services/end_points.dart';
import 'package:tokshop/services/user_api.dart';
import 'package:tokshop/utils/styles.dart';
import 'package:tokshop/widgets/text_form_field.dart';

import '../services/room_api.dart';
import '../utils/text.dart';
import '../utils/utils.dart';

class AuctionController extends GetxController {
  var duration = 30.obs;
  var suddentAuction = false.obs;
  TextEditingController startBidPrice = TextEditingController();
  TextEditingController custombidprice = TextEditingController();
  late Timer timer;
  final formatedTimeString = "00:00".obs;

  void startTimer() {
    TokShowController tokShowController = Get.find<TokShowController>();
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (tokShowController.currentRoom.value.activeauction!.duration <= 0 &&
            tokShowController.currentRoom.value.activeauction!.started ==
                true) {
          tokShowController.currentRoom.value.activeauction!.ended = true;
          timer.cancel();
          removeAuction();
        } else {
          if (tokShowController.currentRoom.value.activeauction != null &&
              tokShowController
                  .currentRoom.value.activeauction!.bids!.isNotEmpty) {
            Bid? bid =
                findWinner(tokShowController.currentRoom.value.activeauction);

            tokShowController.currentRoom.value.activeauction!.winning =
                bid!.bidder;
          }
          formatedTimeString.value = formatedTime(
              timeInSecond: tokShowController
                  .currentRoom.value.activeauction!.duration--);
        }
      },
    );
  }

  formatedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  void removeAuction() {
    Auction? auction =
        Get.find<TokShowController>().currentRoom.value.activeauction;
    Tokshow? tokshow = Get.find<TokShowController>().currentRoom.value;

    if (auction != null &&
        tokshow.ownerId!.id == FirebaseAuth.instance.currentUser!.uid) {
      Get.find<TokShowController>().sendChannelMessage(
          Get.find<TokShowController>().currentRoom.value.ownerId!.toJson(),
          action: "removeauction",
          otherdata: auction.toMap());

      awardWinner(auction);

      AuctinAPI().updateAuction(auction.id!,
          {"winner": tokshow.ownerId!.id, "ended": true}).then((value) {
        RoomAPI().updateRoomId({
          "token": tokshow.token,
          "auctions": [auction.id],
          "activeauction": null,
        }, tokshow.id!);
        Get.find<TokShowController>().currentRoom.value.activeauction = null;
        Get.find<TokShowController>().currentRoom.refresh();
      });
    }
    timer.cancel();
  }

  void addToAuction(Product product) {
    Get.find<TokShowController>().errorroomtitle.value = "";
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        backgroundColor: Color(0Xfff4f5fa),
        context: Get.context!,
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      auction_settings,
                      style: TextStyle(color: primarycolor, fontSize: 18.sp),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(product.name!,
                        style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp)),
                    Text("$qty 1",
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(starting_bid,
                                style: TextStyle(
                                    color: primarycolor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp)),
                            const SizedBox(
                              height: 5,
                            ),
                            CustomTextFormField(
                              controller: startBidPrice,
                              txtType: TextInputType.number,
                              txtColor: primarycolor,
                              prefix: Text(
                                currencySymbol,
                                style: const TextStyle(color: primarycolor),
                              ),
                            ),
                          ],
                        )),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(time,
                                style: TextStyle(
                                    color: primarycolor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp)),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 13),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: primarycolor, width: 1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: Obx(
                                  () => Text(
                                    "${duration.value}s",
                                    style: TextStyle(
                                        color: primarycolor, fontSize: 12.sp),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [10, 20, 30, 50, 1]
                            .map((e) => InkWell(
                                  onTap: () {
                                    duration.value = e;
                                  },
                                  child: Obx(
                                    () => Container(
                                      height: 20,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 5),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 5),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: duration.value == e
                                                  ? kPrimaryColor
                                                  : primarycolor,
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Center(
                                        child: Text(
                                          "${e}s",
                                          style: TextStyle(
                                              color: primarycolor,
                                              fontSize: 12.sp),
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Expanded(
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Text("Sudden Death 💀",
                    //               style: TextStyle(
                    //                   color: primarycolor,
                    //                   fontSize: 14.sp,
                    //                   fontWeight: FontWeight.bold)),
                    //           Text(
                    //               "This means when you're down to 00:01, the last person to bid wins!",
                    //               style: TextStyle(
                    //                   color: primarycolor, fontSize: 11.sp)),
                    //         ],
                    //       ),
                    //     ),
                    //     const SizedBox(
                    //       width: 100,
                    //     ),
                    //     Obx(
                    //       () => Switch(
                    //           value: suddentAuction.value,
                    //           onChanged: (v) {
                    //             suddentAuction.value = !suddentAuction.value;
                    //           }),
                    //     ),
                    //     Divider(),
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: 20,
                    // ),
                    Obx(
                      () => Get.find<TokShowController>()
                              .errorroomtitle
                              .value
                              .isEmpty
                          ? Container()
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  Get.find<TokShowController>()
                                      .errorroomtitle
                                      .value,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: primarycolor, width: 1),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            cancel,
                            style:
                                TextStyle(color: primarycolor, fontSize: 12.sp),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          onTap: () {
                            if (startBidPrice.text.isNotEmpty) {
                              _addAuction(product);
                            } else {
                              Get.find<TokShowController>()
                                  .errorroomtitle
                                  .value = start_bid_price_is_required;
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
                            decoration: BoxDecoration(
                                color: primarycolor,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              start_auction,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.sp),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ));
  }

  _addAuction(Product product) {
    if (product.quantity! <= 0) {
      Get.back();
      Get.snackbar("", not_have_enough_quantity_on_this_product,
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    Get.find<TokShowController>().removePinned();
    formatedTimeString.value = "00:00";
    var au = {
      "baseprice": int.parse(startBidPrice.text),
      "duration": duration.value,
      "started": false,
      "product": product.id,
      "tokshow": Get.find<TokShowController>().currentRoom.value.id!
    };
    Get.back();
    Get.back();
    startBidPrice.clear();
    AuctinAPI().createAuction(au).then((value) {
      Auction auction = Auction.fromJson(value);

      Get.find<TokShowController>().currentRoom.value.activeauction = auction;
      Get.find<TokShowController>().currentRoom.refresh();
      Get.find<TokShowController>().sendChannelMessage(
          {"productid": product.id},
          action: "activeauction", otherdata: auction.toMap());
    });
  }

  _bidUpdateAdd(OwnerId currentUser, int bidamount) {
    TokShowController tokShowController = Get.find<TokShowController>();
    Bid bid = Bid(bidder: currentUser, amount: bidamount);
    bool emit = false;
    if (tokShowController.currentRoom.value.activeauction != null) {
      int i = Get.find<TokShowController>()
          .currentRoom
          .value
          .activeauction!
          .bids!
          .indexWhere((element) => element.bidder.id == currentUser.id);
      if (i != -1) {
        Bid oldbid =
            tokShowController.currentRoom.value.activeauction!.bids![i];
        if (oldbid.amount < bidamount) {
          tokShowController.currentRoom.value.activeauction!.bids![i] = bid;
          emit = true;
        }
      } else {
        tokShowController.currentRoom.value.activeauction!.bids!.add(bid);
        emit = true;
      }
    } else {
      tokShowController.currentRoom.value.activeauction!.bids!.add(bid);
      emit = true;
    }
    return emit;
  }

  void bid(OwnerId currentUser, int bidamount) async {
    TokShowController tokShowController = Get.find<TokShowController>();
    Bid bid = Bid(bidder: currentUser, amount: bidamount);
    bool emit = _bidUpdateAdd(currentUser, bidamount);
    bool userExists = false;
    if (tokShowController.currentRoom.value.activeauction != null) {
      int i = Get.find<TokShowController>()
          .currentRoom
          .value
          .activeauction!
          .bids!
          .indexWhere((element) => element.bidder.id == currentUser.id);
      if (i != -1) {
        userExists = true;
        Bid oldbid =
            tokShowController.currentRoom.value.activeauction!.bids![i];
        if (oldbid.amount < bidamount) {
          tokShowController.currentRoom.value.activeauction!.bids![i] = bid;
          emit = true;
        }
      } else {
        tokShowController.currentRoom.value.activeauction!.bids!.add(bid);
        emit = true;
      }
    } else {
      tokShowController.currentRoom.value.activeauction!.bids!.add(bid);
      emit = true;
    }

    // emit to oother users
    if (emit) {
      tokShowController.currentRoom.value.activeauction!.winning =
          findWinner(tokShowController.currentRoom.value.activeauction)!.bidder;

      await tokShowController.emitRoom(
          action: "bid",
          currentUser: currentUser.toJson(),
          otherdata: bid.toJson(),
          roomId: tokShowController.currentRoom.value.id!,
          extra: true,
          agoraRtmChannel: tokShowController.rtmChannel);
      tokShowController.currentRoom.refresh();
      if (userExists) {
        AuctinAPI().updateBid(currentUser.id!, {
          "amount": bidamount,
        });
      } else {
        AuctinAPI().addBid({
          "user": currentUser.id,
          "amount": bidamount,
          "auction": tokShowController.currentRoom.value.activeauction!.id
        });
      }
    }
  }

  awardWinner(Auction? auction) {
    if (auction!.bids!.isEmpty) return null;
    auction.winner = findWinner(auction)!.bidder;

    Get.find<TokShowController>().emitRoom(
        currentUser: Get.find<AuthController>().usermodel.value!.toJson(),
        action: "wonalert",
        otherdata: auction.toMap(),
        roomId: Get.find<TokShowController>().currentRoom.value.id!);
    Get.find<TokShowController>().wornUi(Get.context!, auction.winner!);
    if (auction.winner!.id == FirebaseAuth.instance.currentUser!.uid) {
      createCharge(findWinner(auction)!.amount.toString(),
              winnerId: auction.winner!.id,
              productOwner: auction.product.ownerId!.id!)
          .then((value) {
        if (value == true) {
          Get.find<CheckOutController>()
              .auctionOrder(auction, findWinner(auction)!);
        }
      });
    }
  }

  Future createCharge(String amount,
      {String? winnerId, String? productOwner}) async {
    var response = await DbBase().databaseRequest(
        createIntentStripeUrl, DbBase().postRequestType,
        bodyFields: {
          "amount": amount,
          "confirm": "true",
          "winnerId": winnerId!,
          "productOwner": productOwner!,
        });
    return response["response"];
  }
}

Bid? findWinner(Auction? auction) {
  if (auction!.bids!.isEmpty) return null;
  List allbids = [];
  for (var element in auction.bids!) {
    allbids.add(element.amount);
  }
  int bidamount = allbids.reduce((curr, next) => curr > next ? curr : next);
  Bid bidwinnder =
      auction.bids!.firstWhere((element) => element.amount == bidamount);
  return bidwinnder;
}
