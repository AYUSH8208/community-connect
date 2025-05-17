import 'package:chatme/helper/helper_function.dart';
import 'package:chatme/master_page.dart';
import 'package:chatme/pages/auth/loginpage.dart';
import 'package:chatme/pages/homepage.dart';
import 'package:chatme/shared/constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;
  @override
  void initState() {
    super.initState();
    getUserLoggedInStatus();
  }
  getUserLoggedInStatus() async {
    await HelperFunction.getUserLoggedInStatus().then((value){
      if(value!=null){
        setState(() {
          _isSignedIn = value ;
        });

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(

        primaryColor: Constants().primaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
     debugShowCheckedModeBanner: false,
      home:_isSignedIn ? MasterPage(): Loginpage(),
    );

    }
}

