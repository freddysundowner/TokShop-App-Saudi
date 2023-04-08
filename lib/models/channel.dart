import 'package:tokshop/models/interests.dart';

import 'tokshow.dart';

class Channel {
  String? title;
  String? id;
  String? description;
  String? ownerid;
  String? imageurl;
  List<Interests>? subinterests;
  List<Tokshow>? rooms;
  List<String>? members;
  List<String>? invited;

  Channel({
    this.title,
    this.id,
    this.imageurl,
    this.subinterests,
    this.description,
    this.invited,
    this.ownerid,
    this.rooms,
    this.members = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "interests": subinterests,
      "description": description,
      "ownerid": ownerid,
      "iconurl": imageurl,
      "invited": invited,
      "rooms": rooms,
    };
  }

  factory Channel.fromJson(channel) {
    var json = channel;

    List<String> invited = json["invited"] != null
        ? List<String>.from(json["invited"].map((item) => item))
        : [];

    List<String> members = json["members"] != null
        ? List<String>.from(json["members"].map((item) => item))
        : [];
    List<Tokshow> rooms = json["rooms"] != null
        ? List<Tokshow>.from(json["rooms"].map((item) =>
            item.toString().length > 80
                ? Tokshow.fromJson(item)
                : Tokshow(id: item)))
        : [];
    List<Interests> subinterests = json["interests"] != null
        ? List<Interests>.from(
            json["interests"].map((item) => Interests.fromJson(item)))
        : [];
    return Channel(
      id: json['_id'],
      title: json['title'],
      imageurl: json['imageurl'] ?? "",
      invited: invited,
      subinterests: subinterests,
      rooms: rooms,
      members: members,
    );
  }
}
