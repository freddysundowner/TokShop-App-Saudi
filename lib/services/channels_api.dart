import 'dart:convert';

import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../utils/utils.dart';
import 'client.dart';
import 'end_points.dart';

class ChannelAPI {
  getChannels() async {
    var channel =
        await DbBase().databaseRequest(channels, DbBase().getRequestType);
    return jsonDecode(channel);
  }

  getChannel(String id) async {
    var channel = await DbBase()
        .databaseRequest(getChannelById + id, DbBase().getRequestType);

    return jsonDecode(channel);
  }

  subscribeChannel(String channelId) async {
    try {
      var body = {"uid": Get.find<AuthController>().currentuser!.id!};

      await DbBase().databaseRequest(
          subscribeChannelUrl + channelId, DbBase().patchRequestType,
          body: body);
    } catch (e, s) {
      printOut("Error joining channel $e $s");
    }
  }

  unsubscribeChannel(String channelId) async {
    try {
      var body = {"uid": Get.find<AuthController>().currentuser!.id!};

      await DbBase().databaseRequest(
          unsubscribeChannelUrl + channelId, DbBase().patchRequestType,
          body: body);
    } catch (e, s) {
      printOut("Error joining channel $e $s");
    }
  }
}
