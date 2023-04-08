import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/screens/profile/user_profile.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/tokshow.dart';
import '../../services/user_api.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';

class FollowersFollowingPage extends StatelessWidget {
  final String type;
  final UserController _userController = Get.find<UserController>();
  final AuthController authController = Get.find<AuthController>();

  FollowersFollowingPage(this.type, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.clear,
            color: primarycolor,
            size: 25,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          type,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Obx(() {
          return _userController.gettingFollowers.isFalse
              ? _userController.userFollowersFollowing.isNotEmpty
                  ? ListView.builder(
                      itemCount: _userController.userFollowersFollowing.length,
                      itemBuilder: (context, index) {
                        OwnerId user = OwnerId.fromJson(_userController
                            .userFollowersFollowing
                            .elementAt(index));
                        return InkWell(
                          onTap: () {
                            _userController.getUserProfile(user.id!);
                            Get.to(UserProfile());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    user.profilePhoto == "" ||
                                            user.profilePhoto == null
                                        ? const CircleAvatar(
                                            radius: 20,
                                            backgroundImage: AssetImage(
                                                "assets/icons/profile_placeholder.png"),
                                          )
                                        : CircleAvatar(
                                            radius: 20,
                                            backgroundImage: NetworkImage(
                                                user.profilePhoto!),
                                          ),
                                    SizedBox(
                                      width: 0.03.sw,
                                    ),
                                    Text(
                                      "${user.firstName} ${user.lastName}"
                                                  .length >
                                              30
                                          ? "${"${user.firstName} ${user.lastName}".substring(0, 30)}..."
                                          : "${user.firstName} ${user.lastName}",
                                      style: TextStyle(
                                          color: primarycolor, fontSize: 14.sp),
                                    ),
                                  ],
                                ),
                                if (user.id !=
                                    FirebaseAuth.instance.currentUser!.uid)
                                  InkWell(
                                    onTap: () async {
                                      if (user.followers!.contains(FirebaseAuth
                                          .instance.currentUser!.uid)) {
                                        await unFollowUser(index, user);
                                      } else {
                                        await followUser(index, user);
                                      }
                                    },
                                    child: Container(
                                      width: 0.25.sw,
                                      height: 0.034.sh,
                                      decoration: BoxDecoration(
                                          color: user.followers!.contains(
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid)
                                              ? kPrimaryColor
                                              : Colors.transparent,
                                          border: Border.all(
                                              color: user.followers!.contains(
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid)
                                                  ? kPrimaryColor
                                                  : primarycolor),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Center(
                                        child: Text(
                                          user.followers!.indexWhere(
                                                      (element) =>
                                                          element ==
                                                          FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid) !=
                                                  -1
                                              ? following
                                              : follow,
                                          style: TextStyle(
                                              color: user.followers!.indexWhere(
                                                          (element) =>
                                                              element ==
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid) !=
                                                      -1
                                                  ? Colors.white
                                                  : primarycolor,
                                              fontSize: 12.sp),
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        );
                      })
                  : SizedBox(
                      height: 0.5.sh,
                      child: Center(
                        child: Text(
                          type == "Following"
                              ? you_are_not_following
                              :you_have_no_followers,
                          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                        ),
                      ),
                    )
              : SizedBox(
                  height: 0.5.sh,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: primarycolor,
                    ),
                  ));
        }),
      ),
    );
  }

  Future<void> followUser(int index, OwnerId user) async {
    _userController.userFollowersFollowing
        .elementAt(index)["followers"]
        .add(FirebaseAuth.instance.currentUser!.uid);
    _userController.userFollowersFollowing.refresh();

    if (FirebaseAuth.instance.currentUser!.uid ==
        _userController.currentProfile.value.id) {
      _userController.currentProfile.value.followingCount =
          _userController.currentProfile.value.followingCount! + 1;
      _userController.currentProfile.refresh();
    }
    await UserAPI()
        .followAUser(FirebaseAuth.instance.currentUser!.uid, user.id!);
  }

  Future<void> unFollowUser(int index, OwnerId user) async {
    _userController.userFollowersFollowing
        .elementAt(index)["followers"]
        .remove(FirebaseAuth.instance.currentUser!.uid);

    if (FirebaseAuth.instance.currentUser!.uid ==
        _userController.currentProfile.value.id) {
      _userController.currentProfile.value.followingCount =
          _userController.currentProfile.value.followingCount! - 1;
      _userController.currentProfile.refresh();
    }
    _userController.userFollowersFollowing.refresh();
    await UserAPI()
        .unFollowAUser(FirebaseAuth.instance.currentUser!.uid, user.id!);
  }
}
