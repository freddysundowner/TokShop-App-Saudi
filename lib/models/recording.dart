import 'tokshow.dart';
import 'user.dart';

class Recording {
  Recording({
    required this.date,
    required this.id,
    required this.userId,
    required this.roomId,
    required this.resourceId,
    required this.sid,
    required this.fileList,
  });

  int date;
  String id;
  UserModel userId;
  Tokshow? roomId;
  String resourceId;
  String sid;
  String fileList;

  factory Recording.fromJson(Map<String, dynamic> json) => Recording(
        date: json["date"],
        id: json["_id"],
        userId: UserModel.fromJson(json["userId"]),
        roomId:
            json["roomId"] == null ? null : Tokshow.fromJson(json["roomId"]),
        resourceId: json["resourceId"],
        sid: json["sid"],
        fileList: json["fileList"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "_id": id,
        "userId": userId.toJson(),
        "roomId": roomId?.toJson(),
        "resourceId": resourceId,
        "sid": sid,
      };
}
