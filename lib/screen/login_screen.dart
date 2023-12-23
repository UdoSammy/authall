// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:authall/provider/internet_provider.dart';
import 'package:authall/provider/sign_in_provider.dart';
import 'package:authall/screen/home_screen.dart';
import 'package:authall/utils/next_screen.dart';
import 'package:authall/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final RoundedLoadingButtonController googleController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController facebookController =
      RoundedLoadingButtonController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 40, right: 40, top: 90, bottom: 30),
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: Column(
                children: [
                  Image.asset(
                    'images/splash.png',
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const Text(
                    'Welcome to FlutterAuth',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Flutter Auth with Provider',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundedLoadingButton(
                  controller: googleController,
                  onPressed: () {
                    handleGoogleSignIn();
                  },
                  successColor: Colors.red,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child:  Wrap(
                    children: const [
                      Icon(
                        FontAwesomeIcons.google,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                  color: Colors.red,
                ),

                //facebook login button

                const SizedBox(height: 15,),
                RoundedLoadingButton(
                  controller: facebookController,
                  onPressed: () {},
                  successColor: Colors.blue,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child:  Wrap(
                    children: const [
                      Icon(
                        FontAwesomeIcons.facebook,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Text(
                        'Sign in withFacebook',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                  color: Colors.blue,
                ),
              ],
            )
          ],
        ),
      ),
    ));
  }


  


  Future handleGoogleSignIn() async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();

    await ip.checkInternetConnection();

    if(ip.hasInternet == false){
      openSnackBar(context, 'Check your internet connection', Colors.red);
      googleController.reset();
    }else{
      await sp.signInWithGoogle().then((value){
        if(sp.hasError == true){
          openSnackBar(context, sp.errorCode.toString(), Colors.red);
          googleController.reset();
        }else{
          
          sp.checkUserExists().then((value) async{
            if(value == true){

            }else{
             
              sp.saveDataToFirestore().then((value) => sp.saveDataToSharedPreferences().then((value) => sp.setSignIn().then((value) {
                googleController.success();
                handleAfterSignIn();
                })));
            }
          });
        }
      });
    }
  }


handleAfterSignIn() {
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      nextScreenReplace(context, const HomeScreen());
    });
  }
}
