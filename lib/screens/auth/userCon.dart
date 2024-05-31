import 'package:chat_app/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
class UserController {
  var box1=Hive.box("myProfile");
  var auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance.collection("user");  // Initialize the Firestore instance
  final messages = FirebaseFirestore.instance;  // Initialize the Firestore instance

  Future<bool> userExists() async {
    try {
      final documentSnapshot = await firestore.doc(auth.currentUser!.uid).get();
      return documentSnapshot.exists;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }
  create_user() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final chatUser = ChatUser(
        image: auth.currentUser!.photoURL.toString(),
        about: "Hey I am Here",
        name: auth.currentUser!.displayName.toString(),
        createdAt: time.toString(),
        isOnline: true,
        id: auth.currentUser!.uid.toString(),
        lastActive: "",
        email: auth.currentUser!.email.toString(),
        pushTokken: ""
      );
      await firestore.doc(auth.currentUser!.uid).set(chatUser.toJson());
    } catch (e) {
      print('Error creating user: $e');
    }
  }
  String generateConversationID(String id,String Userid) {
    return Userid.hashCode <= id.hashCode
        ? '${Userid}_$id'
        : '${id}_${Userid}';
  }
   update(String chatid, String docID) async {
    await messages.collection('chat/${generateConversationID(auth.currentUser!.uid, chatid)}/messages/').doc(docID).update(
        {"read": DateTime.now().millisecondsSinceEpoch});
  }
}







