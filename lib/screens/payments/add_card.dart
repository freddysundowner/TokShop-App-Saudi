import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/models/payment_method.dart';
import 'package:tokshop/services/client.dart';
import 'package:tokshop/services/end_points.dart';
import 'package:tokshop/services/user_api.dart';
import 'package:tokshop/utils/configs.dart';
import 'package:tokshop/utils/text.dart';

class AddCard extends StatefulWidget {
  String? from;
  AddCard({Key? key, this.from}) : super(key: key);

  @override
  State<AddCard> createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  CardFieldInputDetails? _card;

  TokenData? tokenData;
  int step = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            CardField(
              autofocus: true,
              onCardChanged: (card) {
                setState(() {
                  _card = card;
                });
              },
            ),
            const SizedBox(height: 20),
            if (isDev)
              const Text(
                "$text_card : 4242 4242 4242 4242",
                style: TextStyle(color: Colors.black),
              ),
            if (isDev) const Text("$exp_date: 11/34"),
            if (isDev) const Text("$cv : 123"),
            if (isDev) const SizedBox(height: 20),
            LoadingButton(
              onPressed:
                  _card?.complete == true ? _handleCreateTokenPress : null,
              text: add_payment_method,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateTokenPress() async {
    try {
      if (_card == null) {
        return;
      }
      TokenData tokenData = await Stripe.instance.createToken(
          const CreateTokenParams.card(
              params: CardTokenParams(currency: 'USD')));
      setState(() {
        this.tokenData = tokenData;
      });

      await UserAPI().createStripeCardToken({
        "userid": FirebaseAuth.instance.currentUser!.uid,
        "id": tokenData.id,
        "cardid": tokenData.card!.id,
        "name": tokenData.card!.brand,
        "token": tokenData.id,
        "last4": tokenData.card!.last4,
        "type": "card",
      }, FirebaseAuth.instance.currentUser!.uid).then((value) async {
        UserPaymentMethod? paymentMethod = UserPaymentMethod.toJson(value);
        Get.find<AuthController>().usermodel.value!.defaultpaymentmethod =
            paymentMethod;
        if (widget.from == "roompage") {
          Get.back();
          Get.back();
          Get.find<AuthController>().usermodel.refresh();
          if (Get.find<AuthController>().usermodel.value!.address != null) {
            Get.back();
            Get.back();
          }
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credit card added successfully!')));
      return;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      rethrow;
    }
  }
}

class LoadingButton extends StatefulWidget {
  final Future Function()? onPressed;
  final String text;

  const LoadingButton({Key? key, required this.onPressed, required this.text})
      : super(key: key);

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12)),
            onPressed:
                (_isLoading || widget.onPressed == null) ? null : _loadFuture,
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ))
                : Text(widget.text),
          ),
        ),
      ],
    );
  }

  Future<void> _loadFuture() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed!();
    } catch (e, s) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error $e')));
      rethrow;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
