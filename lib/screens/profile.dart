// import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:tellme/api/api.dart';
import 'package:tellme/helper/dialog.dart';
import 'package:tellme/models/chat_user.dart';
import 'package:tellme/screens/auth_screen.dart/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tellme/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final ChatUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _image;
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'My Profile',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              tooltip: 'Sign out',
              onPressed: () async {
                Dialogs.showProgressbar(context);
                await Apis.updateOnlineStatus(false);
                await Apis.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Apis.auth = FirebaseAuth.instance;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  });
                });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                SizedBox(height: md.height * 0.03),
                // Premium Profile Card
                Center(
                  child: Container(
                    width: md.width * 0.85,
                    padding: EdgeInsets.symmetric(vertical: md.height * 0.04),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withAlpha(50) : Colors.black.withAlpha(15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            _image != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    md.height * 0.1,
                                  ),
                                  child: Image.file(
                                    File(_image!),
                                    height: md.height * 0.18,
                                    width: md.height * 0.18,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    md.height * 0.1,
                                  ),
                                  child: CachedNetworkImage(
                                    height: md.height * 0.18,
                                    width: md.height * 0.18,
                                    fit: BoxFit.cover,
                                    imageUrl: widget.user.image.toString(),
                                    placeholder:
                                        (context, imageUrl) =>
                                            const CircularProgressIndicator(),
                                    errorWidget:
                                        (context, url, error) =>
                                            const CircleAvatar(
                                              backgroundColor: Colors.grey,
                                              child: Icon(
                                                CupertinoIcons.person,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                            ),
                                  ),
                                ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: MaterialButton(
                                elevation: 3,
                                onPressed: _showModelBottomSheet,
                                color: const Color(0xFF6200EA),
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(10),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: md.height * 0.03),
                        Text(
                          widget.user.email.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: md.height * 0.04),

                // Edit Details Section
                Container(
                  width: md.width * 0.85,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withAlpha(50) : Colors.black.withAlpha(15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Name Input
                      TextFormField(
                        initialValue: widget.user.name,
                        onSaved:
                            (newValue) => Apis.mySelf!.name = newValue ?? '',
                        validator:
                            (value) =>
                                value != null && value.isNotEmpty
                                    ? null
                                    : 'Required field',
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Color(0xFF6200EA),
                          ),
                          hintText: 'e.g. John Doe',
                          labelText: 'Name',
                          labelStyle: const TextStyle(color: Color(0xFF6200EA)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF6200EA),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // About Input
                      TextFormField(
                        initialValue: widget.user.about,
                        onSaved:
                            (newValue) => Apis.mySelf!.about = newValue ?? '',
                        validator:
                            (value) =>
                                value != null && value.isNotEmpty
                                    ? null
                                    : 'Required field',
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.info_outline,
                            color: Color(0xFF6200EA),
                          ),
                          hintText: 'e.g. Feeling happy',
                          labelText: 'About',
                          labelStyle: const TextStyle(color: Color(0xFF6200EA)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF6200EA),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (_formkey.currentState!.validate()) {
                              _formkey.currentState!.save();
                              await Apis.updateUserData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'User details updated successfully!',
                                  ),
                                  backgroundColor: Color(0xFF6200EA),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6200EA),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          label: const Text(
                            'Update Profile',
                            style: TextStyle(fontSize: 16),
                          ),
                          icon: const Icon(Icons.save),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: md.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showModelBottomSheet() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: md.width * .10,
            vertical: md.height * .03,
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
          height: md.height * .3,
          child: Column(
            children: [
              const Text(
                'Pick Profile Picture',
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF6200EA),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: md.height * .04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _bottomSheetButton(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        Apis.updateProfilePic(File(_image!));
                        Navigator.pop(context);
                      }
                    },
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                  ),
                  _bottomSheetButton(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        Apis.updateProfilePic(File(_image!));
                        Navigator.pop(context);
                      }
                    },
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomSheetButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF6200EA)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
