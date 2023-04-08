import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:share/share.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/models/recording.dart';
import 'package:tokshop/screens/menu/address_details_form.dart';
import 'package:tokshop/screens/payments/payout_settings.dart';
import 'package:tokshop/screens/channels/channels_list.dart';
import 'package:tokshop/services/dynamic_link_services.dart';
import 'package:tokshop/utils/text.dart';
import 'package:tokshop/widgets/bottom_sheet_dialog.dart';
import 'package:tokshop/widgets/default_button.dart';
import 'package:tokshop/widgets/single_product_item.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../controllers/channel_controller.dart';
import '../models/channel.dart';
import '../models/product.dart';
import '../screens/home/create_room.dart';
import '../screens/products/edit_product/edit_product_screen.dart';
import '../screens/payments/add_card.dart';
import 'utils.dart';
import 'package:intl/intl.dart';

import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

printOut(data) {
  if (kDebugMode) {
    print(data);
  }
}

Widget buildInterestField() {
  return SelectDropList(
      dropList: productController.subcategories,
      onOptionSelected: (optionItem) =>
          {productController.pickedProductCategories.add(optionItem)});
}

getFormattedCurrent(double number, {int decimal = 1}) {
  var shortForm = "";
  if (number < 1000000) {
    shortForm = number.toStringAsFixed(0);
  }
  if (number >= 1000000 && number < 1000000000) {
    shortForm = "${(number / 1000000).toStringAsFixed(decimal)}M";
  }
  return shortForm;
}

void addProduct(BuildContext context) {
  final AuthController authController = Get.find<AuthController>();
  if (authController.currentuser!.shopId!.open == true) {
    if (authController.usermodel.value!.payoutMethod != null) {
      Get.to(() => const EditProductScreen());
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(set_up_payout_menu_set),
            content: const Text(how_you_want_to_be_paid_first),
            actions: [
              TextButton(
                child: const Text(setup),
                onPressed: () async {
                  Navigator.pop(context, false);
                  Get.to(() => PayoutSettings());
                },
              ),
              TextButton(
                child: const Text(not_now),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
            ],
          );
        },
      );
    }
  } else {
    Get.defaultDialog(
        title: shop_is_closed, middleText: you_cant_add_a_product);
  }
}

purchaseInfo() {
  showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      backgroundColor: const Color(0Xfff4f5fa),
      context: Get.context!,
      isScrollControlled: true,
      builder: (context) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    payment_info,
                    style: TextStyle(
                        color: primarycolor,
                        fontSize: 21.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(information_make_purchase_tokshop,
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                  SizedBox(
                    height: 20,
                  ),
                  if (Get.find<AuthController>()
                          .usermodel
                          .value!
                          .defaultpaymentmethod ==
                      null)
                    InkWell(
                      onTap: () {
                        showFilterBottomSheet(
                            context,
                            Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        InkWell(
                                          child: const Icon(Icons.clear),
                                          onTap: () {
                                            Get.back();
                                          },
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        const Text(
                                          add_payment_method,
                                          style: TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        Get.back();
                                        Get.to(() => AddCard(from: "roompage"));
                                      },
                                      child: Row(
                                        children: const [
                                          Icon(Icons.credit_card),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            credit_or_debit_card,
                                            style: TextStyle(fontSize: 21),
                                          ),
                                          Spacer(),
                                          Icon(Icons.arrow_forward_ios_rounded),
                                        ],
                                      ),
                                    )
                                  ],
                                )));
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Center(
                              child: Text(
                                payment_method,
                                style: TextStyle(
                                    color: primarycolor, fontSize: 14.sp),
                              ),
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_forward_ios_rounded)
                        ],
                      ),
                    ),
                  if (Get.find<AuthController>()
                          .usermodel
                          .value
                          ?.defaultpaymentmethod !=
                      null)
                    Row(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Ionicons.card,
                              color: Colors.blue,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              children: [
                                Text(
                                  Get.find<AuthController>()
                                      .usermodel
                                      .value!
                                      .defaultpaymentmethod!
                                      .name!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp),
                                ),
                                Text(
                                    Get.find<AuthController>()
                                        .usermodel
                                        .value!
                                        .defaultpaymentmethod!
                                        .last4!,
                                    style: TextStyle(
                                        fontSize: 13.sp, color: primarycolor)),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  Divider(),
                  Obx(() => Get.find<AuthController>()
                              .usermodel
                              .value!
                              .address !=
                          null
                      ? Container()
                      : InkWell(
                          onTap: () {
                            Get.to(() => AddressDetailsForm(
                                  showsave: true,
                                ));
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: Center(
                                  child: Text(
                                    shipping_method,
                                    style: TextStyle(
                                        color: primarycolor, fontSize: 14.sp),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_forward_ios_rounded)
                            ],
                          ),
                        )),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ));
}

