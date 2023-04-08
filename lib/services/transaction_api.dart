import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tokshop/utils/configs.dart';

import 'client.dart';
import 'end_points.dart';

class TransactionAPI {
  getUserTransactions() async {
    var transactions = await DbBase().databaseRequest(
        userTransactions + FirebaseAuth.instance.currentUser!.uid,
        DbBase().getRequestType);

    return jsonDecode(transactions);
  }

  getMoreUserTransactions(int pageNumber) async {
    var transactions = await DbBase().databaseRequest(
        "$userTransactionsPaginated${FirebaseAuth.instance.currentUser!.uid}/$pageNumber",
        DbBase().getRequestType);

    var decodedTransactions = jsonDecode(transactions);
    var finalTransactions = [];

    for (var a in decodedTransactions.elementAt(0)["data"]) {
      a["from"] = a["from"].isEmpty ? null : a["from"].elementAt(0);
      a["to"] = a["to"].isEmpty ? null : a["to"].elementAt(0);
      finalTransactions.add(a);
    }

    return finalTransactions;
  }

  saveTransaction(Map<String, dynamic> body, String userId) async {
    var savedTransactions = await DbBase()
        .databaseRequest(transactions, DbBase().postRequestType, body: body);

    return jsonDecode(savedTransactions);
  }

  withdrawToBank(String amount) async {
    var response = await DbBase().databaseRequest(
        "$stripePayout/${FirebaseAuth.instance.currentUser!.uid}",
        DbBase().postRequestType,
        bodyFields: {
          "amount": amount,
        });
    return jsonDecode(response);
  }
}
