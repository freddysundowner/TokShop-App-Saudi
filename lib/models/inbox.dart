import 'package:firebase_auth/firebase_auth.dart';

class Inbox {
  String id;
  String lastMessage;
  String lastMessageTime;
  String lastSender;
  var lastSeen;
  bool online;
  List<dynamic> userIds;
  List<dynamic> users;
  int unread;

  Inbox(this.id, this.lastMessage, this.lastMessageTime, this.lastSender,
      this.online, this.userIds, this.lastSeen, this.users, this.unread);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'lastSender': lastSender,
      'userIds': userIds,
      'last_seen': userIds,
      'users': users,
    };
  }

  factory Inbox.fromMap(Map<String, dynamic> data, userId) {
    return Inbox(
        data["id"],
        data["lastMessage"],
        data["lastMessageTime"].toString(),
        data["lastSender"],
        data['online_$userId'] ?? false,
        data["userIds"],
        data["last_seen"] ?? "",
        data["users"],
        data[FirebaseAuth.instance.currentUser!.uid] ?? 0);
  }
}
