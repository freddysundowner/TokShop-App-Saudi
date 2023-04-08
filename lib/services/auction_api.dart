import 'dart:convert';

import 'package:tokshop/services/client.dart';
import 'package:tokshop/services/end_points.dart';
import 'package:tokshop/utils/functions.dart';

class AuctinAPI {
  Future getAuctionsByRoomId(String roomid) async {
    try {
      var auctionresponse = await DbBase()
          .databaseRequest("$auction$roomid", DbBase().getRequestType);
      var decodedResponse = jsonDecode(auctionresponse);
      return decodedResponse;
    } catch (e, s) {
      printOut("$e $s");
    }
  }

  Future updateAuction(String id, Map<String, dynamic> body) async {
    try {
      var auctionresponse = await DbBase().databaseRequest(
          "$auction$id", DbBase().patchRequestType,
          body: body);
      var decodedResponse = jsonDecode(auctionresponse);
      return decodedResponse;
    } catch (e, s) {
      printOut("$e $s");
    }
  }

  Future addBid(Map<String, dynamic> body) async {
    try {
      var auctionresponse = await DbBase()
          .databaseRequest(auctionbid, DbBase().postRequestType, body: body);
      var decodedResponse = jsonDecode(auctionresponse);
      return decodedResponse;
    } catch (e, s) {
      printOut("$e $s");
    }
  }

  Future updateBid(String userId, Map<String, dynamic> body) async {
    try {
      var bidresponse = await DbBase().databaseRequest(
          "$auctionbid/$userId", DbBase().patchRequestType,
          body: body);
      var decodedResponse = jsonDecode(bidresponse);
      return decodedResponse;
    } catch (e, s) {
      printOut("$e $s");
    }
  }

  Future createAuction(Map<String, dynamic> body) async {
    try {
      var auctionresponse = await DbBase()
          .databaseRequest(auction, DbBase().postRequestType, body: body);
      var decodedResponse = jsonDecode(auctionresponse);
      return decodedResponse;
    } catch (e, s) {
      printOut("$e $s");
    }
  }
}
