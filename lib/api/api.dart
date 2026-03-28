import 'dart:developer' as developer;
import 'dart:io';
import 'package:tellme/api/api_notification.dart';
import 'package:tellme/models/chat_user.dart';
import 'package:tellme/models/message.dart' as chat_app_message;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Apis {
  static ChatUser? mySelf;

  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  static User? get user => auth.currentUser;

  static Future<bool> userExists() async {
    if (user == null) return false;
    return (await firestore.collection('users').doc(user!.uid).get()).exists;
  }

  static Future<void> getSelfInfo() async {
    if (user == null) throw Exception('No authenticated user');
    await firestore.collection('users').doc(user!.uid).get().then((doc) async {
      if (doc.exists) {
        mySelf = ChatUser.fromJson(doc.data()!);
        await setUpPushNotification();
        await updateOnlineStatus(true);
        developer.log('My Data: ${doc.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<void> createUser() async {
    if (user == null) throw Exception('No authenticated user');
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final newUser = ChatUser(
      image: user!.photoURL ?? 'https://default-image-url.com',
      about: 'Hey, I\'m using my app',
      name: user!.displayName ?? 'Anonymous',
      createdAt: time,
      isOnline: false,
      lastActive: time,
      id: user!.uid,
      email: user!.email ?? '',
      pushToken: '',
    );
    await firestore.collection('users').doc(user!.uid).set(newUser.toJson());
    developer.log('User created at: $time');
  }

  static Future<void> updateUserData() async {
    if (mySelf == null) throw Exception('User not initialized');
    await firestore.collection('users').doc(user?.uid).update({
      'name': mySelf!.name,
      'about': mySelf!.about,
    });
  }

  static Future<void> updateProfilePic(File file) async {
    if (user == null || mySelf == null) throw Exception('User not initialized');
    final ext = file.path.split('.').last;
    final ref = firebaseStorage.ref().child(
      'profile_picture/${user!.uid}.$ext',
    );
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    mySelf!.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user!.uid).update({
      'image': mySelf!.image,
      'about': mySelf!.about,
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
    ChatUser user,
  ) {
    return firestore
        .collection('chats/${getConversationID(user.id.toString())}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static String getConversationID(String id) {
    return user!.uid.hashCode <= id.hashCode
        ? '${user!.uid}_$id'
        : '${id}_${user!.uid}';
  }

  static Future<void> sendMessage(
    ChatUser chatuser,
    String msg,
    chat_app_message.MessageType type,
  ) async {
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();
      final message = chat_app_message.Message(
        toId: chatuser.id.toString(),
        msg: msg,
        read: '',
        type: type,
        fromId: user!.uid,
        sent: time,
      );

      final chatId = getConversationID(chatuser.id.toString());
      final ref = firestore.collection('chats').doc(chatId);
      await ref.set({
        'participants': [user!.uid, chatuser.id],
      }, SetOptions(merge: true));
      await ref
          .collection('messages')
          .doc(time)
          .set(message.toJson())
          .then(
            (value) => ApiNotification.sendNotification(
              chatuser,
              message,
              message.type == chat_app_message.MessageType.text
                  ? msg
                  : ' Send an Image ',
            ),
          );
    } catch (e) {
      developer.log('Error sending message: $e');
    }
  }

  static Future<void> updateMessageReadStatus(
    chat_app_message.Message message,
  ) async {
    await firestore
        .collection('chats/${getConversationID(message.fromId)}/messages')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
    ChatUser user,
  ) {
    return firestore
        .collection('chats/${getConversationID(user.id.toString())}/messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = firebaseStorage.ref().child(
      'images/${getConversationID(chatUser.id.toString())}/${DateTime.now().millisecondsSinceEpoch}.$ext',
    );
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, chat_app_message.MessageType.image);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
    ChatUser chatUser,
  ) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateOnlineStatus(bool isOnline) async {
    if (mySelf == null) return;
    await firestore.collection('users').doc(user?.uid).update({
      'isOnline': isOnline,
      'lastActive': DateTime.now().millisecondsSinceEpoch.toString(),
      'pushToken': mySelf!.pushToken,
    });
  }

  static Future<void> setUpPushNotification() async {
    try {
      NotificationSettings settings = await firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await firebaseMessaging.getToken();
        if (token != null && mySelf != null) {
          mySelf!.pushToken = token;
          await updateOnlineStatus(true);
          developer.log('Push Token: $token');
        }
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log('Got a message whilst in the foreground!');
        developer.log('Message data: ${message.data}');

        if (message.notification != null) {
          developer.log(
            'Message also contained a notification: ${message.notification}',
          );
        }
      });
    } catch (e) {
      developer.log('Error setting up push notifications: $e');
    }
  }

  static void tokenUpdate() {
    firebaseMessaging.onTokenRefresh.listen((token) async {
      if (mySelf != null) {
        mySelf!.pushToken = token;
        await updateOnlineStatus(true);
        developer.log('Token refreshed: $token');
      }
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getChattedusers() {
    final currentUserId = user!.uid.toString();

    return firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .asyncMap((chatsnapshot) async {
          final List<String> chattedUsers = [];
          for (var chat in chatsnapshot.docs) {
            String chatId = chat.id;

            List<String> ids = chatId.split('_');
            String otherUserId = ids.firstWhere((id) => id != currentUserId);
            chattedUsers.add(otherUserId);
          }

          if (chattedUsers.isEmpty) {
            return firestore.collection('users').limit(0).snapshots().first;
          }

          return await firestore
              .collection('users')
              .where('id', whereIn: chattedUsers)
              .snapshots()
              .first;
        });
  }

  static Future<void> deleteMessage(chat_app_message.Message message) async {
    developer.log("message ${message.msg}");
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == chat_app_message.MessageType.image) {
      developer.log('message.msg  --  ${message.msg}');

      await firebaseStorage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> updateMessage(
    chat_app_message.Message message,
    String updatedMsg,
  ) async {
    developer.log("message ${message.msg}");
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }

  static Future<bool> addchatuser(String email) async {
    final data =
        await firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

    if (data.docs.isNotEmpty) {
      firestore
          .collection('users')
          .doc(user!.uid)
          .collection('my-users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      return false;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
    List<String?> userId,
  ) {
    if (userId.isNotEmpty) {
      return firestore
          .collection('users')
          .where('id', whereIn: userId)
          .snapshots();
    } else {
      return Stream.empty();
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyusersId() {
    return firestore
        .collection('users')
        .doc(user!.uid)
        .collection('my-users')
        .snapshots();
  }

  static Future<void> sendFirstMessage(
    ChatUser chatuser ,String msg , chat_app_message.MessageType type
  ) async {
    await firestore.collection('users')
    .doc(chatuser.id).collection('my-users')
    .doc(user!.uid).set({}).then((onValue)=>sendMessage(chatuser, msg, type));
  }
}
