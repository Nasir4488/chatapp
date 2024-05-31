class MessageModel {
  MessageModel({
    required this.msg,
    required this.toid,
    required this.formid,
    required this.read,
    required this.type,
    required this.sent,
  });
  late final String msg;
  late final String toid;
  late final String formid;
  late final String read;
  late final Type type;
  late final String sent;

  MessageModel.fromJson(Map<String, dynamic> json){
    msg = json['msg'].toString();
    toid = json['toid'].toString();
    formid = json['formid'].toString();
    read = json['read'].toString();
    type = json['type'].toString()==Type.image.name? Type.image:Type.text;
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['toid'] = toid;
    data['formid'] = formid;
    data['read'] = read;
    data['type'] = type.name;
    data['sent'] = sent;
    return data;
  }

}
enum Type{text,image}