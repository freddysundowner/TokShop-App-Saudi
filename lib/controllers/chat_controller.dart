import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tokshop/services/notifications_api.dart';

import '../models/chat.dart';
import '../models/inbox.dart';
import '../models/user.dart';
import '../utils/utils.dart';
import 'auth_controller.dart';
import 'room_controller.dart';
import 'package:intl/intl.dart';

class ChatController extends GetxController {
  FirebaseFirestore db = FirebaseFirestore.instance;
  var allUserChats = [].obs;
  var gettingChats = false.obs;
  var currentChatLoading = false.obs;
  var currentChat = [].obs;
  RxList<Chat> currentRoomChat = RxList([]);
  var currentRecordedRoomChat = [].obs;
  var currentChatUsers = [].obs;
  var currentChatUsersIds = [].obs;
  var currentChatId = "".obs;
  var sendingMessage = false.obs;
  late Stream<QuerySnapshot> allChatStream;
  late Stream<QuerySnapshot> chatStream;
  late StreamSubscription<QuerySnapshot> roomChatStream;
  var unReadChats = 0.obs;
  var online = false.obs;
  RxString lastseen = RxString("");
  RxBool typing = RxBool(false);

  @override
  void onInit() {
    allUserChats.value = [];
    if (FirebaseAuth.instance.currentUser != null) {
      getUserChats();
    }
    super.onInit();
  }

  Future<void> getUserChats() async {
    gettingChats.value = true;

    allUserChats.bindStream(allUserChatsStream());
    gettingChats.value = false;
  }

