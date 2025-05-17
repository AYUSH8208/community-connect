import 'package:chatme/pages/homepage.dart';
import 'package:chatme/widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatme/service/database_service.dart';

class GroupInfo extends StatefulWidget{
  final String groupId;
  final String groupName;
  final String adminName;


  const GroupInfo({Key? key,
    required this.groupName,
    required this.groupId,
    required this.adminName}) : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;
  @override
  void initState() {
    // TODO: implement initState
    getMembers();
    super.initState();
  }
  getMembers() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((val){
          setState(() {
            members = val;
          });
    });
  }
  String getName(String r){
    return r.substring(r.indexOf("_")+1);
  }
  String getId(String res){
    return res.substring(0, res.indexOf("_"));
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Group Info",style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(onPressed: (){
            showDialog(
                context: context,
                builder: (context){
                  return AlertDialog(
                    title: Text("Exit"),
                    content: Text("Are you sure you want to exit?"),
                    actions: [
                      IconButton(onPressed:() {Navigator.pop(context);},
                          icon: Icon(Icons.cancel,color: Colors.red)
                      ),
                      IconButton(onPressed:() async {
                        DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).toggleGroupJoin(
                            widget.groupId, getName(widget.adminName), widget.groupName).whenComplete((){
                              nextScreenReplace(context, Homepage());
                        });
                      },
                          icon: Icon(Icons.done,color: Colors.green,)
                      ),
                    ],
                  );
                });
          }, icon: Icon(Icons.exit_to_app),color: Colors.white,)
        ],

      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 13),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).primaryColor.withOpacity(0.2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(widget.groupName.substring(0,1).toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 20,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Group: ${widget.groupName}",style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 6,),
                      Text("Admin: ${getName(widget.adminName)}",)
                    ],
                  )
                ],
              ),
            ),
            memberList(),
          ],
        ),
      ),

    );

  }
  memberList() {
    return  StreamBuilder(
        stream: members,
        builder: (context, AsyncSnapshot snapshot){
          if(snapshot.hasData){
            if(snapshot.data['members'] != null){
              if(snapshot.data['members'] != 0){
                return ListView.builder(
                    itemCount: snapshot.data['members'].length,
                    shrinkWrap: true,
                    itemBuilder:(context, index){
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(getName(snapshot.data['members'][index])
                                .substring(0,1).toUpperCase(),
                              style: TextStyle(
                                  color:  Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),),
                          ),
                          title:  Text(getName(snapshot.data['members'][index])),
                          subtitle: Text(getId(snapshot.data['members'][index])),
                        ),
                      );
                    }


                );

              }else{
                return Center(child: Text("NO MEMBERS"),);
              }

            }else{
              return Center(child: Text("NO MEMBERS"),);
            }

          }else{
            return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),);
          }

        }

    );
  }
}
