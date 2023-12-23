import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInProvider extends ChangeNotifier {
  // instance of firebaseauth, google and facebook

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  // hasError, errorCode, provider, uid, email, name, imageurl

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _provider;
  String? get provider => _provider;

  String? _uid;
  String? get uid => _uid;

  String? _email;
  String? get email => _email;

  String? _name;
  String? get name => _name;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  SignInProvider() {
    checkSignedInUser();
  }

  Future checkSignedInUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    _isSignedIn = sp.getBool('signed_in') ?? false;
    notifyListeners();
  }


  Future setSignIn() async{
    final SharedPreferences sp = await SharedPreferences.getInstance();

    sp.setBool('signed_in', true);
    _isSignedIn = true;
    notifyListeners();
  }

  // signIn with google
  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();

    if (googleSignInAccount != null) {
      // execute authentication

      try {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);

        // sign to firebase user instance

        final User userDetails =
            (await _firebaseAuth.signInWithCredential(credential)).user!;

        // saving user details

        _name = userDetails.displayName;
        _email = userDetails.email;
        _imageUrl = userDetails.photoURL;
        _provider = 'GOOGLE';
        _uid = userDetails.uid;
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'account-exists-with-different-credentail':
            'You already have an acount. Use corrent accout';
            _hasError = true;
            notifyListeners();
            break;

          case 'null':
            'Some unexpected error occured while signing in';
            _hasError = true;
            notifyListeners();
            break;

          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  // entry for cloudfirestore
  Future getUserDataFromFirestore() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) => {
          _uid = snapshot['uid'],
          _name = snapshot['name'],
          _email = snapshot['email'],
          _imageUrl = snapshot['image_url'],
          _provider = snapshot['provider']
        });
  }



  // saving data to cloud firestore

  Future saveDataToFirestore() async{
    final DocumentReference r = FirebaseFirestore.instance.collection('users').doc(uid);

    await r.set({
      'name': _name,
      'email': _email,
      'uid': _uid,
      'imageUrl': _imageUrl,
      'provider': _provider
    });
    notifyListeners();
  }


  // save data to shareed prefrences
  Future saveDataToSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();

    await s.setString('name', _name!);
    await s.setString('email', _email!);
    await s.setString('uid', _uid!);
    await s.setString('imageUrl', _imageUrl!);
    await s.setString('provider', _provider!);
    notifyListeners();
  }

  // check if user exist in firestore
  Future<bool> checkUserExists() async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if (snap.exists) {
      print('existing user');
      return true;
    } else {
      print('new user');
      return false;
    }
  }

  Future userSignOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    _isSignedIn = false;
    notifyListeners();

    // future

    clearStoredData();
  }

  Future clearStoredData() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.clear();
  }
}
