import 'package:chatme/pages/homepage.dart';
import 'package:chatme/widgets/widget.dart';
import 'package:flutter/material.dart';

import '../service/auth_service.dart';
import 'auth/loginpage.dart';

class ProfilePage extends StatefulWidget{
  String userName;
  String email;
  ProfilePage({Key? key,required this.email,required this.userName}) : super(key: key);
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Authservice authservice = Authservice();
  @override
  Widget build(BuildContext context){
    return Scaffold(
     appBar: AppBar(
       backgroundColor: Theme.of(context).primaryColor,
       elevation: 0,
       title: Text("Profile", style:
       TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),),
     ),
      drawer: Drawer(
        child: ListView(
        padding: EdgeInsets.symmetric(vertical: 50),
        children: <Widget> [
          Icon(Icons.account_circle,size: 150,color: Colors.indigoAccent),
          SizedBox(height: 15),
          Text(widget.userName,textAlign: TextAlign.center,style:
          TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
          Divider(height: 2),
          ListTile(
            onTap: (){
              nextScreen(context, Homepage());
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
            leading: Icon(Icons.group),
            title: Text("Groups",style: TextStyle(color: Colors.black),),
          ),
          ListTile(
            onTap: (){},
            selectedColor: Theme.of(context).primaryColor,
            selected: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
            leading: Icon(Icons.person),
            title: Text("Profile",style: TextStyle(color: Colors.black),),
          ),
          ListTile(
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (context){
                    return AlertDialog(
                      title: Text("Logout"),
                      content: Text("Are you sure you want to logout"),
                      actions: [
                        IconButton(onPressed:() {Navigator.pop(context);},
                            icon: Icon(Icons.cancel,color: Colors.red)
                        ),
                        IconButton(onPressed:() async {
                          await authservice.signOut();
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Loginpage()),
                                  (route) => false);
                        },
                            icon: Icon(Icons.done,color: Colors.green,)
                        ),
                      ],
                    );
                  });

            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
            leading: Icon(Icons.exit_to_app),
            title: Text("Logout",style: TextStyle(color: Colors.black),),
          )
        ],
      ),),

      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30,vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.account_circle,size: 170,color: Colors.indigoAccent),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Full Name ",style: TextStyle(fontSize: 17)),
                Text(widget.userName,style: TextStyle(fontSize: 17)),
              ],
            ),
            Divider(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Email ",style: TextStyle(fontSize: 17)),
                Text(widget.email,style: TextStyle(fontSize: 17)),
              ],
            )
            
          ],
        ),
      ),
    );
  }
}