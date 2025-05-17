import 'package:chatme/helper/helper_function.dart';
import 'package:chatme/master_page.dart';
import 'package:chatme/pages/auth/loginpage.dart';
import 'package:chatme/pages/homepage.dart';
import 'package:chatme/service/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../widgets/widget.dart';

class RegisterPage extends StatefulWidget{
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formkey = GlobalKey<FormState>();
  String email = "";
  String fullname = "";
  String password = "";
  bool _isloading = false;
  Authservice authservice = Authservice();
  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: _isloading ? Center(child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor
          ),) : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 80),
            child: Form(
              key: formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("ChatMe",style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold,color: Color(0xFF432C81)),),
                  SizedBox(height: 10),
                  const Text("Create your Account now to chat and Explore",style: TextStyle(
                      fontWeight: FontWeight.bold,fontSize: 15,color:Color(0xFF432C81)),
                  ),
                  Image.asset("assets/images/loginp.jpg"),
                  SizedBox(height: 15),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                      labelText:"Full Name",
                      prefixIcon:Icon(CupertinoIcons.person_alt,color: Theme.of(context).primaryColor),),
                    onChanged: (val){
                      setState(() {
                        fullname = val;
                      });
                    },
                    //validator for person
                    validator: (val){
                     if(val!.isNotEmpty){
                       return null;
                     }else{
                       return "Name Cannot be empty";
                     }
                    },

                  ),
                  SizedBox(height: 15),

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

                  SizedBox(height: 15),
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
                      child: Text("Register",style: TextStyle(color: Colors.white,fontSize: 16),),
                      onPressed: (){
                      register();
                      },
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text.rich(TextSpan(
                      text: "Already Have an account ? ",style: TextStyle(fontWeight: FontWeight.bold),
                      children:<TextSpan> [TextSpan(
                        text: "Login here",style: TextStyle(decoration:TextDecoration.underline ),
                        recognizer: TapGestureRecognizer()..onTap=(){nextScreen(context, Loginpage());
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
  register() async{
    if(formkey.currentState!.validate()){
      setState(() {
        _isloading = true;
      });
      await authservice.registerUserWithEmailandPassword(fullname, email, password).then((value) async{
        if(value == true){
          //saving the shared preference state
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSF(email);
          await HelperFunction.saveUserNameSF(fullname);
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

