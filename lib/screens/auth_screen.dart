import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../widgets/auth/auht_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _submitAuthForm(
    String email,
    String userName,
    String password,
    File image,
    bool login,
    BuildContext ctx,
  ) async {
    var user;
    try {
      setState(() {
        _isLoading = true;
      });
      if (login) {
        user = (await _auth.signInWithEmailAndPassword(
                email: email, password: password))
            .user;
      } else {
        user = (await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ))
            .user;

        final ref = await  FirebaseStorage.instance.ref().child('user_Image').child(_auth.currentUser.uid + 'jpg');
        await ref.putFile(image).onComplete;

        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'username': userName,
            'email': email,
            'image_url' : url,
          },
        );
      }
    } catch (err) {
      var message = 'An error occurred , please check your credentials!';
      if (err.message != null) {
        message = err.message;
      }
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
//    catch (e) {
//      print(e);
//      setState(() {
//        _isLoading = false;
//      });
//    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}
