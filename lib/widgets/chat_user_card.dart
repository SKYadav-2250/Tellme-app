import 'package:cached_network_image/cached_network_image.dart';
import 'package:tellme/api/api.dart';
import 'package:tellme/helper/my_date_util.dart';
import 'package:tellme/main.dart';
import 'package:tellme/models/chat_user.dart';
import 'package:tellme/models/message.dart';
import 'package:tellme/screens/chat_screen.dart';
import 'package:tellme/widgets/dialog.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.user});

  final ChatUser user;

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? message;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: md.width * .04, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withAlpha(40) : Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: StreamBuilder(
          stream: Apis.getLastMessage(widget.user),
          builder: (context, snapshot) {
            // log(snapshot.data.toString());

            final data = snapshot.data?.docs;

            final list =
                data
                    ?.map(
                      (element) => Message.fromJson(
                        element.data() as Map<String, dynamic>,
                      ),
                    )
                    .toList()
                    .cast<Message>() ??
                [];

            if (list.isNotEmpty) {
              message = list[0];
            }

            // if(data!=null)
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => ProfileDialog(user: widget.user),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(md.height * .3),

                  child: CachedNetworkImage(
                    height: md.height * .055, // Increased size
                    width: md.height * .055,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.image ?? '',

                    placeholder:
                        (context, imageUrl) =>
                            const CircularProgressIndicator(),
                    errorWidget:
                        (context, url, error) => const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(CupertinoIcons.add),
                        ),
                  ),
                ),
              ),

              title: Text(
                widget.user.name.toString(),
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              subtitle:
                  message != null
                      ? message!.type == MessageType.image
                          ? const Row(
                            children: [
                              Icon(Icons.image, size: 18, color: Colors.grey),
                              SizedBox(width: 5),
                              Text(
                                'Photo',
                                style: TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )
                          : Text(
                            message!.msg,
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          )
                      : Text(
                        widget.user.about.toString(),
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),

              trailing:
                  message == null
                      ? null
                      : message!.read.isEmpty &&
                          message!.fromId != Apis.user!.uid
                      ? Container(
                        height: 12,
                        width: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF6200EA), // Match brand color
                        ),
                      )
                      : Text(
                        MyDateUtil.getLastMessageTime(
                          context: context,
                          time: message!.sent,
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
            );
          },
        ),
      ),
    );
  }
}
