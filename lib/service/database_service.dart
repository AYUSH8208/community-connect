import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  //reference of our collection
  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  final CollectionReference groupsCollection = FirebaseFirestore.instance.collection("groups");

  //update the userdata
Future updateUserData(String fullname,String email) async {
  return await userCollection.doc(uid).set({
    "fullname": fullname,
    "email" : email,
    "groups" : [],
    "profilepic" : "",
    "uid" : uid,

  });
}
//getting user data
Future gettingUserData(String email) async {
  QuerySnapshot snapshot = await userCollection.where("email", isEqualTo: email).get();
  return snapshot;
}
// getting the user groups
 getUserGroups() async {
  return userCollection.doc(uid).snapshots();
 }

 // Creating a group

 Future createGroup(String userName,String id, String groupName) async {
  DocumentReference groupDocumentReference = await groupsCollection.add({
    "groupName" : groupName,
    "groupIcon" : "",
    "admin" : "${id}_$userName",
    "members" : [] ,
    "groupId" : "",
    "recentMessage" : "",
    "recentMessageSender" : "",
  });
  //update the members
   await groupDocumentReference.update({
     "members" : FieldValue.arrayUnion(["${uid}_$userName"]),
     "groupId" : groupDocumentReference.id,
   });

   DocumentReference userDocumentReference = userCollection.doc(uid);
   return await userDocumentReference.update({
     "groups" : FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
   });

 }
 getChats(String groupId) async {
  return groupsCollection
      .doc(groupId)
      .collection("messages")
      .orderBy("time")
      .snapshots();
 }
 Future getGroupAdmin(String groupId) async{
  DocumentReference d = groupsCollection.doc(groupId);
  DocumentSnapshot documentSnapshot = await d.get();
  return documentSnapshot['admin'];
 }
getGroupMembers(groupId) async {
  return groupsCollection.doc(groupId).snapshots();
}
//search
searchByName(String groupName){
  return groupsCollection.where("groupName",isEqualTo: groupName).get();
}
//function -> bool
Future<bool> isUserJoined(String groupName,String groupId,String userName) async {
  DocumentReference userDocumentReference = userCollection.doc(uid);
  DocumentSnapshot documentSnapshot = await userDocumentReference.get();

  List<dynamic> groups =  await documentSnapshot['groups'];
  if(groups.contains("${groupId}_$groupName")){
    return true;
  }else{
    return false;
  }
}
//toggling the group join or exit
Future toggleGroupJoin(String groupId,String userName,String groupName) async {
  // doc reference
  DocumentReference userDocumentReference = userCollection.doc(uid);
  DocumentReference groupDocumentReference = groupsCollection.doc(groupId);

  DocumentSnapshot documentSnapshot = await userDocumentReference.get();
  List<dynamic> groups = await documentSnapshot['groups'];

  //if user has our groups --> then remove then or arise in other part re join
  if(groups.contains("${groupId}_$groupName")){
    await userDocumentReference.update({
      "groups" : FieldValue.arrayRemove(["${groupId}_$groupName"])
    });
    await groupDocumentReference.update({
      "members" : FieldValue.arrayRemove(["${uid}_$userName"])
    });
  }else{
    await userDocumentReference.update({
      "groups" : FieldValue.arrayUnion(["${groupId}_$groupName"])
    });
    await groupDocumentReference.update({
      "members" : FieldValue.arrayUnion(["${uid}_$userName"])
    });
  }
}
//send
  sendMessage(String groupId,Map<String, dynamic> chatMessageData) async {
  groupsCollection.doc(groupId).collection("messages").add(chatMessageData);
  groupsCollection.doc(groupId).update({
    "recentMessage": chatMessageData['message'],
    "recentMessageSender": chatMessageData['sender'],
    "recentMessageTime" : chatMessageData['time'].toString()

  });
  }

}

