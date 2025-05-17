import 'package:chatme/pages/groupinfo.dart';
import 'package:chatme/service/database_service.dart';
import 'package:chatme/widgets/messagetile.dart';
import 'package:chatme/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget{
  final String groupId;
  final String groupName;
  final String userName;

  const ChatPage({Key? key,
    required this.userName,
    required this.groupName,
    required this.groupId}) :super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  String admin = "" ;
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getChatandAdmin();
  }

  getChatandAdmin() {
    DatabaseService().getChats(widget.groupId).then((val){
      setState(() {
        chats = val;
      });

    });
    DatabaseService().getGroupAdmin(widget.groupId).then((val){
      setState(() {
        admin = val;

      });
    });
  }


  Widget build(BuildContext context){
    return Scaffold(
     appBar: AppBar(
       centerTitle: true,
       elevation: 0,
       title: Text(widget.groupName,style: TextStyle(color: Colors.white),),
       backgroundColor: Theme.of(context).primaryColor,
       actions: [
         IconButton(onPressed: (){
           nextScreen(context, GroupInfo(
               groupName: widget.groupName,
               groupId: widget.groupId,
               adminName: admin));
         }, icon: Icon(Icons.info,color: Colors.white,))
       ],
     ),
      body: Stack(
        children: <Widget> [
          //chat messages here
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
          width: MediaQuery.of(context).size.width,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 18,horizontal: 20),
              width: MediaQuery.of(context).size.width,
              color: Color(0xFFEDECF4),
              child: Row(
                children: [
                  Expanded(child: TextFormField(
                    controller: messageController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Send a message.....",
                      hintStyle: TextStyle(color: Colors.black,fontSize: 16),
                      border: InputBorder.none,
                    ),
                  )),
                 SizedBox(width: 12),
                  GestureDetector(
                    onTap: (){
                      sendMessage();
                    },
                    child: Container(
                      height: 50, width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(Icons.send,color: Colors.white,),
                    ),
                  )
                ],),
            ),

          )


        ],
      ),
    );

  }
  chatMessages(){
    return StreamBuilder(
        stream: chats,
        builder: (context,AsyncSnapshot snapshot){
          return snapshot.hasData ? ListView.builder(
            itemCount: snapshot.data.docs.length,
              itemBuilder: (context,index){
               return MessageTile(
                   message: snapshot.data.docs[index]['message'],
                   sender: snapshot.data.docs[index]['sender'],
                   sentByMe: widget.userName==snapshot.data.docs[index]['sender']);

              }
          ) : Container();
        }

    );
  }
  sendMessage(){
    if(messageController.text.isNotEmpty){
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time" : DateTime.now().microsecondsSinceEpoch,

      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }

  }
}