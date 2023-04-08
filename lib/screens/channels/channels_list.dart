//ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/models/channel.dart';
import 'package:tokshop/models/interests.dart';
import 'package:tokshop/utils/styles.dart';

import '../../utils/text.dart';

class SelectDropList extends StatefulWidget {
  List? dropList;
  Function(Interests optionItem)? onOptionSelected;

  SelectDropList({Key? key, this.dropList, this.onOptionSelected})
      : super(key: key);

  @override
  SelectDropListState createState() => SelectDropListState();
}

class SelectDropListState extends State<SelectDropList>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;
  ProductController productController = Get.find<ProductController>();

  @override
  void initState() {
    super.initState();
    expandController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
    _runExpandCheck();
  }

  void _runExpandCheck() {
    if (productController.showingCategories.value) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
          decoration: BoxDecoration(
            color: primarycolor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Obx(() {
            return GestureDetector(
                onTap: () {
                  productController.showingCategories.value =
                      !productController.showingCategories.value;
                  _runExpandCheck();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    productController.pickedProductCategories.isNotEmpty
                        ? Expanded(
                            child: Wrap(
                              children: productController
                                  .pickedProductCategories
                                  .map((element) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      productController.pickedProductCategories
                                          .remove(element);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: kPrimaryColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 5),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(element.title!,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14.sp),
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis),
                                          SizedBox(width: 0.01.sw),
                                          const Icon(
                                            Icons.cancel_outlined,
                                            color: Colors.white,
                                            size: 18,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        : Text(select_category,
                            style: TextStyle(
                                color: primarycolor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis),
                    Align(
                      alignment: const Alignment(1, 0),
                      child: Obx(() {
                        return Icon(
                          productController.showingCategories.value
                              ? Icons.arrow_drop_up_outlined
                              : Icons.arrow_drop_down_outlined,
                          color: primarycolor,
                          size: 25,
                        );
                      }),
                    ),
                  ],
                ));
          }),
        ),
        SizeTransition(
            axisAlignment: 1.0,
            sizeFactor: animation,
            child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                ),
                child: _buildDropListOptions(widget.dropList!, context))),
      ],
    );
  }

  Column _buildDropListOptions(List items, BuildContext context) {
    return Column(
      children: items.map((item) => _buildSubMenu(item, context)).toList(),
    );
  }

  Widget _buildSubMenu(Interests item, BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 26.0, top: 5, bottom: 5),
      child: GestureDetector(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 1)),
                  ),
                  child: Text(item.title!,
                      style: const TextStyle(
                          color: primarycolor,
                          fontWeight: FontWeight.w400,
                          fontSize: 14),
                      maxLines: 3,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis)),
            ),
          ],
        ),
        onTap: () {
          if (!productController.pickedProductCategories.contains(item)) {
            productController.pickedProductCategories.add(item);
          }
          productController.showingCategories.value = false;
          expandController.reverse();
        },
      ),
    );
  }
}
