import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/models/channel.dart';
import 'package:tokshop/screens/home/search_channels.dart';
import 'package:tokshop/screens/profile/user_profile.dart';
import 'package:tokshop/screens/room/components/room_card.dart';
import 'package:tokshop/widgets/follow_button.dart';
import 'package:tokshop/widgets/nothingtoshow_container.dart';
import 'package:tokshop/widgets/product_chime.dart';
import 'package:tokshop/widgets/single_product_item.dart';

import '../../controllers/global.dart';
import '../../controllers/user_controller.dart';
import '../../models/tokshow.dart';
import '../../models/user.dart';
import '../../services/user_api.dart';
import '../../utils/text.dart';
import '../../utils/utils.dart';

class SearchResults extends StatelessWidget {
  final UserController _userController = Get.find<UserController>();
  final GlobalController _globalController = Get.find<GlobalController>();
  final ProductController productController = Get.find<ProductController>();

  SearchResults({Key? key}) : super(key: key);

  Future<void> refreshPage() {
    return Future<void>.value();
  }

  final List<String> searchOptions = [
    channels,
    people,
    products_text,
    tokShows
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          decoration: BoxDecoration(
              color: Styles.textButton.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                scrollPadding: const EdgeInsets.all(0),
                textInputAction: TextInputAction.done,
                maxLines: 1,
                minLines: 1,
                autofocus: false,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  suffixIcon: IconButton(
                    iconSize: 25,
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      _globalController.searchPageNumber.value = 0;
                      if (_globalController
                          .searchShopController.text.isNotEmpty) {
                        _globalController.searchPageNumber.value = 0;
                        _globalController.searchPageNumber.refresh();
                        _globalController.searchresults.value = [];
                        _search(_globalController.currentsearchtab.value);
                      }
                    },
                  ),
                  hintText: "$discover_everything...",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.sp,
                  ),
                  border: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                controller: _globalController.searchShopController,
                onChanged: (c) {
                  if (c.isEmpty) {
                    _globalController.searchPageNumber.value = 0;
                    _globalController.searchresults.value = [];
                    _globalController.searchShopController.text = "";
                    _search(_globalController.currentsearchtab.value);
                  }
                },
              ),
            ],
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13.0),
        child: Column(
          children: [
            Obx(() {
              return Column(
                children: [
                  if (_globalController.isSearching.isTrue)
                    Transform.scale(
                        scale: 0.3,
                        child: const CircularProgressIndicator(
                          color: primarycolor,
                        )),
                  const SizedBox(height: 20.0),
                  _searchTabs(),
                ],
              );
            }),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                child: Obx(() {
                  if (_globalController.isSearching.isTrue) {
                    return const ListViewChime();
                  }
                  if (_globalController.currentsearchtab.value == 2 &&
                      productController.allproducts.isNotEmpty) {
                    return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 15,
                        ),
                        itemCount: productController.allproducts.length,
                        controller: productController.scrollControllerCustom(),
                        itemBuilder: (context, index) {
                          return SingleproductItem(
                            element: productController.allproducts[index],
                            imageHeight: 180,
                          );
                        });
                  }
                  if (_globalController.currentsearchtab.value == 0) {
                    return SearchChannels(
                        text: _globalController.searchShopController.text);
                  }

                  if (_globalController.searchresults.isEmpty &&
                      _globalController.searchShopController.text.isNotEmpty &&
                      _globalController.isSearching.isFalse) {
                    return const NothingToShowContainer(
                      primaryMessage: no_search_results,
                    );
                  }

                  if (_globalController.currentsearchtab.value == 3 &&
                      _globalController.searchresults.isEmpty) {
                    return const NothingToShowContainer(
                      primaryMessage: no_search_results,
                    );
                  }

                  if (_globalController.searchresults.isNotEmpty) {
                    return ListView.builder(
                      controller: _globalController.scrollcontroller,
                      itemBuilder: (_, i) {
                        var e = _globalController.searchresults.elementAt(i);

                        if (_globalController.currentsearchtab.value == 0) {
                          if (e["title"] != null) {
                            return SearchChannels()
                                .singleChannel(Channel.fromJson(e));
                          }
                        }
                        if (_globalController.currentsearchtab.value == 1) {
                          if (e["firstName"] != null) {
                            if (e["shopId"] is List) {
                              e["shopId"] =
                                  e["shopId"] == null || e["shopId"].isEmpty
                                      ? null
                                      : e["shopId"].elementAt(0);
                            }
                            return _singleItemUser(UserModel.fromJson(e), i);
                          }
                        }
                        if (_globalController.currentsearchtab.value == 2) {}
                        if (_globalController.currentsearchtab.value == 3) {
                          return _singleItemRoom(Tokshow.fromJson(e));
                        }
                        return Container();
                      },
                      itemCount: _globalController.searchresults.length,
                    );
                  }
                  return Container();
                }),
              ),
            ),
          ],
        ),
      ),
      //body: Body(),
    );
  }

  InkWell _singleItemUser(UserModel e, int index) {
    return InkWell(
      onTap: () {
        _userController.getUserProfile(e.id!);
        Get.to(() => UserProfile());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  e.profilePhoto != null && e.profilePhoto != ""
                      ? CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(e.profilePhoto!),
                        )
                      : const CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage(
                              "assets/icons/profile_placeholder.png"),
                        ),
                  SizedBox(
                    width: 0.02.sw,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 0.4.sw,
                        child: Text(
                          "${e.firstName!} ${e.lastName!}",
                          style: TextStyle(
                              color: primarycolor,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            following,
                            style:
                                TextStyle(color: primarycolor, fontSize: 11.sp),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            e.following.length.toString(),
                            style: TextStyle(
                                color: kPrimaryColor, fontSize: 11.sp),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            followers,
                            style:
                                TextStyle(color: primarycolor, fontSize: 11.sp),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            e.followers.length.toString(),
                            style: TextStyle(
                                color: kPrimaryColor, fontSize: 11.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (e.id != FirebaseAuth.instance.currentUser!.uid)
                    Obx(
                      () => _userController.userFollowingIndex.value ==
                              index + 1
                          ? Transform.scale(
                              scale: 0.3,
                              child: const CircularProgressIndicator(
                                color: primarycolor,
                              ))
                          : FollowUnfollowButton(
                              height: 30,
                              callBack: () async {
                                _userController.userFollowingIndex.value =
                                    index + 1;
                                print(e.followers.indexWhere((element) =>
                                    element.id ==
                                    FirebaseAuth.instance.currentUser!.uid));
                                if (e.followers.indexWhere((element) =>
                                        element.id ==
                                        FirebaseAuth
                                            .instance.currentUser!.uid) !=
                                    -1) {
                                  e.followers.removeWhere((element) =>
                                      element.id ==
                                      FirebaseAuth.instance.currentUser!.uid);
                                  await UserAPI().unFollowAUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      e.id!);
                                } else {
                                  e.followers
                                      .add(authController.usermodel.value!);
                                  await UserAPI().followAUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      e.id!);
                                }
                                _userController.userFollowingIndex.value = 0;
                              },
                              enabled: e.followers.indexWhere((element) =>
                                      element.id ==
                                      FirebaseAuth.instance.currentUser!.uid) ==
                                  -1,
                            ),
                    ),
                ],
              ),
              const Divider()
            ],
          ),
        ),
      ),
    );
  }

  _singleItemRoom(Tokshow e) {
    var hosts = [];
    hosts = e.hostIds!.length > 10 ? e.hostIds!.sublist(0, 10) : e.hostIds!;
    return RoomCard(roomModel: e, hosts: hosts, showChannel: false);
  }

  _search(int index) async {
    if (index == 2) {
      productController.searchPageNumber.value = 1;
      _globalController.searchresults.refresh();
      _globalController.currentsearchtab.value = index;
      _globalController.isSearching.value = true;
      productController.searchText.text =
          _globalController.searchShopController.text.trim();
      await productController.getAllroducts(
          title: _globalController.searchShopController.text.trim().toString(),
          featured: false,
          page: productController.searchPageNumber.value.toString());
      _globalController.isSearching.value = false;
    } else if (index == 0) {
      _globalController.currentsearchtab.value = index;
      // channelController
      //     .searchChannel(_globalController.searchShopController.text.trim());
      _globalController.currentsearchtab.refresh();
      channelController.allchannels.refresh();
    } else {
      _globalController.searchresults.value = [];
      _globalController.searchresults.refresh();
      _globalController.currentsearchtab.value = index;
      _globalController.searchoption.value = searchOptions[index].toLowerCase();
      _globalController.searchPageNumber.value = 1;
      _globalController.search();
    }
  }

  _searchTabs() {
    return Row(
        children: List.generate(
            searchOptions.length,
            (index) => Obx(
                  () => InkWell(
                    onTap: () {
                      _search(index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      margin: EdgeInsets.only(
                          right: index == searchOptions.length ? 0 : 10),
                      decoration:
                          _globalController.currentsearchtab.value == index
                              ? BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(25.0))
                              : null,
                      child: Text(
                        searchOptions[index],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _globalController.currentsearchtab.value ==
                                    index
                                ? Colors.white
                                : primarycolor,
                            fontSize: 11.sp),
                      ),
                    ),
                  ),
                )));
  }
}
