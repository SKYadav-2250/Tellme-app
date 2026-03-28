// import 'dart:nativewrappers/_internal/vm/lib/developer.dart';
import 'dart:developer' as dev;
import 'dart:math';
// import 'dart:nativewrappers/_internal/vm/lib/developer.dart';

import 'package:tellme/api/api.dart';
import 'package:tellme/helper/dialog.dart';
import 'package:tellme/main.dart';
import 'package:tellme/models/chat_user.dart';
// import 'package:tellme/screens/auth_screen.dart/login_screen.dart';
import 'package:tellme/screens/profile.dart';
import 'package:tellme/widgets/chat_user_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];

  Future<void> fetchData() async {
    // Reference to the 'users' collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    try {
      // Fetch all documents in the collection
      QuerySnapshot querySnapshot = await users.get();

      // Iterate over the documents and access data
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('User Name: ${data['name']}');
        print('User Email: ${data['email']}');
        // Access other fields as needed
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  final List<ChatUser> _searchList = [];
  bool _isSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Apis.getSelfInfo();

    SystemChannels.lifecycle.setMessageHandler((handler) {
      dev.log('message: ${handler.toString()}');
      if (Apis.auth.currentUser != null) {
        if (handler.toString().contains('resume')) {
          Apis.updateOnlineStatus(true);
        }
        if (handler.toString().contains('pause')) {
          Apis.updateOnlineStatus(false);
        }
      }
      return Future.value(handler);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: !_isSearch,
        onPopInvokedWithResult: (didPop, result) {
          if (_isSearch) {
            setState(() {
              _isSearch = false;
              _searchController.clear();
              _searchList.clear();
            });
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  _isSearch
                      ? TextField(
                        key: const ValueKey(1),
                        controller: _searchController,
                        autofocus: true, // Focus when search opens
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: md.height * .015,
                            horizontal: md.width * .05,
                          ), // R
                          hintText: "Search chat...",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Colors.grey,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchList.clear();
                            for (var i in _list) {
                              if (i.name!.toLowerCase().contains(
                                    value.toLowerCase(),
                                  ) ||
                                  i.email!.toLowerCase().contains(
                                    value.toLowerCase(),
                                  )) {
                                _searchList.add(i);
                              }

                              setState(() {
                                _searchList;
                              });
                            }
                          });
                        },
                      )
                      : Text(
                        'tellme',
                        key: const ValueKey(2),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                          letterSpacing: -0.5,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isSearch ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearch = !_isSearch;
                    _searchController.clear(); // Clear text when search closes
                  });
                },
              ),

              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(user: Apis.mySelf!),
                    ),
                  );
                },
                icon: Icon(Icons.more_vert),
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              _addChatuserDialog();
            },
            elevation: 4,
            backgroundColor: const Color(0xFF6200EA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
            ),
            label: const Text(
              'Add User',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          body: StreamBuilder(
            stream: Apis.getMyusersId(),
            builder: (context, snapshot) {
              if (snapshot.data?.docs != null) {
                dev.log('apis call is ${snapshot.data?.docs}');

                return StreamBuilder(
                  stream: Apis.getAllUsers(
                    snapshot.data?.docs.map((element) => element.id).toList() ??
                        [],
                  ),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(child: CircularProgressIndicator());

                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs ?? [];

                        _list =
                            data
                                .map(
                                  (element) =>
                                      ChatUser.fromJson(element.data()),
                                )
                                .toList();

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            itemCount:
                                _isSearch ? _searchList.length : _list.length,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ChatUserCard(
                                user:
                                    _isSearch
                                        ? _searchList[index]
                                        : _list[index],
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: Text(
                              'No users found',
                              style: TextStyle(fontSize: 20),
                            ),
                          );
                        }
                    }
                  },
                );
              } else {
                return const Center(
                  child: Text('No users found', style: TextStyle(fontSize: 20)),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _addChatuserDialog() {
    String email = '';

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),

          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.people_alt, color: Colors.blueAccent, size: 26),
              Text('User Email', style: TextStyle(fontSize: 18)),
            ],
          ),

          content: TextFormField(
            // initialValue: updateMsg,
            maxLines: null,
            onChanged: (value) => email = value,
            decoration: InputDecoration(
              hintText: 'Email ..',
              labelText: 'Email Id',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),

            // maxLines: 5,
          ),

          contentPadding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: 5,
          ),

          actions: [
            // ElevatedButton(onPressed: onPressed, child: child)
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
            ),
            MaterialButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (email.isNotEmpty) {
                  await Apis.addchatuser(email).then((onValue) {
                    Dialogs.showSnackbar(context, 'Not ble to find user', true);
                  });
                }
              },
              child: Text(
                'Add',
                style: TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}
