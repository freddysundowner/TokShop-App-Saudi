import 'dart:io';

import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/global.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/models/channel.dart';
import 'package:tokshop/models/interests.dart';
import 'package:tokshop/utils/functions.dart';
import 'package:tokshop/utils/styles.dart';
import 'package:tokshop/widgets/single_product_item.dart';
import 'package:tokshop/widgets/text_form_field.dart';

import '../../utils/text.dart';

class MarketPlaceProducts extends StatelessWidget {
  List<Channel>? channels = [];
  String? userid;

  MarketPlaceProducts({Key? key, this.channels, this.userid})
      : super(key: key) {}
  final ProductController productController = Get.find<ProductController>();
  final GlobalController globalController = Get.find<GlobalController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (productController.searchEnabled.isFalse)
                const Text(market_place),
              if (productController.searchEnabled.isTrue)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: CustomTextFormField(
                      hint: search_by_name,
                      onChanged: (String c) async {
                        globalController.searchShopController.text = c;
                        if (c.isNotEmpty) {
                          productController.loadingproducts.value = true;
                          globalController.searchPageNumber.value = 1;

                          productController.searchText.text = c.trim();
                          await productController.getAllroducts(
                              title: c.trim().toString(),
                              featured: false,
                              page: "1");
                          productController.loadingproducts.value = false;
                        } else {
                          await productController.getAllroducts(page: "1");
                        }
                      },
                    ),
                  ),
                ),
              if (productController.searchEnabled.isFalse)
                InkWell(
                  child: const Icon(Icons.search_rounded),
                  onTap: () {
                    productController.searchEnabled.value =
                        !productController.searchEnabled.value;
                  },
                ),
              if (productController.searchEnabled.isTrue)
                InkWell(
                  child: const Icon(Icons.clear),
                  onTap: () {
                    if (globalController.searchShopController.text.isNotEmpty) {
                      globalController.searchShopController.clear();
                      productController.getAllroducts(page: "1");
                    }
                    productController.searchEnabled.value =
                        !productController.searchEnabled.value;
                  },
                )
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          Obx(
                () => SliverAppBar(
              toolbarHeight: productController.selectedChannel.value == null ||
                  productController
                      .selectedChannel.value!.subinterests!.isEmpty
                  ? 80
                  : 120,
              automaticallyImplyLeading: false,
              pinned: true,
              flexibleSpace: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 30,
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: Row(
                      children: [
                        Obx(
                              () => InkWell(
                            onTap: () {
                              productController.getAllroducts();

                              productController.selectedChannel.value = null;
                              productController.selectedInterest.value = null;
                              productController.selectedChannel.refresh();
                              productController.selectedInterest.refresh();
                            },
                            child: Container(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: productController.selectedChannel
                                            .value ==
                                            null &&
                                            productController
                                                .selectedInterest
                                                .value ==
                                                null
                                            ? Colors.transparent
                                            : primarycolor),
                                    color: productController
                                        .selectedChannel.value ==
                                        null &&
                                        productController
                                            .selectedInterest.value ==
                                            null
                                        ? kPrimaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Center(
                                    child: Text(
                                      all,
                                      style: TextStyle(
                                          color: productController
                                              .selectedChannel.value ==
                                              null &&
                                              productController
                                                  .selectedInterest.value ==
                                                  null
                                              ? Colors.white
                                              : primarycolor),
                                    ))),
                          ),
                        ),
                        Expanded(
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
                                    productController.allproducts
                                        .clear();
                                    productController.selectedChannel.value = e;
                                    if (productController
                                        .tabController.value!.index ==
                                        0) {
                                      productController.getAllroducts(
                                          channel: e.id!);
                                    }
                                    productController.allproducts =
                                        productController.channelProducts;

                                    productController.selectedInterest.value =
                                    null;
                                    productController.selectedChannel.refresh();
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: productController
                                                  .selectedChannel
                                                  .value !=
                                                  null &&
                                                  productController
                                                      .selectedChannel
                                                      .value!
                                                      .id ==
                                                      e.id
                                                  ? Colors.transparent
                                                  : primarycolor),
                                          color:
                                          productController.selectedChannel.value != null &&
                                              productController
                                                  .selectedChannel
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
                                                    .selectedChannel
                                                    .value !=
                                                    null &&
                                                    productController
                                                        .selectedChannel
                                                        .value!
                                                        .id ==
                                                        e.id
                                                    ? Colors.white
                                                    : primarycolor),
                                          ))),
                                ),
                              );
                            },
                            itemCount: channels!.length,
                          ),
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    color: primarycolor,
                  ),
                  Obx(
                        () => productController.selectedChannel.value == null ||
                        productController
                            .selectedChannel.value!.subinterests!.isEmpty
                        ? Container()
                        : Container(
                      height: 30,
                      margin: const EdgeInsets.only(
                          left: 20, right: 20, top: 10),
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
                                productController.allproducts
                                    .clear();
                                productController.selectedInterest.value =
                                    e;
                                if (productController
                                    .tabController.value!.index ==
                                    0) {
                                  productController.getAllroducts(
                                      interest: e.id!);
                                }
                                productController.allproducts =
                                    productController.interestsProducts;

                                productController.selectedInterest
                                    .refresh();
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
                  ),
                ],
              ),
              floating: true,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return FadedScaleAnimation(
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Obx(() => RefreshIndicator(
                          onRefresh: () {
                            return productController.getAllroducts(page: "1");
                          },
                          child: productController.loadingproducts.isTrue
                              ? const Center(
                            child: CircularProgressIndicator(),
                          )
                              : productController.allproducts.isNotEmpty
                              ? Container(
                            margin: const EdgeInsets.only(bottom: 200),
                            child: GridView.builder(
                                gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: Platform.isAndroid ? 0.58 : 0.65,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 15,
                                ),
                                itemCount: productController
                                    .allproducts.length,
                                controller: productController
                                    .scrollControllerCustom(),
                                itemBuilder: (context, index) {
                                  return SingleproductItem(
                                    element: productController
                                        .allproducts[index],
                                    imageHeight: 180,
                                  );
                                }),
                          )
                              : ListView(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: Text(
                                  have_no_products_yet,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13.sp),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  addProduct(context);
                                },
                                child: Container(
                                  width: MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.40,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 13, vertical: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add,
                                        size: 20,
                                      ),
                                      Text(
                                        add,
                                        style: TextStyle(
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize: 11.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ))),
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