Future<void> shareRecording(Recording recordModel) async {
  Get.defaultDialog(
      contentPadding: const EdgeInsets.all(10),
      content: const CircularProgressIndicator(),
      barrierDismissible: false);
  DynamicLinkService()
      .generateShareLink(recordModel.id,
          type: "recording",
          title: "Join ${recordModel.roomId!.title} TokShow Recorded")
      .then((value) async {
    await Share.share(value);
  }).then((value) => Get.back());
}

getShortForm(double number, {int decimal = 1}) {
  var shortForm = "";
  if (number != null) {
    if (number < 1000) {
      shortForm = number.toStringAsFixed(decimal);
    } else if (number >= 1000 && number < 1000000) {
      shortForm = "${(number / 1000).toStringAsFixed(decimal)}K";
    } else if (number >= 1000000 && number < 1000000000) {
      shortForm = "${(number / 1000000).toStringAsFixed(decimal)}M";
    } else if (number >= 1000000000 && number < 1000000000000) {
      shortForm = "${(number / 1000000000).toStringAsFixed(decimal)}B";
    }
  }
  return shortForm;
}

String convertTime(String time) {
  var convertedTime = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
  var timeDifference =
      "${convertedTime.day}/${convertedTime.month}/${convertedTime.year}";

  var diff = DateTime.now().difference(convertedTime);

  if (diff.inMinutes < 1) {
    timeDifference = "now";
  } else if (diff.inHours < 1) {
    timeDifference = "${diff.inMinutes} minutes ago";
  } else if (diff.inHours <= 24) {
    timeDifference = "${diff.inHours} hours ago";
  } else if (diff.inHours <= 47) {
    timeDifference = "${diff.inDays} day ago";
  }
  final f = DateFormat('dd MMM, yyyy hh:mm');

  return f.format(DateTime.fromMillisecondsSinceEpoch(
      convertedTime.millisecondsSinceEpoch));
}

String showActualTime(String time) {
  var convertedTime = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
  var hour = convertedTime.hour.toString().length == 2
      ? convertedTime.hour
      : "0${convertedTime.hour}";
  var minute = convertedTime.minute.toString().length == 2
      ? convertedTime.minute
      : "0${convertedTime.minute}";

  var timeDifference = "$hour:$minute  "
      "${convertedTime.day}/${convertedTime.month}/${convertedTime.year}";

  return timeDifference;
}

Future<dynamic> showProductBottomSheet(BuildContext context,
    {Function? callback}) async {
  return showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    isDismissible: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(15),
      topRight: Radius.circular(15),
    )),
    builder: (context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return DraggableScrollableSheet(
            initialChildSize: 0.7,
            expand: false,
            builder: (BuildContext productContext,
                ScrollController scrollController) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      height: 0.01.sh,
                      width: 0.15.sw,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: kPrimaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 0.02.sh,
                    ),
                    Text(
                      tag_products,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(
                      height: 0.05.sh,
                    ),
                    Expanded(
                      child: Obx(() {
                        return productController.userProductsLoading.isFalse
                            ? productController.allproducts.isNotEmpty
                                ? GridView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 0.60,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemCount:
                                        productController.allproducts.length,
                                    itemBuilder: (context, index) {
                                      Product product = productController
                                          .allproducts
                                          .elementAt(index);
                                      int i = homeController.roomPickedProduct
                                          .indexWhere((element) =>
                                              element.id == product.id);
                                      return Stack(
                                        children: [
                                          SingleproductItem(
                                            element: product,
                                            action: false,
                                            callBack: callback != null
                                                ? () {
                                                    callback(product);
                                                  }
                                                : () {
                                                    if (i == -1) {
                                                      homeController
                                                          .roomPickedProduct
                                                          .add(product);
                                                    }
                                                    setState(() {});
                                                  },
                                            imageHeight: 70,
                                          ),
                                          if (i != -1)
                                            InkWell(
                                              child: Center(
                                                child: Container(
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  child: const Icon(
                                                    Icons.check_circle,
                                                    size: 45,
                                                    color: kPrimaryColor,
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                homeController.roomPickedProduct
                                                    .removeAt(i);
                                                setState(() {});
                                              },
                                            ),
                                        ],
                                      );
                                    })
                                : Column(
                                    children: [
                                      Text(
                                        have_no_products_yet,
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.grey),
                                      ),
                                      const SizedBox(
                                        height: 40,
                                      ),
                                      Center(
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            CupertinoIcons.add_circled_solid,
                                            size: 50,
                                          ),
                                          onPressed: () {
                                            Get.to(() =>
                                                const EditProductScreen());
                                          },
                                        ),
                                      )
                                    ],
                                  )
                            : const Center(
                                child: CircularProgressIndicator(
                                  color: primarycolor,
                                ),
                              );
                      }),
                    ),
                    if (homeController.roomPickedProduct.isNotEmpty)
                      DefaultButton(
                        text:
                            "Done (${homeController.roomPickedProduct.length})",
                        press: () {
                          Get.back();
                        },
                        color: kPrimaryColor,
                        txtcolor: Colors.white,
                      )
                  ],
                ),
              );
            });
      });
    },
  );
}

