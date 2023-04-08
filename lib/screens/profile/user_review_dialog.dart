import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/order_controller.dart';
import 'package:tokshop/controllers/user_controller.dart';
import 'package:tokshop/models/order.dart';
import 'package:tokshop/models/user.dart';
import 'package:tokshop/utils/size_config.dart';
import 'package:tokshop/utils/text.dart';
import 'package:tokshop/widgets/default_button.dart';

class UserReviewDialog extends StatelessWidget {
  final UserModel user;
  UserReviewDialog({
    Key? key,
    required this.user,
  }) : super(key: key);

  final UserController userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Center(
        child: Text(
      rate,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      children: [
        Center(
          child: RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              userController.ratingvalue.value = rating.round();
            },
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(20)),
        Center(
          child: TextFormField(
            minLines: 3,
            initialValue: userController.review.text,
            validator: (c) {
              if (c!.isEmpty) {
                return feedback_cannot_be_empty;
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: feedback_optional,
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            onChanged: (value) {
              userController.review.text = value;
            },
            maxLines: null,
            maxLength: 150,
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(10)),
        Obx(() => Text(
              userController.ratingError.value.isNotEmpty
                  ? userController.ratingError.value
                  : "",
              style: const TextStyle(color: Colors.red),
            )),
        Center(
          child: DefaultButton(
            text:submit,
            press: () {
              userController.ratingError.value = "";
              if (userController.review.text.isEmpty) {
                userController.ratingError.value = feedback_is_required;
              } else {
                userController.addUserReview(
                    userController.currentProfile.value.id!,
                    userController.review.text,
                    userController.ratingvalue.value);
                Get.back();
              }
              // Get.back();
            },
          ),
        ),
      ],
    );
  }
}
