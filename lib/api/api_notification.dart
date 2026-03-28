import 'dart:convert';
import 'dart:developer';

import 'package:tellme/api/api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
// import 'package:googleapis/storage/v1.dart'as serviceControl;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:tellme/models/chat_user.dart';
import 'package:tellme/models/message.dart';

class ApiNotification {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": dotenv.env['PROJECT_ID'] ?? "NOT FOUND",
      "private_key_id": dotenv.env['PROJECT_KEY_ID'] ?? "NOT FOUND",
      "private_key": dotenv.env['PRIVATE_KEY'] ?? "NOT FOUND",
      "client_email":
          "firebase-adminsdk-fbsvc@flutter-project-55b71.iam.gserviceaccount.com",
      "client_id": dotenv.env['CLIENT_ID'] ?? "NOT FOUND",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": dotenv.env['CLIENT_URL'] ?? "NOT FOUND",
      "universe_domain": "googleapis.com",
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    //get access token
    auth.AccessCredentials credentials = await auth
        .obtainAccessCredentialsViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
          scopes,
          client,
        );

    client.close();

    return credentials.accessToken.data;
  }

  static sendNotification(
    ChatUser user,
    Message userMessage,
    String msg,
  ) async {
    DocumentSnapshot getTitle =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userMessage.fromId)
            .get();

    log(getTitle.exists.toString());

    String nameData = getTitle.get('name');

    log('\n \n getTitle : $nameData \n \n');

    final String serverKey = await getAccessToken();

    log(' server key is there :  ${serverKey.toString()}');

    String endPointFirebaseCloudMessaging =
        dotenv.env['REQUEST_URL'] ?? 'no_key';

    final Map<String, dynamic> message = {
      'message': {
        'token': user.pushToken,

        'notification': {'title': nameData, 'body': msg},

        'data': {'some_data': 'User  ID : ${Apis.mySelf?.id}'},

        'android': {
          'notification': {'channel_id': 'chatting_app'},
        },
      },
    };

    final http.Response response = await http.post(
      Uri.parse(endPointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      log('\n Notification sent');
    } else {
      log('Notification failed to sent : ${response.statusCode}');

      log(response.body);
    }
  }
}
