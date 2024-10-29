import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'login_screen.dart';
import 'package:gradient_elevated_button/gradient_elevated_button.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  File? _pickedImage;

  FocusNode _usernameFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _requestPermission();

    _usernameFocusNode.addListener(() {
      setState(() {});
    });
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  void _showErrorDialog(String message) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 229, 229),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Error',
            style: TextStyle(
              color: Color.fromARGB(255, 86, 107, 211),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 86, 107, 211),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOut,
          )),
          child: child,
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedImageFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImageFile != null) {
      setState(() {
        _pickedImage = File(pickedImageFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('${_auth.currentUser?.uid}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    if (_pickedImage == null) {
      _showErrorDialog('Please select a profile image.');
      return;
    }

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorDialog('Please fill out all fields.');
      return;
    }

    if (password.length < 6) {
      _showErrorDialog('Password must be at least 6 characters long.');
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final imageUrl = await _uploadImage(_pickedImage!);

      await userCredential.user?.updateProfile(
        displayName: username,
        photoURL: imageUrl,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      _showErrorDialog('Signup failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 86, 107, 211),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                const SizedBox(height: 30),
                const Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sign up to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      TextField(
                        focusNode: _usernameFocusNode,
                        controller: _usernameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person,
                              color: Color.fromARGB(255, 86, 107, 211)),
                          hintText:
                              _usernameFocusNode.hasFocus ? '' : 'Username',
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 86, 107, 211),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        focusNode: _emailFocusNode,
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email,
                              color: Color.fromARGB(255, 86, 107, 211)),
                          hintText: _emailFocusNode.hasFocus ? '' : 'Email',
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 86, 107, 211),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock,
                              color: Color.fromARGB(255, 86, 107, 211)),
                          hintText:
                              _passwordFocusNode.hasFocus ? '' : 'Password',
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 86, 107, 211),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Divider(
                  color: Colors.transparent,
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                GradientElevatedButton(
                  onPressed: _signup,
                  style: GradientElevatedButton.styleFrom(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 42, 59, 92),
                        Color.fromARGB(255, 58, 80, 148),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    fixedSize: const Size(340, 55),
                  ),
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: -175,
            left: -175,
            right: -175,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 7, 8, 9).withOpacity(0.2),
                    spreadRadius: 10,
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),

          // Positioned(
          //   top: MediaQuery.of(context).size.height * 0.07,
          //   left: 0,
          //   right: 0,
          //   child: GestureDetector(
          //     onTap: _pickImage,
          //     child: CircleAvatar(
          //       radius: 80,
          //       backgroundColor: Colors.grey,
          //       backgroundImage:
          //           _pickedImage != null ? FileImage(_pickedImage!) : null,
          //       child: _pickedImage == null
          //           ? Icon(Icons.person, size: 80, color: Colors.white)
          //           : null,
          //     ),
          //   ),
          // ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.07,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.grey,
                child: _pickedImage != null
                    ? ClipOval(
                        child: Image.file(
                          _pickedImage!,
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.person, size: 80, color: Colors.white),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                icon: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.04),
                      shape: BoxShape.circle),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 15,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
