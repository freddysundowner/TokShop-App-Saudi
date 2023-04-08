import 'package:tokshop/models/user.dart';

class UserReview {
  static const String REVIEWER_UID_KEY = "_id";
  static const String RATING_KEY = "rating";
  static const String FEEDBACK_KEY = "review";
  static const String FROM_KEY = "from";

  String? reviewerUid;
  int rating;
  String? feedback;
  UserModel? from;
  UserReview({
    this.reviewerUid,
    this.rating = 3,
    this.feedback,
    this.from,
  });

  factory UserReview.fromMap(Map<String, dynamic> map) {
    return UserReview(
      reviewerUid: map[REVIEWER_UID_KEY],
      rating: map[RATING_KEY],
      feedback: map[FEEDBACK_KEY],
      from: map[FROM_KEY] != null ? UserModel.fromJson(map[FROM_KEY]) : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      REVIEWER_UID_KEY: reviewerUid,
      RATING_KEY: rating,
      FEEDBACK_KEY: feedback,
    };
    return map;
  }

  @override
  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{};
    if (reviewerUid != null) map[REVIEWER_UID_KEY] = reviewerUid;
    if (rating != null) map[RATING_KEY] = rating;
    if (feedback != null) map[FEEDBACK_KEY] = feedback;
    return map;
  }
}
