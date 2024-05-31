import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/userModel.dart';
import 'package:chat_app/screens/auth/loginScreen.dart';
import 'package:chat_app/screens/auth/userCon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({Key? key,required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formkey=GlobalKey<FormState>();
  late ChatUser me;
  File? image;
  FirebaseStorage storage=FirebaseStorage.instance;
  UserController userController=UserController();
  @override
  void initState() {
    setState(() {
      me = widget.user;
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ()async{
          FirebaseAuth.instance.signOut();
          await GoogleSignIn().disconnect();
          Get.offAll(()=>LoginScreen());
        },
        icon: Icon(Icons.add),
        label: Text("Log Out"),

      ),
      body: Form(
        key: _formkey,
        child: Container(
          margin: EdgeInsets.all(10),
          child: ListView(
            children: [
              Column(
                children: [
                  SizedBox(height: 20,),
                  Stack(
                    children: [
                      Container(
                        height: 150,
                        width: 150,
                        child:ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: image != null ? Image.file(image!) : CachedNetworkImage(
                            imageUrl: widget.user.image,
                            fit: BoxFit.fill,
                          ),
                        )
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: IconButton(
                          onPressed: _bottomsheet,
                          icon: Icon(Icons.edit, color: Colors.blueAccent),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.white), // Use MaterialStateProperty
                          ),
                        ),
                      )

                    ],
                  ),
                  SizedBox(height: 10,),
                  Text(widget.user.email),
                  SizedBox(height: 20,),
                  TextFormField(
                    onChanged: (val)=>me.name=val,
                    validator: (val)=>val != null && val.isNotEmpty ? null:"Required Field",
                    initialValue: widget.user.name,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.blue, // Customize the border color
                          width: 2.0, // Customize the border width
                        ),
                      ),
                      prefixIcon: Icon(Icons.person),
                      hintText: "Name here",
                    )
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                      onChanged: (val)=>me.about = val,
                      validator: (val)=>val != null && val.isNotEmpty ? null:"Required Field",
                    initialValue: widget.user.about,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.blue, // Customize the border color
                            width: 2.0, // Customize the border width
                          ),
                        ),
                        prefixIcon: Icon(Icons.info_outline_rounded),
                        hintText: "Name here",
                      )
                  ),
                  SizedBox(height: 20,),
                  SizedBox(
                    width: 150,  // Set the maximum width
                    height: 60, // Set the maximum height
                    child: ElevatedButton(
                      onPressed: () async{
                        if(_formkey.currentState!.validate()){
                          try{
                            print(me.name);
                            print(me.about);
                             await userController.firestore.doc(widget.user.id).update({
                               "name":me.name,
                               "about":me.about,
                             });
                          }
                          catch(e){
                            print(e);
                          }
                        }
                      },
                      child: Text("Update"),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _bottomsheet(){
    showModalBottomSheet(context: context, builder: (_){
      return ListView(
        padding: EdgeInsets.only(bottom: 20),
        shrinkWrap: true,
        children: [
          Container(
            margin: EdgeInsets.all(15),
              alignment: Alignment.center,
              child: Text("Set Yours Profile Picture")),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? photo = await picker.pickImage(source: ImageSource.camera,imageQuality: 70);
                  if (photo != null) {
                    setState(() {
                      image = File(photo.path); // Convert XFile to File
                    });
                  }
                  print("key likhan tery $image");
                  Navigator.pop(context);
                  setimage(File(image!.path));
                },
                child: Image.asset("assets/images/camera.png",height: 100,width: 100,),
              ),
              GestureDetector(
                onTap: ()async{
                  print("gallery");
                  final ImagePicker picker = ImagePicker();
                  final XFile? image1 = await picker.pickImage(source: ImageSource.gallery);
                  if(image1!=null){
                   setState(() {
                     image=File(image1.path);
                     print("image is this $image" );
                   }
                   );
                   Navigator.pop(context);
                   setimage(File(image!.path));
                  }
                },
                child: Image.asset("assets/images/gallery.png",height: 100,width: 100,),
              )
            ],
          )
        ],
      );
    });
  }
  void setimage(File file)async{
    var ext=file.path.split(".").last;
    var ref=storage.ref().child("profileImages/${me.id}.$ext");
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    var img=await ref.getDownloadURL();
    print("url of image $img");
    me.image=img;
    await userController.firestore.doc(widget.user.id).update({
      "image":me.image,
    });
  }
}
