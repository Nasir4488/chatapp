import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/userModel.dart';
import 'package:chat_app/screens/auth/userCon.dart';
import 'package:chat_app/screens/profieScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'chat-screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  UserController userController=UserController();
  List<ChatUser> user=[];
  bool issearching=false;
  List<ChatUser> _searchlist=[];
  var box=Hive.box("mybox");
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading:IconButton(onPressed: (){}, icon: Icon(Icons.home)),
          actions: [
            IconButton(onPressed: (){
              setState(() {
                issearching=!issearching;
              });
            }, icon: Icon(issearching?CupertinoIcons.add_circled:Icons.search)),
            IconButton(onPressed: ()async{
              Future<QuerySnapshot> self = userController.firestore
                  .where("id", isEqualTo: userController.auth.currentUser!.uid)
                  .get();
              var selfSnapshot = await self;
              var document = selfSnapshot.docs.first;
              var selfdata = document.data() as Map<String, dynamic>;
              ChatUser selfUser=ChatUser.fromJson(selfdata);
              Get.to(()=>ProfileScreen(user: selfUser));
            }, icon: Icon(Icons.more_vert)),
          ],
          title: issearching?
          TextFormField(
            onChanged: (val) {
              _searchlist.clear();
              for (var i in user) {
                if (i.name.toLowerCase().contains(val.toLowerCase()) || i.email.toLowerCase().contains(val.toLowerCase())) {
                  _searchlist.add(i);
                  setState(() {
                  });
                }
              }
              print("Search List Length: ${_searchlist.length}");
            },
            autofocus: true,
          ):
          Text("We Chat",style: TextStyle(fontSize: 20,fontWeight: FontWeight.normal),),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            for(var i in user){
              print(box.get(i.id));
              print(box.get("${i.id}email"));
            }
          },
          child: Icon(Icons.add),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: userController.firestore.where("id",isNotEqualTo: userController.auth.currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Display a loading indicator while fetching data.
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              user = [];
              for (var doc in snapshot.data!.docs) {
                var data1 = doc.data() as Map<String, dynamic>;
                ChatUser chatUser = ChatUser.fromJson(data1);
                user.add(chatUser);
                box.put(chatUser.id, chatUser.name);
                box.put("${chatUser.id}email", chatUser.email);
              }
              print(user.length);
              return ListView.builder(
                itemCount: issearching ? _searchlist.length : user.length,
                itemBuilder: (context, index) {
                  final chatUser = issearching ? _searchlist[index] : user[index];
                  return GestureDetector(
                    onTap: (){
                      Get.to(()=>ChatScreen(user: user[index],),transition: Transition.cupertino,duration: Duration(seconds: 2));
                    },
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(imageUrl: chatUser.image),
                        ),
                      ),
                      title: Text(box.get(chatUser.id)),
                      subtitle: Text(box.get("${chatUser.id}email")),
                      // Add more widgets to display other user information
                    ),
                  );
                },
              );
            }
          },
        )
    );
  }
}