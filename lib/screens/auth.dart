import 'dart:io';

import 'package:chat_app/widget/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  File? _pickedImage; 
  bool _isAuthenticating = false;
  var _enteredEmail = '';
  var _enteredPass = '';
  var _enteredName = '';
  final _form = GlobalKey<FormState>();

  void _submit() async {
    var isValid = _form.currentState!.validate();

    if (!isValid || (!_isLogin &&( _pickedImage == null))) {
      if(_isLogin && _pickedImage == null){
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image is required")));
      }

      return;
    }

    _form.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        var userCradentials = await _firebase.signInWithEmailAndPassword(email: _enteredEmail, password: _enteredPass);
      } else {
        var userCradentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPass,
        );

        final storageFileRef =  FirebaseStorage.instance.ref().child('users_images').child('${userCradentials.user!.uid}.jpg');

        await storageFileRef.putFile(_pickedImage!);

        final imageUrl = await storageFileRef.getDownloadURL();
        await FirebaseFirestore.instance.collection('users').doc('${userCradentials.user!.uid}').set({
          'user_name':_enteredName,
          'email':_enteredEmail,
          'image': imageUrl
        });
        
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? "Authentication Fialed")),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset("assets/images/chat.png"),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: .min,
                        children: [
                          if(!_isLogin)
                          UserImagePicker(pickedImage: (pickedImage){
                            _pickedImage = pickedImage;

                          
                          },),
                          if(!_isLogin)
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Name'),
                            enableSuggestions: false,
                            validator: (value) {
                              if(value == null || value.trim().isEmpty || value.trim().length <4){
                                return 'Insert atleast 4 characters';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredName = newValue!;
                            },

                          ),
                          TextFormField(
                            decoration: InputDecoration(label: Text("Email")),
                            textCapitalization: .none,
                            autocorrect: false,
                            keyboardType: .emailAddress,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Entere valid email address';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              label: Text("Password"),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password should have atlease 6 characters';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPass = value!;
                            },
                          ),
                          SizedBox(height: 12),
                          if(_isAuthenticating)
                          const CircularProgressIndicator(),
                          if(!_isAuthenticating)
                          ElevatedButton(
                            onPressed: _submit,
                            child: Text(!_isLogin ? "Sign Up" : "Log In"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                          ),
                          if(!_isAuthenticating)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? "Create an account"
                                  : "Already have an account",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
