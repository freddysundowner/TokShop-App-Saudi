import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/models/channel.dart';
import 'package:tokshop/models/tokshow.dart';
import 'package:tokshop/screens/home/create_room.dart';
import 'package:tokshop/screens/room/components/room_card.dart';
import 'package:tokshop/utils/styles.dart';
import 'package:tokshop/utils/text.dart';
import 'package:tokshop/widgets/nothingtoshow_container.dart';
import 'package:tokshop/widgets/product_chime.dart';

class AllTokShows extends StatelessWidget {
  String? userid;
  List<Channel>? channels = [];
  AllTokShows({Key? key, this.userid, this.channels}) : super(key: key) {
    _homeController.getActiveTokshows(
        limit: "15",
        userid: userid != null ? userid! : "",
        channel: channels != null && channels!.isNotEmpty
            ? channels!.first.id!
            : "");
    productController.selectedChannel.value = channels!.first;
  }

  final TokShowController _homeController = Get.find<TokShowController>();
  final ProductController productController = Get.find<ProductController>();
  @override
  Widget build(BuildContext context) {
    channels = productController.categories;
    return Scaffold(
      appBar: AppBar(
        title: const Text(live_tokshows),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            toolbarHeight: 40,
            automaticallyImplyLeading: false,
            pinned: true,
            flexibleSpace: Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: ListView.separated(
                separatorBuilder: (context, i) {
                  return Container(
                    width: 10,
                  );
                },
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, i) {
                  Channel e = channels![i];
                  return Obx(
                    () => InkWell(
                      onTap: () {
                        productController.selectedChannel.value = e;
                        _homeController.getActiveTokshows(
                          limit: "15",
                          channel: e.id!,
                          userid: userid != null ? userid! : "",
                        );
                        if (userid != null) {
                          _homeController.channelRoomsList =
                              _homeController.userRoomsList;
                        }
                        productController.selectedChannel.refresh();
                      },
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      productController.selectedChannel.value !=
                                                  null &&
                                              productController.selectedChannel
                                                      .value!.id ==
                                                  e.id
                                          ? Colors.transparent
                                          : primarycolor),
                              color: productController.selectedChannel.value !=
                                          null &&
                                      productController
                                              .selectedChannel.value!.id ==
                                          e.id
                                  ? kPrimaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                              child: Text(
                            e.title!,
                            style: TextStyle(
                                color:
                                    productController.selectedChannel.value !=
                                                null &&
                                            productController.selectedChannel
                                                    .value!.id ==
                                                e.id
                                        ? Colors.white
                                        : primarycolor),
                          ))),
                    ),
                  );
                },
                itemCount: channels!.length,
              ),
            ),
            floating: true,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Obx(
                  () => _homeController.isLoading.isTrue
                      ? const SizedBox(
                          height: 280,
                          child: ProductGridChime(),
                        )
                      : _homeController.channelRoomsList.isEmpty
                          ? NothingToShowContainer(
                              primaryMessage:
                                  "$no_Live_tokshows ${productController.selectedChannel.value != null ? "in ${productController.selectedChannel.value!.title}" : ""}",
                              iconPath: "assets/icons/mic.png",
                              widget: InkWell(
                                onTap: () {
                                  homeController.createRoomView();
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(Get.context!).size.width *
                                          0.40,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 13, vertical: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      Text(
                                       go_live_now,
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          : Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount:
                                        _homeController.channelRoomsList.length,
                                    itemBuilder: (context, index) {
                                      Tokshow roomModel = _homeController
                                          .channelRoomsList[index];

                                      var hosts = [];
                                      hosts = roomModel.hostIds!.length > 10
                                          ? roomModel.hostIds!.sublist(0, 10)
                                          : roomModel.hostIds!;
                                      return RoomCard(
                                          roomModel: roomModel,
                                          hosts: hosts,
                                          showChannel: false);
                                    }),
                              ),
                            ),
                );
              },
              childCount: 1, // 1000 list items
            ),
          ),
        ],
      ),
    );
  }
}
