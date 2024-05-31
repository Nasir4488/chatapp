class ChatUser {
  String image;
  String about;
  String name;
  String createdAt;
  bool isOnline;
  String id;
  String lastActive;
  String email;
  String pushTokken;

  ChatUser({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.pushTokken});

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      image: json["image"] ?? "",
      about: json["about"] ?? "",
      name: json["name"] ?? "",
      createdAt: json["createdAt"] ?? "",
      isOnline: json["isOnline"] == 'true',
      id: json["id"] ?? "",
      lastActive: json["lastActive"] ?? "",
      email: json["email"] ?? "",
      pushTokken: json["pushTokken"] ?? "",
    );
  }



  Map<String, dynamic> toJson() => {
        'image': image,
        'about': about,
        'name': name,
        'createdAt': createdAt,
        'isOnline': isOnline,
        'id': id,
        'lastActive': lastActive,
        'email': email,
        'pushTokken': pushTokken,
      };
}