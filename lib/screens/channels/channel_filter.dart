import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/models/channel.dart';
import 'package:tokshop/models/interests.dart';
import 'package:tokshop/models/tokshow.dart';
import 'package:tokshop/screens/room/components/room_card.dart';
import 'package:tokshop/screens/room/components/single_tokshow.dart';
import 'package:tokshop/utils/styles.dart';
import 'package:tokshop/widgets/nothingtoshow_container.dart';
import 'package:tokshop/widgets/product_chime.dart';
import 'package:tokshop/widgets/single_product_item.dart';

import '../../services/end_points.dart';
import '../../utils/text.dart';

class ChannelFilter extends StatelessWidget {
  ChannelFilter({Key? key}) : super(key: key) {
    tokShowController.getActiveTokshows(
        limit: "15", channel: productController.selectedChannel.value!.id!);
    productController.getAllroducts(
        channel: productController.selectedChannel.value!.id!);
    productController.tabController.value!.index = 0;
    productController.channelProducts = productController.interestsProducts;
  }
  final ProductController productController = Get.find<ProductController>();
  final TokShowController tokShowController = Get.find<TokShowController>();
  String title = "";

  @override
  Widget build(BuildContext context) {
    title = productController.selectedChannel.value!.title!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 45,
        elevation: 0,
        title: Text(productController.selectedChannel.value!.title!),
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: const Icon(Icons.clear),
        ),
      ),
      body: Obx(
        () {
          return CustomScrollView(
            slivers: [
              if (productController
                  .selectedChannel.value!.subinterests!.isNotEmpty)
                SliverAppBar(
                  toolbarHeight: 120,
                  automaticallyImplyLeading: false,
                  pinned: true,
                  flexibleSpace: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        margin:
                            const EdgeInsets.only(left: 20, right: 20, top: 10),
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
                            Interests e = productController
                                .selectedChannel.value!.subinterests![i];
                            return Obx(
                              () => InkWell(
                                onTap: () {
                                  productController.selectedInterest.value = e;
                                  if (productController
                                          .tabController.value!.index ==
                                      0) {
                                    productController.getAllroducts(
                                        interest: e.id!);
                                  }
                                  if (productController
                                          .tabController.value!.index ==
                                      1) {
                                    tokShowController.getActiveTokshows(
                                        limit: "15",
                                        channel: productController
                                            .selectedChannel.value!.id!);
                                  }
                                  title = e.title!;
                                  productController.selectedInterest.refresh();
                                },
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: productController
                                                            .selectedInterest
                                                            .value !=
                                                        null &&
                                                    productController
                                                            .selectedInterest
                                                            .value!
                                                            .id ==
                                                        e.id
                                                ? Colors.transparent
                                                : primarycolor),
                                        color:
                                            productController.selectedInterest.value != null &&
                                                    productController
                                                            .selectedInterest
                                                            .value!
                                                            .id ==
                                                        e.id
                                                ? kPrimaryColor
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(20)),
                                    child: Center(
                                        child: Text(
                                      e.title!,
                                      style: TextStyle(
                                          color: productController
                                                          .selectedInterest
                                                          .value !=
                                                      null &&
                                                  productController
                                                          .selectedInterest
                                                          .value!
                                                          .id ==
                                                      e.id
                                              ? Colors.white
                                              : primarycolor),
                                    ))),
                              ),
                            );
                          },
                          itemCount: productController
                              .selectedChannel.value!.subinterests!.length,
                        ),
                      ),
                      const Divider(
                        color: primarycolor,
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            height: 40,
                            child: TabBar(
                              indicator: BoxDecoration(
                                color: primarycolor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              indicatorPadding: EdgeInsets.zero,
                              padding: EdgeInsets.zero,
                              isScrollable: true,
                              controller: productController.tabController.value,
                              labelStyle: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              labelColor: Colors.white,
                              unselectedLabelColor: primarycolor,
                              onTap: (i) {
                                productController.tabController.value!.index =
                                    i;
                                if (i == 0) {
                                  productController.getAllroducts(
                                      channel: productController
                                          .selectedChannel.value!.id!);
                                }
                                if (i == 1) {
                                  tokShowController.getActiveTokshows(
                                      limit: "15",
                                      channel: productController
                                          .selectedChannel.value!.id!);
                                }
                                title =
                                    productController.selectedInterest.value ==
                                            null
                                        ? productController
                                            .selectedChannel.value!.title!
                                        : productController
                                            .selectedInterest.value!.title!;
                                productController.tabController.refresh();
                              },
                              tabs: const [
                                Tab(
                                  child: Text(products_text),
                                ),
                                Tab(
                                  child: Text(shows_text),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  floating: true,
                ),
              if (productController.tabController.value?.index == 0)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Obx(
                        () => productController.loadingproducts.isTrue ||
                                tokShowController.isLoading.isTrue
                            ? GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.68,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.all(8),
                                itemCount: 10,
                                itemBuilder: (context, index) {
                                  return const ProductGridChime();
                                },
                              )
                            : productController.interestsProducts.isEmpty
                                ? NothingToShowContainer(
                                    secondaryMessage: "$no_products ${title}",
                                  )
                                : GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.64,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.all(8),
                                    itemCount: productController
                                        .interestsProducts.length,
                                    itemBuilder: (context, index) {
                                      return SingleproductItem(
                                        imageHeight: 180,
                                        element: productController
                                            .interestsProducts[index],
                                        action: true,
                                      );
                                    },
                                  ),
                      );
                    },
                    childCount: 1, // 1000 list items
                  ),
                ),
              if (productController.tabController.value?.index == 1)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Obx(
                        () => tokShowController.isLoading.isTrue
                            ? const SizedBox(
                                height: 280,
                                child: ProductGridChime(),
                              )
                            : tokShowController.channelRoomsList.isEmpty
                                ? NothingToShowContainer(
                                    secondaryMessage: "$no_Tokshows $title",
                                  )
                                : Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height,
                                      child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: tokShowController
                                              .channelRoomsList.length,
                                          itemBuilder: (context, index) {
                                            Tokshow roomModel =
                                                tokShowController
                                                    .channelRoomsList[index];

                                            var hosts = [];
                                            hosts =
                                                roomModel.hostIds!.length > 10
                                                    ? roomModel.hostIds!
                                                        .sublist(0, 10)
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
          );
        },
      ),
    );
  }
}
