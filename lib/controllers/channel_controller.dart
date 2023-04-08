import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/channel.dart';

import '../models/channel.dart';
import '../services/notifications_api.dart';
import '../services/channels_api.dart';
import '../utils/utils.dart';
import 'auth_controller.dart';
import 'room_controller.dart';
import 'user_controller.dart';

class ChannelController extends GetxController {
  var chosenChannelImage = "".obs;
  var seearchchannelLoading = false.obs;
  var channelLoading = false.obs;
  var currentChannel = Channel().obs;
  RxList<Channel> allchannels = RxList([]);
  TextEditingController searchUsersController = TextEditingController();
  TokShowController roomController = Get.find<TokShowController>();
  UserController userController = Get.find<UserController>();
  var toInviteUsers = [].obs;

  final channelNameTextController = TextEditingController();
  final descriptioncontroller = TextEditingController();
  var publish = false.obs;
  var membersprivate = false.obs;
  var allowfollowers = false.obs;
  var membercanstartrooms = false.obs;
  var channelJoiningId = "".obs;

  @override
  void onInit() {
    super.onInit();
    getAllChannels();
  }

  getAllChannels() async {
    try {
      seearchchannelLoading.value = true;

      List<dynamic> channelss = await ChannelAPI().getChannels();

      allchannels.assignAll(channelss.map((e) => Channel.fromJson(e)).toList());
    } catch (e) {
      seearchchannelLoading.value = false;
    } finally {
      seearchchannelLoading.value = false;
    }
  }

  Future<void> joinChannel(Channel channel) async {
    channelLoading.value = true;
    await ChannelAPI().subscribeChannel(channel.id!);
    channel.members!.add(Get.find<AuthController>().currentuser!.id!);
    Get.find<AuthController>().usermodel.value?.channels!.add(channel);
    Get.find<AuthController>().usermodel.refresh();
    allchannels.refresh();

    channelLoading.value = false;
  }

  Future<void> leaveChannel(Channel channel) async {
    channelLoading.value = true;
    await ChannelAPI().unsubscribeChannel(channel.id!);
    channel.members!.removeWhere((element) => element == channel.id);
    Get.find<AuthController>()
        .usermodel
        .value
        ?.channels!
        .removeWhere((element) => element.id == channel.id);
    Get.find<AuthController>().usermodel.refresh();
    allchannels.refresh();
    channelLoading.value = false;
  }

  getChannel(String channelId) async {
    try {
      channelLoading.value = true;

      var channel = await ChannelAPI().getChannel(channelId);

      if (channel != null) {
        currentChannel.value = Channel.fromJson(channel);
      }
    } catch (e, s) {
      printOut("Error getting channel $e $s");
    } finally {
      channelLoading.value = false;
    }
  }

  Future<void> inviteUser(String title, String message, String type,
      String actionKey, List userIds, String imageUrl) async {
    await NotificationsAPI()
        .sendNotification(userIds, title, message, type, actionKey);

    for (var i = 0; i < userIds.length; i++) {
      var activityBody = {
        "imageurl": imageUrl,
        "name": title,
        "type": type,
        "actionkey": actionKey,
        "actioned": false,
        'to': userIds.elementAt(i),
        'from': Get.find<AuthController>().currentuser!.id,
        "message": message,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      await NotificationsAPI().saveActivity(activityBody);
    }
  }
}
