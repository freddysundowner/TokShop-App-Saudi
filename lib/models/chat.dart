class Chat {
  String date;
  String id;
  String message;
  bool seen;
  String sender;
  String? senderName;
  String? senderProfileUrl;

  Chat(this.date, this.id, this.message, this.seen, this.sender,
      {this.senderName, this.senderProfileUrl});

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'id': id,
      'message': message,
      'seen': seen,
      'sender': sender,
      'senderName': senderName ?? "",
      "senderProfileUrl": senderProfileUrl ?? ""
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(map['date'] as String, map['id'] as String,
        map['message'] as String, map['seen'] as bool, map['sender'] as String,
        senderName: map['senderName'] as String,
        senderProfileUrl: map['senderProfileUrl'] as String);
  }
}