date(date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = DateTime(now.year, now.month, now.day + 1);

  final dateToCheck = DateTime.fromMillisecondsSinceEpoch(date);
  final aDate = DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day,
      dateToCheck.hour, dateToCheck.minute);
  final aDatee = DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
  var formatter = DateFormat('hh:mm a');
  String when = "";
  if (aDatee == today) {
    when = "Today, ${formatter.format(dateToCheck).toString()}";
  } else if (aDatee == tomorrow) {
    when = "Tomorrow, ${formatter.format(dateToCheck).toString()}";
  } else {
    var formatter = DateFormat('MMMM dd, yyyy, hh:mm a');

    String checkInTimeIsoString = formatter.format(aDate).toString();

    when = checkInTimeIsoString;
  }
  return when;
}

Future<dynamic> showChooseChannelBottomSheet(BuildContext context) async {
  ChannelController channelController =
      Get.put<ChannelController>(ChannelController());
  return showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: Colors.grey[200],
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
      topLeft: Radius.circular(15),
      topRight: Radius.circular(15),
    )),
    builder: (context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return DraggableScrollableSheet(
            initialChildSize: 0.5,
            expand: false,
            builder: (BuildContext productContext,
                ScrollController scrollController) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 0.01.sh,
                      width: 0.15.sw,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    SizedBox(
                      height: 0.02.sh,
                    ),
                    Text(
                      choose_channel,
                      style: TextStyle(
                          color: primarycolor,
                          fontSize: 21.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 0.01.sh,
                    ),
                    Obx(() {
                      return channelController.channelLoading.isFalse
                          ? Wrap(
                              direction: Axis.horizontal,
                              children: listMyWidgets(
                                  Get.find<ChannelController>().allchannels,
                                  setState),
                            )
                          : SizedBox(
                              height: 0.2.sh,
                              child: const Center(
                                  child: CircularProgressIndicator(
                                color: primarycolor,
                              )));
                    }),
                    const Spacer(),
                    if (homeController.roomPickedChannel.isNotEmpty)
                      DefaultButton(
                        text:
                            "Done (${homeController.roomPickedChannel.length})",
                        press: () {
                          Get.back();
                        },
                        color: kPrimaryColor,
                        txtcolor: Colors.white,
                      )
                  ],
                ),
              );
            });
      });
    },
  );
}

showSnackBack(BuildContext context, String message,
    {MaterialColor? color = Colors.green}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: kPrimaryColor,
    ),
  );
}

launchURL(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    const GetSnackBar(
      message: could_not_open_the_social_link,
      duration: Duration(seconds: 2),
    ).show();
  }
}

List<Widget> listMyWidgets(items, StateSetter setState) {
  List<Widget> list = [];

  for (var item in items) {
    list.add(GestureDetector(
      child: Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          decoration: BoxDecoration(
            color: getColor(item.title!) ? kPrimaryColor : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
                color: getColor(item.title!) ? kPrimaryColor : primarycolor),
            boxShadow: getColor(item.title!)
                ? [
                    const BoxShadow(
                      color: primarycolor,
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Text(
            item.title!,
            style: TextStyle(
                fontSize: 15,
                color: getColor(item.title!) ? Colors.white : Colors.black),
          ),
        ),
      ),
      onTap: () {
        int i = homeController.roomPickedChannel
            .indexWhere((element) => element.id == item.id);
        if (i == -1) {
          homeController.roomPickedChannel.add(item);
        } else {
          homeController.roomPickedChannel.removeAt(i);
        }
        setState(() => {});
      },
    ));
  }
  return list;
}

bool getColor(String itemName) {
  bool val = false;
  for (var i = 0; i < homeController.roomPickedChannel.length; i++) {
    if (homeController.roomPickedChannel[i].title == itemName) {
      val = true;
      break;
    } else {
      val = false;
    }
  }

  return val;
}
