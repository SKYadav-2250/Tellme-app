import 'package:tellme/api/api.dart';
import 'package:tellme/helper/dialog.dart';
import 'package:tellme/helper/my_date_util.dart';
import 'package:tellme/models/message.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:flutter/material.dart';
import 'package:tellme/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool itsUser = Apis.user!.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBotttom(context, itsUser);
      },
      child: itsUser ? _greenMessage() : _blueMessage(),
    );
  }

  Widget _blueMessage() {
    //update lastvread message if sender send the message

    if (widget.message.read.isEmpty) {
      Apis.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(md.width * .03),
            margin: EdgeInsets.symmetric(
              horizontal: md.width * .04,
              vertical: md.height * .01,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C35) : const Color(0xFFE8ECEF),
            ),
            child: widget.message.type == MessageType.image
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.message.msg,
                      placeholder: (context, imageUrl) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.image, size: 70),
                    ),
                  )
                : Text(
                    widget.message.msg,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(right: md.width * .03),
          child: Text(
            MyDateUtil.getFormattedDate(
              context: context,
              time: widget.message.sent,
            ),
            style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
          ),
        ),
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: md.width * .04),

            if (widget.message.read.isNotEmpty)
              const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),

            SizedBox(width: 2),

            Text(
              MyDateUtil.getFormattedDate(
                context: context,
                time: widget.message.sent,
              ),
              style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
            ),
          ],
        ),

        Flexible(
          child: Container(
            padding: EdgeInsets.all(md.width * .03),
            margin: EdgeInsets.symmetric(
              horizontal: md.width * .04,
              vertical: md.height * .01,
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(4),
              ),
              color: Color(0xFF6200EA),
            ),
            child: widget.message.type == MessageType.image
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.message.msg,
                      placeholder: (context, imageUrl) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.image, size: 70, color: Colors.white),
                    ),
                  )
                : Text(
                    widget.message.msg,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _showBotttom(context, itsuser) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          shrinkWrap: true,

          padding: const EdgeInsets.only(
            top: 2,
            right: 10,
            left: 15,
            bottom: 30,
          ),

          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 5,
                width: 50,
                margin: EdgeInsets.symmetric(vertical: md.height * .015),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),

            // SizedBox(height: 90),
            widget.message.type == MessageType.text
                ? _OtionItem(
                  icon: Icon(
                    Icons.copy_all_rounded,
                    color: Colors.blue,
                    size: 26,
                  ),
                  title: 'Copy Text',
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: widget.message.msg),
                    ).then((value) {
                      Navigator.pop(context);
                      Future.delayed(Duration(milliseconds: 1000), () {
                        Dialogs.showSnackbar(
                          context,
                          'Copied to Clipboard',
                          true,
                        );
                      });
                    });
                  },
                )
                : _OtionItem(
                  icon: Icon(
                    Icons.download_rounded,
                    color: Colors.blue,
                    size: 26,
                  ),
                  title: 'Save image',
                  onTap: () async {
                    try {
                      String path = widget.message.msg.toString();

                      await GallerySaver.saveImage(
                        path,
                        albumName: 'chatt App',
                      ).then((success) {
                        Navigator.pop(context);
                        if (success != null && true) {
                          Dialogs.showSnackbar(context, 'Image Saved', true);
                        }
                      });
                    } catch (e) {
                      Dialogs.showSnackbar(context, 'Error Saving Image', true);
                    }
                  },
                ),
            Divider(
              color: Theme.of(context).dividerColor,
              endIndent: md.width * .04,
              indent: md.width * .04,
            ),

            if (widget.message.type == MessageType.text && itsuser)
              _OtionItem(
                icon: Icon(Icons.edit, color: Colors.blue, size: 26),
                title: 'Edit Message',
                onTap: () {
                  Navigator.pop(context);

                  _showMessageupdatedialog();
                },
              ),
            if (itsuser)
              _OtionItem(
                icon: Icon(Icons.delete_forever, color: Colors.red, size: 26),
                title: 'Delete Message',
                onTap: () async {
                  await Apis.deleteMessage(widget.message).then((onValue) {
                    Navigator.pop(context);

                    Dialogs.showSnackbar(context, 'Message deleted', true);
                  });
                },
              ),
            if (widget.message.type == MessageType.text && itsuser)
              Divider(
                color: Theme.of(context).dividerColor,
                endIndent: md.width * .04,
                indent: md.width * .04,
              ),
            _OtionItem(
              icon: Icon(Icons.remove_red_eye, color: Colors.red, size: 26),
              title:
                  widget.message.read.isNotEmpty
                      ? 'Read At  ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}'
                      : 'Read At : No Seen Yet ',
              onTap: () {},
            ),

            _OtionItem(
              icon: Icon(Icons.remove_red_eye, color: Colors.blue, size: 26),
              title:
                  'Send At  ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
              onTap: () {},
            ),
            // SizedBox(height: 10),
          ],
        );
      },
    );
  }

  void _showMessageupdatedialog() {
    String updateMsg = widget.message.msg;

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
              Icon(Icons.message, color: Colors.blueAccent, size: 26),
              Text('Update Message', style: TextStyle(fontSize: 18)),
            ],
          ),

          content: TextFormField(
            initialValue: updateMsg,
            maxLines: null,
            onChanged: (value) => updateMsg = value,
            decoration: InputDecoration(
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
            bottom: 10,
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
                await Apis.updateMessage(widget.message, updateMsg);
              },
              child: Text(
                'Update',
                style: TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OtionItem extends StatelessWidget {
  const _OtionItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final Icon icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),

      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            icon,
            SizedBox(width: 30),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
