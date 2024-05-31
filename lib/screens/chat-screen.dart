import 'dart:convert';

import 'package:chat_app/models/messageModel.dart';
import 'package:chat_app/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';


import 'auth/userCon.dart';
class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({Key? key,required this.user}) : super(key: key);


  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var msg=TextEditingController();
  UserController userController=UserController();
  FirebaseAuth auth=FirebaseAuth.instance;
  List<MessageModel> messages=[];
  var ourmessage=Hive.box("chat");
  var yourmessage=Hive.box("yourchat");


  @override
  void initState() {
    // TODO: implement initState
    print(widget.user.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white.withOpacity(.90), // Set the desired status bar color

    ));
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(0, 66.0), // Set your desired width and height
          child: _appbar(),
        ),
        body: Column(
          children: [
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: userController.messages.collection('chat/${userController.generateConversationID(auth.currentUser!.uid, widget.user.id)}/messages/').orderBy("sent",descending: true).snapshots(),
                  builder: (context,snapshot){
                    if(snapshot.connectionState==ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator(),);
                    }
                    else if(snapshot.hasError)
                      {
                        return Center(child: Text("Sorry no messages at this time"));
                      }
                    else if(snapshot.data!.docs.isEmpty)
                      {
                        return Center(child: Text("Say hi to user"));
                      }
                    else{


                      return ListView.builder(
                        reverse: true,
                        itemCount: snapshot.data!.docs.length, // Use the actual number of messages
                        itemBuilder: (context, index){
                          var message = snapshot.data!.docs[index];
                          var data = message.data() as Map<String, dynamic>;
                          var messageModel = MessageModel.fromJson(data);

                          if(widget.user.id==messageModel.formid){
                            ourmessage.put("${widget.user.id}our",messageModel.msg);
                            // print(ourmessage.get("${widget.user.id}our"));
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                  Container(
                                      margin: EdgeInsets.only(left: 10,right:5),
                                      child: Icon(Icons.done_all,color: Colors.lightBlue,size: 22,)),
                                Container(
                                    margin: EdgeInsets.only(left: 5,),
                                    child: Text(
                                        DateFormat('MM-dd HH:mm:').format(
                                            DateTime.fromMillisecondsSinceEpoch(int.parse(messageModel.sent))
                                        )
                                    )

                                ),
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.all(15),
                                    margin: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.shade200,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15), // Rounded top-left corner
                                        topRight: Radius.circular(15), // Rounded top-right corner
                                        bottomRight: Radius.circular(15), // Rounded bottom-right corner
                                        bottomLeft: Radius.circular(0), // Square bottom-left corner
                                      ),
                                    ),
                                    child: Text("${widget.user.id}our"),
                                  ),
                                ),

                              ],
                            );
                          }
                          else{
                            yourmessage.put("${widget.user.id}yours", messageModel.msg);
                            print(yourmessage.get("${widget.user.id}yours"));
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.all(15),
                                    margin: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade200,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15), // Rounded top-left corner
                                        topRight: Radius.circular(15), // Rounded top-right corner
                                        bottomRight: Radius.circular(15), // Rounded bottom-right corner
                                        bottomLeft: Radius.circular(0), // Square bottom-left corner
                                      ),
                                    ),
                                    child: Text(messageModel.msg),
                                  ),
                                ),

                                Container(
                                    child:Text(
                                        DateFormat('yyyy-MM-dd HH:mm').format(
                                            DateTime.fromMillisecondsSinceEpoch(int.parse(messageModel.sent))
                                        )
                                )),
                                Container(
                                    margin: EdgeInsets.only(left: 5,right:5),
                                    child: Icon(Icons.done_all,color: Colors.lightBlue,size: 22,)),
                                ],
                            );
                          }
                        },
                      );
                    }
                    return Container(child: null,);
                  },
                )
            ),
            _inputChatField(widget.user),
          ],
        ),

      ),
    );
  }
  //Screen is ending up here below it there are weigits
  Widget _inputChatField(ChatUser user){
    return Container(
      margin: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Row(
                children: [
                  IconButton(onPressed: (){}, icon: Icon(Icons.emoji_emotions_outlined,color: Colors.blue,)),
                  Expanded(child: TextField(
                    controller: msg,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        border: InputBorder.none,),
                  )),
                  IconButton(onPressed: (){}, icon: Icon(Icons.image,color: Colors.blue,)),
                  IconButton(onPressed: (){}, icon: Icon(Icons.camera_alt_outlined,color: Colors.blue,)),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.lightBlueAccent),
            ),
            height: 50,
            width: 50,
            child: IconButton(
              onPressed: () async{
                if(msg.text!=""){
                  final time=DateTime.now().millisecondsSinceEpoch.toString();
                   var message=MessageModel(msg: msg.text, toid: user.id, formid: auth.currentUser!.uid, read: "", type: Type.text, sent: time);
                  final messagesCollection = FirebaseFirestore.instance.collection('chat/${userController.generateConversationID(auth.currentUser!.uid, widget.user.id)}/messages/');
                  await messagesCollection.doc(time).set(message.toJson());
                  msg.text="";
                }
              },
              icon: Icon(Icons.send, color: Colors.white),
            ),
          )

        ],
      ),
    );
  }


  Widget _appbar(){
    return Row(
      children: [
        IconButton(onPressed: (){
          Get.back();
        }, icon: Icon(Icons.arrow_back)),
         ClipRRect(
           borderRadius: BorderRadius.circular(100),
           child: Image.network(widget.user.image,width: 40,height: 40,),
         ),
        SizedBox(width: 10,),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.user.email),
            Text("not recived"),
          ],
        )
      ],
    );
  }
}
