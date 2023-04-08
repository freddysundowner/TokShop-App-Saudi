class Interests {
  String? title;
  String? id;

  Interests({
    this.title,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": title,
    };
  }

  factory Interests.fromJson(json) {
    return Interests(
      id: json['_id'],
      title: json['name'],
    );
  }
}
