import 'package:chatme/helper/helper_function.dart';
import 'package:chatme/service/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authservice {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // login
  Future loginUserWithEmailandPassword (String email,String password)
  async {
    try {
      User user = (
          await firebaseAuth.signInWithEmailAndPassword(email: email, password: password))
          .user!;
      if(user!= null){

        return true;

      }


    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

// register
Future registerUserWithEmailandPassword (String fullname, String email,String password)
  async {
  try {
   User user = (
       await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password))
       .user!;
    if(user!= null){
     await DatabaseService(uid: user.uid).updateUserData(fullname, email);
      return true;

    }


  } on FirebaseAuthException catch (e) {
    return e.message;
  }
}

// signout
Future signOut() async {
  try{
    await HelperFunction.saveUserLoggedInStatus(false);
    await HelperFunction.saveUserNameSF("");
    await HelperFunction.saveUserEmailSF("");
    await firebaseAuth.signOut();
  } catch (e){
    return null;
  }

}

}