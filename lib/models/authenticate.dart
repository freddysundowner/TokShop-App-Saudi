import 'package:meta/meta.dart';

class Authenticate {
  Authenticate(
      {this.email,
      this.type,
      this.profilePhoto = "",
      this.userName,
      this.firstName,
      this.lastName,
      this.bio,
      this.referrer});

  String? email;
  String? type;
  String? userName;
  String? profilePhoto;
  String? lastName;
  String? firstName;
  String? bio;
  String? referrer;

  factory Authenticate.fromJson(Map<String, dynamic> json) => Authenticate(
      email: json["email"],
      type: json["type"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      userName: json["username"],
      profilePhoto: json["profilePhoto"],
      bio: json["bio"],
      referrer: json["referrer"]);

  Map<String, dynamic> toJson() => {
        "email": email,
        "type": type,
        "userName": userName ?? "",
        "profilePhoto": profilePhoto ?? "",
        "firstName": firstName ?? "",
        "lastName": lastName ?? "",
        "bio": bio ?? "",
        "referrer": referrer
      };
}
