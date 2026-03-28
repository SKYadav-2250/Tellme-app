import 'package:tellme/main.dart';
import 'package:tellme/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tellme/screens/chat_user_profile.dart';

import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
  final ChatUser user;

  @override
  Widget build(context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(md.height * .05),
      ),

      content: SizedBox(
        height: md.height * .30,
        width: md.width * .6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (user.name?.length ?? 0) > 15
                      ? '${user.name?.substring(0, 15) ?? ''}...'
                      : (user.name ?? ''),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatUserProfile(user: user),
                      ),
                    );
                  },
                  icon: Icon(Icons.error_outline_rounded, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: md.height * .02),
            ClipRRect(
              borderRadius: BorderRadius.circular(md.height * .1),
              child: CachedNetworkImage(
                width: md.height * .20,
                height: md.height * .20,
                fit: BoxFit.cover,
                imageUrl: user.image.toString(),
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
