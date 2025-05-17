import 'package:chatme/helper/helper_function.dart';
import 'package:chatme/pages/auth/loginpage.dart';
import 'package:chatme/pages/profilepage.dart';
import 'package:chatme/pages/searchpage.dart';
import 'package:chatme/service/auth_service.dart';
import 'package:chatme/service/database_service.dart';
import 'package:chatme/widgets/grouptile.dart';
import 'package:chatme/widgets/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class Homepage extends StatefulWidget{

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String userName = "";
  String email = "";
  Authservice authservice = Authservice();
  Stream? groups;
  bool _isloading = false;
  String groupName = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gettingUserData();
  }

  //string manipulation
  String getId(String res){
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res){
    return res.substring(res.indexOf("_")+1
    );
  }

  gettingUserData() async {
    await HelperFunction.getUserEmailFromSF().then((value) =>
    {
      setState(() {
        email = value!;
      })
    });
    await HelperFunction.getUserNameFromSF().then((value) =>
    {
      setState(() {
        userName = value!;
      })
    });
    // getting the list of snapshot in out stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(onPressed: () {
            nextScreen(context, SearchPage());
          },
              icon: Icon(Icons.search, color: Colors.white,))
        ],
        backgroundColor: Theme
            .of(context)
            .primaryColor,
        centerTitle: true,
        title: Text("Connect Me", style: TextStyle(
            color: Colors.white, fontSize: 27,
            fontWeight: FontWeight.bold),),
        //
      ),
      drawer: Drawer(

        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(Icons.account_circle, size: 150, color: Colors.indigoAccent),
            SizedBox(height: 15),
            Text(userName, textAlign: TextAlign.center, style:
            TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
            Divider(height: 2),
            ListTile(
              onTap: () {},
              selectedColor: Theme
                  .of(context)
                  .primaryColor,
              selected: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.group),
              title: Text("Groups", style: TextStyle(color: Colors.black),),
            ),
            ListTile(
              onTap: () {
                nextScreenReplace(
                    context, ProfilePage(email: email, userName: userName));
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.person),
              title: Text("Profile", style: TextStyle(color: Colors.black),),
            ),
            ListTile(
              onTap: () async {
                showDialog(context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Logout"),
                        content: Text("Are you sure you want to logout"),
                        actions: [
                          IconButton(onPressed: () {
                            Navigator.pop(context);
                          },
                              icon: Icon(Icons.cancel, color: Colors.red)
                          ),
                          IconButton(onPressed: () async {
                            await authservice.signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => Loginpage()),
                                    (route) => false);
                          },
                              icon: Icon(Icons.done, color: Colors.green,)
                          ),
                        ],
                      );
                    });
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: Icon(Icons.exit_to_app),
              title: Text("Logout", style: TextStyle(color: Colors.black),),
            )


          ],
        ),
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Theme
            .of(context)
            .primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 30,),
      ),
    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context){
      return AlertDialog(
        title: Text("Create a Group",textAlign: TextAlign.left,),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isloading == true? Center(
              child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),
            )
                : TextField(
               onChanged: (val){
                 setState(() {
                   groupName = val;
                 });
               },
              style:  TextStyle(color: Colors.black),
              decoration: InputDecoration(
                enabledBorder:  OutlineInputBorder(
                  borderSide:  BorderSide(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(20)
                ),
               errorBorder:  OutlineInputBorder(
                borderSide:  BorderSide(color: Colors.red),
                 borderRadius: BorderRadius.circular(20)
                  ),
                 focusedBorder:  OutlineInputBorder(
               borderSide:  BorderSide(color: Theme.of(context).primaryColor),
             borderRadius: BorderRadius.circular(20)
               )
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text("Cancel",style: TextStyle(color: Colors.white),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if(groupName != ""){
                setState(() {
                  _isloading= true;
                });
                DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                    .createGroup(userName, FirebaseAuth.instance.currentUser!.uid, groupName)
                    .whenComplete(() {
                      _isloading = false;
                });
                Navigator.of(context).pop();
                showSnackbar(context, Colors.green, "Group created successfully");

              }
            },
            child: Text("Create",style: TextStyle(color: Colors.white),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
          )
        ],
      );
        });
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        //checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,

                  itemBuilder: (context, index){
                    int reverseIndex = snapshot.data['groups'].length - index - 1;
                  return GroupTile(
                      groupName: getName(snapshot.data['groups'][reverseIndex]),
                      userName: snapshot.data['fullname'],
                      groupId: getId(snapshot.data['groups'][reverseIndex])

                  );
                  }

                  );
            } else {
              return noGroupsWidget();
            }
          } else {
            return noGroupsWidget();
          }
        } else {
          return Center(child: CircularProgressIndicator(color: Theme
              .of(context)
              .primaryColor));
        }
      },
    );
  }

  noGroupsWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: (){
              popUpDialog(context);
            },
              child: Icon(Icons.add_circle, color: Colors.purpleAccent, size: 75,)),
          SizedBox(height: 20,),

          Text("You have not joined any groups, tap on the add icon to create a group.",
            textAlign: TextAlign.center,),
        ],
      ),
    );
  }
}