import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:tokshop/screens/products/components/product_list_single_item.dart';
import 'package:tokshop/services/dynamic_link_services.dart';
import 'package:tokshop/utils/styles.dart';
import 'package:tokshop/widgets/bottom_sheet_dialog.dart';
import '../../controllers/room_controller.dart';
import '../../models/tokshow.dart';

class PlayRecordingPage extends StatelessWidget {
  final TokShowController _homeController = Get.find<TokShowController>();

  final bool videoPlayerInitialised = false;
  final TextEditingController messageController = TextEditingController();

  final String roomId;

  PlayRecordingPage({Key? key, required this.roomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _homeController.onTokShowChatPage.value = false;

    return Scaffold(
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () {
            return _homeController
                .fetchRoom(_homeController.currentRecordedRoom.value.id!);
          },
          child: _homeController.isCurrentRecordedRoomLoading.isFalse &&
                  _homeController.currentRecordedRoom.value.userIds != null
              ? Stack(
                  children: [
                    buildVideoPlayer(),
                    // Positioned(
                    //   right: 20,
                    //   top: 80,
                    //   child: Row(
                    //     children: [
                    //       IconButton(
                    //         icon: const Icon(
                    //           Icons.keyboard_arrow_down_outlined,
                    //           color: Colors.white,
                    //           size: 35,
                    //         ),
                    //         onPressed: () {
                    //           if (_homeController
                    //                   .currentRecordedRoom.value.recordedRoom ==
                    //               true) {
                    //             _homeController.disposeVideoPlayer();
                    //             _homeController.currentRecordedRoom.value =
                    //                 Tokshow();
                    //           }
                    //           Get.back();
                    //         },
                    //       ),
                    //       const SizedBox(
                    //         width: 10,
                    //       ),
                    //       const Icon(
                    //         Icons.visibility,
                    //         color: Colors.white,
                    //       ),
                    //       const SizedBox(
                    //         width: 5,
                    //       ),
                    //       Obx(() {
                    //         return Text(
                    //           _homeController
                    //               .currentRecordedRoom.value.userIds!.length
                    //               .toString(),
                    //           style: const TextStyle(color: Colors.white),
                    //         );
                    //       }),
                    //     ],
                    //   ),
                    // ),
                    // if (_homeController.currentRecordedRoom.value.title
                    //     .toString()
                    //     .isNotEmpty)
                    //   Align(
                    //       alignment: Alignment.topLeft,
                    //       child: Padding(
                    //         padding: const EdgeInsets.only(left: 20.0),
                    //         child: Column(
                    //           children: [
                    //             SizedBox(
                    //               height: 0.1.sh,
                    //             ),
                    //             Text(
                    //               _homeController
                    //                   .currentRecordedRoom.value.title
                    //                   .toString(),
                    //               style: TextStyle(
                    //                   color: Colors.white,
                    //                   fontSize: 18.sp,
                    //                   fontWeight: FontWeight.w600),
                    //             ),
                    //           ],
                    //         ),
                    //       )),
                    // Positioned(
                    //     bottom: 80,
                    //     right: 20,
                    //     child: Column(
                    //       children: [
                    //         InkWell(
                    //           onTap: () async {
                    //             _homeController.shareSheetLoading.value = true;
                    //             await DynamicLinkService()
                    //                 .generateShareLink(
                    //                     _homeController.currentRoom.value.id!,
                    //                     type: "room",
                    //                     title:
                    //                         "Watch recorded '${_homeController.currentRoom.value.title}' TokShow",
                    //                     msg:
                    //                         "Products on the show ${_homeController.currentRoom.value.productIds!.map((e) => e.name).toList()}",
                    //                     imageurl: _homeController
                    //                             .currentRoom
                    //                             .value
                    //                             .productIds![0]
                    //                             .images!
                    //                             .isNotEmpty
                    //                         ? _homeController.currentRoom.value
                    //                             .productIds![0].images![0]
                    //                         : "")
                    //                 .then((value) async {
                    //               _homeController.shareSheetLoading.value =
                    //                   false;
                    //               await Share.share(value);
                    //             });
                    //           },
                    //           child: Column(
                    //             children: [
                    //               const Icon(
                    //                 Icons.share,
                    //                 color: Colors.white,
                    //                 size: 28,
                    //               ),
                    //               const SizedBox(
                    //                 height: 5,
                    //               ),
                    //               Text(
                    //                 "Share",
                    //                 style: TextStyle(
                    //                     color: Colors.white, fontSize: 10.sp),
                    //               )
                    //             ],
                    //           ),
                    //         ),
                    //         const SizedBox(
                    //           height: 20,
                    //         ),
                    //         InkWell(
                    //           onTap: () {
                    //             showFilterBottomSheet(
                    //                 context,
                    //                 Container(
                    //                   padding: const EdgeInsets.symmetric(
                    //                       horizontal: 10, vertical: 15),
                    //                   child: ListView(
                    //                     children: _homeController
                    //                         .currentRoom.value.productIds!
                    //                         .map((e) => ProductListSingleItem(
                    //                             product: e))
                    //                         .toList(),
                    //                   ),
                    //                 ));
                    //           },
                    //           child: Stack(
                    //             clipBehavior: Clip.none,
                    //             children: [
                    //               Container(
                    //                 padding: const EdgeInsets.all(10),
                    //                 decoration: BoxDecoration(
                    //                     color: Colors.black,
                    //                     border:
                    //                         Border.all(color: kPrimaryColor),
                    //                     borderRadius:
                    //                         BorderRadius.circular(100)),
                    //                 child: const Icon(
                    //                   Icons.shopping_cart,
                    //                   color: Colors.white,
                    //                   size: 28,
                    //                 ),
                    //               ),
                    //               Positioned(
                    //                 right: 0,
                    //                 top: -10,
                    //                 child: Container(
                    //                   padding: const EdgeInsets.all(8),
                    //                   decoration: const BoxDecoration(
                    //                       shape: BoxShape.circle,
                    //                       color: Colors.white),
                    //                   child: Text(
                    //                     _homeController.currentRoom.value
                    //                         .productIds!.length
                    //                         .toString(),
                    //                     style: const TextStyle(
                    //                         color: Colors.black,
                    //                         fontWeight: FontWeight.bold),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ],
                    //     ))
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(
                  color: Colors.black87,
                )),
        );
      }),
    );
  }

  buildVideoPlayer() {
    return Chewie(
      controller: _homeController.chewieController,
    );
  }
}
