import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/order_controller.dart';
import 'package:tokshop/models/order.dart';
import 'package:tokshop/utils/size_config.dart';
import 'package:tokshop/widgets/default_button.dart';

import '../../utils/text.dart';

class ProductReviewDialog extends StatelessWidget {
  final Order order;
  ProductReviewDialog({
    Key? key,
    required this.order,
  }) : super(key: key);

  final OrderController _orderController = Get.find<OrderController>();
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Center(
        child: Text(
          review,
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
              _orderController.ratingvalue.value = rating.round();
            },
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(20)),
        Center(
          child: TextFormField(
            initialValue: _orderController.review.text,
            validator: (c) {
              if (c!.isEmpty) {
                return feedback_cannot_be_empty;
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: review_this_product,
              labelText: feedback_optional,
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            onChanged: (value) {
              _orderController.review.text = value;
            },
            maxLines: null,
            maxLength: 150,
          ),
        ),
        SizedBox(height: getProportionateScreenHeight(10)),
        Obx(() => Text(
              _orderController.ratingError.value.isNotEmpty
                  ? _orderController.ratingError.value
                  : "",
              style: const TextStyle(color: Colors.red),
            )),
        Center(
          child: DefaultButton(
            text: submit,
            press: () {
              _orderController.ratingError.value = "";
              if (_orderController.review.text.isEmpty) {
                _orderController.ratingError.value = feedback_is_required;
              } else {
                _orderController.addProductReview(
                    order.itemId!.productId!.id!,
                    _orderController.review.text,
                    _orderController.ratingvalue.value);
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
