import 'package:chatme/master_page.dart';
import 'package:chatme/pages/auth/registerpage.dart';
import 'package:chatme/service/auth_service.dart';
import 'package:chatme/service/database_service.dart';
import 'package:chatme/shared/constant.dart';
import 'package:chatme/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../helper/helper_function.dart';
import '../homepage.dart';

class Loginpage extends StatefulWidget{
  @override
  State<Loginpage> createState() => _LoginpageState();
}
class _LoginpageState extends State<Loginpage> {
  final formkey = GlobalKey<FormState>();
   bool _isloading = false;
    String email = "";
    String password = "";
  Authservice authservice = Authservice();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: _isloading? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor),)
          :SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 80),
          child: Form(
            key: formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("ChatMe",style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold,
                    color: Color(0xFF432C81)),),
                SizedBox(height: 10),
                 Text("Login now to see what they are takling!!!",style: TextStyle(
                  fontWeight: FontWeight.bold,fontSize: 15,color:Color(0xFF432C81),
                 ),
                ),
                Image.asset("assets/images/loginp.jpg"),
                SizedBox(height: 35),
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                    labelText:"Email",
                    prefixIcon:Icon(CupertinoIcons.mail_solid,color: Theme.of(context).primaryColor),),
                  onChanged: (val){
                    setState(() {
                      email = val;
                    });
                  },
                  //validaot for email
                  validator: (val){
                    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val!)
                        ? null : "Please Enter a valid Email";
                  },


                ),
                SizedBox(height: 25),
                TextFormField(
                  obscureText: true,
                    decoration: textInputDecoration.copyWith(
                      labelText:"Password",
                      prefixIcon:Icon(CupertinoIcons.lock_fill,color: Theme.of(context).primaryColor,),
                    ),
                  validator: (val) {
                    if(val!.length < 6){
                      return "Password must be atleast 6 charactor";
                    }
                    else {
                      return null;
                    }
                  },
                  onChanged: (val){
                    setState(() {
                      password = val;
                    });
                  },
                  ),
                SizedBox(height: 25,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor,
                        elevation: 0),
                    child: Text("Sign In",style: TextStyle(color: Colors.white,fontSize: 16),),
                    onPressed: (){
                      login();
                    },
                  ),
                ),
                SizedBox(height: 10,),
                Text.rich(TextSpan(
                  text: "Don't Have an account ? ",style: TextStyle(fontWeight: FontWeight.bold),
                  children:<TextSpan> [TextSpan(
                    text: "Register here",style: TextStyle(decoration:TextDecoration.underline ),
                    recognizer: TapGestureRecognizer()..onTap=(){nextScreen(context, RegisterPage());
                    },

                  )]
                ))


              ],
            ),
          ),
        ),
      )
    

    );
  }
  login() async {
    if(formkey.currentState!.validate()){
      setState(() {
        _isloading = true;
      });
      await authservice.loginUserWithEmailandPassword(email, password).then((value) async{
        if(value == true){
          QuerySnapshot snapshot = await DatabaseService(uid:
          FirebaseAuth.instance.currentUser!.uid).gettingUserData(email);
          //saving the values in shared preferences
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSF(email);
          await HelperFunction.saveUserNameSF(snapshot.docs[0]['fullname']);
          nextScreenReplace(context, MasterPage());
        } else {
          showSnackbar(context, Colors.red, value);
          setState(() {
            _isloading = false;
          });

        }
      });
    }
  }
}