  Stream<List> allUserChatsStream() {
    allChatStream = FirebaseFirestore.instance
        .collection("chats")
        .where("userIds", arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    online.value = false;
    lastseen.value = "";
    return allChatStream.map((event) {
      var unread = 0;
      var chatty = event.docs.map((e) {
        Map<String, dynamic> data = e.data()! as Map<String, dynamic>;
        var int = currentChatUsersIds.indexWhere(
            (element) => element != FirebaseAuth.instance.currentUser!.uid);
        Inbox allChatsModel =
            Inbox.fromMap(data, data["userIds"][int == -1 ? 0 : int]);
        unread = unread + allChatsModel.unread;
        if (allChatsModel.id == currentChatId.value) {
          var id = allChatsModel.userIds.indexWhere(
              (element) => FirebaseAuth.instance.currentUser!.uid != element);
          String userid = allChatsModel.userIds[id];
          online.value = data["online_$userid"] ?? false;
          if (data["last_seen_$userid"] != null) {
            typing.value = data["typing_$userid"];
            lastseen.value = DateFormat('yyyy-MM-dd hh:mm')
                .format(data["last_seen_$userid"].toDate());

            lastseen.refresh();
          } else {
            lastseen.value = "";
          }
        }

        return allChatsModel;
      }).toList();
      chatty.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      unReadChats.value = unread;
      return chatty;
    });
  }

  Future<void> getChatById(String id) async {
    currentChatLoading.value = true;

    currentChat.bindStream(singleChatStream(id));
    currentChatLoading.value = false;
  }

  Stream<List> singleChatStream(String id) {
    chatStream =
        FirebaseFirestore.instance.collection("chats/$id/messages").snapshots();

    var chat = chatStream.map((event) {
      var chatty = event.docs.map((e) {
        Map<String, dynamic> data = e.data()! as Map<String, dynamic>;

        Chat chatRoomModel = Chat(data['date'], data["id"], data['message'],
            data['seen'], data['sender'],
            senderName: data['senderName'] ?? "",
            senderProfileUrl: data['senderProfileUrl'] ?? "");

        return chatRoomModel;
      }).toList();
      chatty.sort((a, b) => a.date.compareTo(b.date));
      return chatty;
    });

    return chat;
  }

  Future<void> getRecordingRoomChatById(String id) async {
    currentChatLoading.value = true;
    currentRecordedRoomChat.value = [];
    currentRecordedRoomChat.bindStream(singleRoomChatStream(id));
    currentChatLoading.value = false;
  }

  singleRoomChatStream(String id) {
    currentRoomChat.value = [];
    roomChatStream = FirebaseFirestore.instance
        .collection("chats/$id/messages")
        .snapshots()
        .listen((event) {
      var chatty = event.docs.map((e) {
        Map<String, dynamic> data = e.data();

        Chat chatRoomModel = Chat(data['date'], data["id"], data['message'],
            data['seen'], data['sender'],
            senderName: data['senderName'] ?? "",
            senderProfileUrl: data['senderProfileUrl'] ?? "");

        return chatRoomModel;
      }).toList();
      chatty.sort((a, b) => a.date.compareTo(b.date));
      currentRoomChat.addAll(chatty);
    });
  }

  Future getChatUsers(String id) async {
    var chat =
        await FirebaseFirestore.instance.collection("chats").doc(id).get();

    for (var user in chat.data()?["users"]) {
      currentChatUsers.add(user["id"]);
    }
  }

  getOtherUser(List chatUsers) {
    String? user;

    for (var i = 0; i < chatUsers.length; i++) {
      if (chatUsers.elementAt(i) != FirebaseAuth.instance.currentUser!.uid) {
        user = chatUsers.elementAt(i);
      }
    }
    return user;
  }

  Future getPreviousChat(UserModel otherUser) async {
    await getUserChats();
    currentChatUsers.add(otherUser.id);
    currentChatUsers.add(Get.find<AuthController>().usermodel.value!.id);

    var otherUserChats = await FirebaseFirestore.instance
        .collection("chats")
        .where("userIds", arrayContains: otherUser.id)
        .get();

    String chatId = "";
    for (var i = 0; i < allUserChats.length; i++) {
      Inbox chatsModel = allUserChats.elementAt(i);

      for (String chat in otherUserChats.docs.map((e) => e.id)) {
        if (chat == chatsModel.id) {
          chatId = chatsModel.id;
        }
      }
    }

    if (chatId != "") {
      currentChatId.value = chatId;
      currentChatId.refresh();
      getChatById(chatId);
    }
  }

  updateOnlineStatus(bool status) async {
    await db.collection("chats").doc(currentChatId.value).set({
      "online_${FirebaseAuth.instance.currentUser!.uid}": status,
      "last_seen_${FirebaseAuth.instance.currentUser!.uid}":
          FieldValue.serverTimestamp()
    }, SetOptions(merge: true));
  }

  updateTypingStatus(bool status) async {
    try {
      await db.collection("chats").doc(currentChatId.value).set({
        "typing_${FirebaseAuth.instance.currentUser!.uid}": status,
      }, SetOptions(merge: true));
    } catch (e) {}
  }

  readChats() async {
    if (currentChatId.value != "") {
      await db.collection("chats").doc(currentChatId.value).set({
        FirebaseAuth.instance.currentUser!.uid: 0,
        "online_${FirebaseAuth.instance.currentUser!.uid}": true
      }, SetOptions(merge: true));
    }
  }

  sendMessage(String message, UserModel otherUser) {
    sendingMessage.value = true;
    getPreviousChat(otherUser).then((value) {
      if (currentChatId.value == "") {
        String genId = db.collection("chats").doc().id;
        currentChatId.value = genId;
        createChat(message, otherUser, genId);
      }

      Chat newChat = Chat(
          DateTime.now().millisecondsSinceEpoch.toString(),
          currentChatId.value,
          message,
          false,
          Get.find<AuthController>().usermodel.value!.id!);

      db
          .collection("chats/${currentChatId.value}/messages")
          .add(newChat.toMap())
          .then((value) async {
        sendingMessage.value = false;

        db.collection("chats").doc(currentChatId.value).set({
          "lastMessage": message,
          "lastMessageTime": DateTime.now().millisecondsSinceEpoch.toString(),
          "typing_${FirebaseAuth.instance.currentUser!.uid}": false,
          "lastSender": Get.find<AuthController>().usermodel.value!.id,
          otherUser.id!: FieldValue.increment(1)
        }, SetOptions(merge: true));
        await NotificationsAPI().sendNotification(
            [otherUser.id],
            "${Get.find<AuthController>().usermodel.value!.firstName}"
                " ${Get.find<AuthController>().usermodel.value!.firstName}",
            message,
            "ChatScreen",
            currentChatId.value);
      });
    });
  }

  saveToFirestore(String message, String roomId) {
    final TokShowController homeController = Get.find<TokShowController>();

    currentChatId.value = roomId;
    sendingMessage.value = true;

    Chat newChat = Chat(DateTime.now().millisecondsSinceEpoch.toString(),
        roomId, message, false, Get.find<AuthController>().usermodel.value!.id!,
        senderName: "${Get.find<AuthController>().usermodel.value!.firstName}"
            " ${Get.find<AuthController>().usermodel.value!.lastName}",
        senderProfileUrl: Get.find<AuthController>()
            .usermodel
            .value!
            .profilePhoto
            .toString());

    db
        .collection("chats/$roomId/messages")
        .add(newChat.toMap())
        .then((value) async {
      sendingMessage.value = false;

      db.collection("chats").doc(roomId).set({
        "lastMessage": message,
        "lastMessageTime": DateTime.now().millisecondsSinceEpoch.toString(),
        "lastSender": Get.find<AuthController>().usermodel.value!.id,
      }, SetOptions(merge: true));

      var roomUsers = [];

      for (var i = 0;
          i < homeController.currentRoom.value.hostIds!.length;
          i++) {
        if (homeController.currentRoom.value.hostIds!.elementAt(i).id !=
            Get.find<AuthController>().usermodel.value!.id!) {
          roomUsers
              .add(homeController.currentRoom.value.hostIds!.elementAt(i).id);
        }
      }

      for (var i = 0;
          i < homeController.currentRoom.value.speakerIds!.length;
          i++) {
        if (homeController.currentRoom.value.speakerIds!.elementAt(i).id !=
            Get.find<AuthController>().usermodel.value!.id!) {
          roomUsers.add(
              homeController.currentRoom.value.speakerIds!.elementAt(i).id);
        }
      }

      for (var i = 0;
          i < homeController.currentRoom.value.userIds!.length;
          i++) {
        if (homeController.currentRoom.value.userIds!.elementAt(i).id !=
            Get.find<AuthController>().usermodel.value!.id!) {
          roomUsers
              .add(homeController.currentRoom.value.userIds!.elementAt(i).id);
        }
      }
      printOut("Chat message saved");
    });
  }

  void createChat(String message, UserModel otherUser, chatId) {
    UserModel currentUser = Get.find<AuthController>().usermodel.value!;
    //Create a new chat
    var data = {
      "id": chatId,
      "lastMessage": message,
      "lastMessageTime": DateTime.now().millisecondsSinceEpoch.toString(),
      "lastSender": FirebaseAuth.instance.currentUser!.uid,
      "userIds": [FirebaseAuth.instance.currentUser!.uid, otherUser.id],
      FirebaseAuth.instance.currentUser!.uid: 0,
      otherUser.id!: 0,
      "unread_users": [otherUser.id],
      "users": [
        {
          "id": currentUser.id,
          "firstName": currentUser.firstName,
          "lastName": currentUser.lastName,
          "userName": currentUser.userName,
          "profilePhoto": currentUser.profilePhoto
        },
        {
          "id": otherUser.id,
          "firstName": otherUser.firstName,
          "lastName": otherUser.lastName,
          "userName": otherUser.userName,
          "profilePhoto": otherUser.profilePhoto
        }
      ]
    };
    db
        .collection("chats")
        .doc(currentChatId.value)
        .set(data, SetOptions(merge: true))
        .then((value) {
      getChatById(currentChatId.value);
    });
  }
}
