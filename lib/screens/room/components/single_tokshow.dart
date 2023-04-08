import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/models/tokshow.dart';
import 'package:tokshop/screens/room/components/room_card.dart';
import 'package:tokshop/utils/text.dart';

class HomepageTokshows extends StatelessWidget {
  HomepageTokshows({Key? key}) : super(key: key);

  final TokShowController _homeController = Get.find<TokShowController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() => RefreshIndicator(
        onRefresh: () {
          return _homeController.getActiveTokshows();
        },
        child: _homeController.allroomsList.isNotEmpty
            ? SizedBox(
                height: 190,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _homeController.allroomsList.length,
                    itemBuilder: (context, index) {
                      Tokshow roomModel = _homeController.allroomsList[index];

                      var hosts = [];
                      hosts = roomModel.hostIds!.length > 10
                          ? roomModel.hostIds!.sublist(0, 10)
                          : roomModel.hostIds!;
                      return RoomCard(
                          roomModel: roomModel,
                          hosts: hosts,
                          showChannel: false);
                    }),
              )
            : Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        no_live_tokshows,
                        style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        onTap: () {
                          _homeController.createRoomView();
                        },
                        child: Container(
                          width: MediaQuery.of(Get.context!).size.width * 0.40,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                      )
                    ],
                  ),
                ),
              )));
  }
}
