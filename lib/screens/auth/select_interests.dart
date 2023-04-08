import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auth_controller.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/models/interests.dart';
import 'package:tokshop/screens/home/create_room.dart';
import 'package:tokshop/screens/home/home_page.dart';
import 'package:tokshop/screens/home/main_page.dart';

import '../../utils/styles.dart';
import '../../utils/text.dart';

//ignore: must_be_immutable
class SelectInterests extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Function? selectedItemsCallback;
  final showbackarrow;
  SelectInterests(
      {this.title,
      this.subtitle,
      this.selectedItemsCallback,
      this.showbackarrow});

  bool isCallApi = false;
  bool loading = false;

  final AuthController authController = Get.find<AuthController>();
  final ProductController productController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    productController.getCategories();
    return Scaffold(
      resizeToAvoidBottomInset: false, // set
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: ListView(
              children: [
                if (showbackarrow == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Stack(
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(Icons.arrow_back_ios,
                              color: primarycolor),
                        ),
                        const Center(
                          child: Text(
                            intrests,
                            style: TextStyle(fontSize: 25, color: primarycolor),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  intrests_help,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primarycolor),
                ),
                const SizedBox(height: 20),
                Obx(
                  () => ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: productController.categories.length,
                      itemBuilder: (BuildContext context, int i) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${productController.categories[i].title}',
                                style: TextStyle(
                                    fontSize: 15.sp, color: primarycolor)),
                            const SizedBox(height: 10),
                            funListViewData(
                                list: productController
                                    .categories[i].subinterests!,
                                categoryName: productController.categories[i].id
                                    .toString()),
                            const SizedBox(height: 20),
                          ],
                        );
                      }),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                width: 400,
                child: Obx(
                  () => ElevatedButton(
                    style: ButtonStyle(
                      minimumSize:
                          MaterialStateProperty.all<Size>(const Size(300, 50)),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) {
                          if (authController.selectedItemList.isEmpty) {
                            return Colors.grey;
                          }

                          return kPrimaryColor;
                        },
                      ),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(horizontal: 15)),
                      elevation: MaterialStateProperty.all<double>(0.5),
                    ),
                    onPressed: userController.updateInterests.isTrue
                        ? null
                        : () async {
                            userController.updateUserInterests(authController
                                .selectedItemList
                                .map((element) => element.id!)
                                .toList());
                            Get.offAll(() => MainPage());
                          },
                    child: userController.updateInterests.isTrue
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Text(
                            next_text,
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: authController.selectedItemList.isEmpty
                                    ? Colors.white
                                    : Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> listMyWidgets(List<Interests> docs) {
    List<Widget> list = [];

    for (var item in docs) {
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
              boxShadow: const [
                BoxShadow(
                    // color: ccc.getactiveBgColor.value,
                    // blurRadius: 4,
                    ),
              ],
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
          updateUserInterests(item);
        },
      ));
    }
    return list;
  }

  updateUserInterests(Interests item) async {
    bool isAddData = true;
    for (var i = 0; i < authController.selectedItemList.length; i++) {
      if (authController.selectedItemList[i].title == item.title) {
        isAddData = false;
        authController.selectedItemList.removeAt(i);
        break;
      } else {
        isAddData = true;
      }
    }
    if (isAddData) {
      authController.selectedItemList.add(item);
      if (selectedItemsCallback != null) {
        selectedItemsCallback!(authController.selectedItemList);
      }
    }
  }

  Widget funListViewData(
      {required List<Interests> list, required String categoryName}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 650,
        child: Wrap(
          direction: Axis.horizontal,
          children: listMyWidgets(list),
        ),
      ),
    );
  }

  bool getColor(String itemName) {
    bool val = false;
    for (var i = 0; i < authController.selectedItemList.length; i++) {
      if (authController.selectedItemList[i].title == itemName) {
        val = true;
        break;
      } else {
        val = false;
      }
    }

    return val;
  }
}
