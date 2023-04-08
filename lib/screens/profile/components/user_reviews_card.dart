import 'package:flutter/material.dart';
import 'package:tokshop/models/UserReview.dart';
import 'package:tokshop/screens/products/components/review_box.dart';
import 'package:tokshop/utils/size_config.dart';

class UserReviewsCard extends StatelessWidget {
  const UserReviewsCard({
    Key? key,
    required this.reviews,
  }) : super(key: key);

  final List<UserReview>? reviews;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: getProportionateScreenHeight(320),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: getProportionateScreenHeight(20)),
              if (reviews!.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: reviews!.length,
                    itemBuilder: (context, index) {
                      return ReviewBox(
                        userreview: reviews![index],
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
