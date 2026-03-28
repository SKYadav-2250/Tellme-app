import 'package:tellme/api/api.dart';
import 'package:tellme/helper/my_date_util.dart';
import 'package:tellme/models/chat_user.dart';
import 'package:tellme/models/message.dart';
import 'package:tellme/widgets/message_card.dart';

import 'package:tellme/screens/chat_user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:tellme/main.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});
  final ChatUser user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  bool _isUploading = false;

  bool _showEmoji = false;
  List<Message> list = [];

  late Stream _messagesStream;
  late Stream _userInfoStream;

  @override
  void initState() {
    super.initState();
    _messagesStream = Apis.getAllMessages(widget.user);
    _userInfoStream = Apis.getUserInfo(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          if (_showEmoji) _showEmoji = false;
        });
      },
      child: PopScope(
        canPop: !_showEmoji,
        onPopInvokedWithResult: (didPop, result) {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
          }
        },
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
              elevation: 2,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),

            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    // initialData: ,
                    stream: _messagesStream,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        // return SizedBox();

                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;

                          list =
                              data
                                  ?.map(
                                    (e) => Message.fromJson(
                                      e.data() as Map<String, dynamic>,
                                    ),
                                  )
                                  .toList()
                                  .cast<Message>() ??
                              [];

                          if (list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: list.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(message: list[index]);
                              },
                            );
                          } else {
                            return Center(
                              child: Text(
                                'Say hii...👋👋👋',
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),
                if (_isUploading)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 40,
                      ),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),

                _chatInput(),

                if (_showEmoji)
                  EmojiPicker(
                    textEditingController: _textEditingController,
                    config: Config(
                      height: 320,

                      // 🔥 Main background color
                      // bgColor: Colors.black,
                      checkPlatformCompatibility: true,

                      emojiViewConfig: EmojiViewConfig(
                        emojiSizeMax:
                            28 *
                            (foundation.defaultTargetPlatform ==
                                    TargetPlatform.iOS
                                ? 1.20
                                : 1.30),

                        // 🔥 Emoji background
                        backgroundColor: Colors.black,
                      ),

                      viewOrderConfig: const ViewOrderConfig(
                        bottom: EmojiPickerItem.searchBar,
                        middle: EmojiPickerItem.categoryBar,
                        top: EmojiPickerItem.emojiView,
                      ),

                      // 🔥 Skin tone popup dark
                      skinToneConfig: const SkinToneConfig(
                        dialogBackgroundColor: Colors.black,
                      ),

                      // 🔥 Category bar (icons row)
                      categoryViewConfig: CategoryViewConfig(
                        backgroundColor: Colors.black,
                        indicatorColor: Colors.green, // highlight color
                        iconColor: Colors.white54,
                        iconColorSelected: Colors.green,
                      ),

                      // 🔥 Bottom bar
                      bottomActionBarConfig: BottomActionBarConfig(
                        backgroundColor: Colors.black,
                        buttonColor: Colors.green,
                        buttonIconColor: Colors.white,
                      ),

                      // 🔥 Search bar
                      searchViewConfig: SearchViewConfig(
                        backgroundColor: Colors.black,
                        buttonIconColor: Colors.white,
                        hintText: 'Search emoji...',
                        hintTextStyle: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ChatUserProfile(user: widget.user)),
        );
      },
      highlightColor: Colors.transparent,
      splashColor: const Color(0xFF6200EA).withAlpha(20),
      child: StreamBuilder(
        stream: _userInfoStream,
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data
                  ?.map(
                    (e) => ChatUser.fromJson(e.data() as Map<String, dynamic>),
                  )
                  .toList()
                  .cast<ChatUser>() ??
              [];

          // Determine online status cleanly
          bool isOnline =
              list.isNotEmpty
                  ? (list[0].isOnline ?? false)
                  : (widget.user.isOnline ?? false);

          return Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 2),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(md.height * 0.3),
                      child: CachedNetworkImage(
                        height: 42,
                        width: 42,
                        fit: BoxFit.cover,
                        imageUrl:
                            list.isNotEmpty
                                ? list[0].image.toString()
                                : widget.user.image.toString(),
                        placeholder:
                            (context, imageUrl) => const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        errorWidget:
                            (context, url, error) => const CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(
                                CupertinoIcons.person,
                                color: Colors.white,
                              ),
                            ),
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.shade400,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: md.width * 0.035),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.isNotEmpty
                            ? list[0].name.toString()
                            : widget.user.name.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOnline
                            ? 'Online'
                            : MyDateUtil.getLastActiveTime(
                              context: context,
                              lasttime:
                                  list.isNotEmpty
                                      ? list[0].lastActive.toString()
                                      : widget.user.lastActive.toString(),
                            ),
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isOnline
                                  ? Colors.green.shade600
                                  : Colors.grey.shade600,
                          fontWeight:
                              isOnline ? FontWeight.w500 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: md.width * .025,
        vertical: md.height * .015,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withAlpha(40)
                            : Colors.black.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        FocusScope.of(context).unfocus();
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 120),
                      child: Scrollbar(
                        child: TextField(
                          controller: _textEditingController,
                          maxLines: null,
                          keyboardAppearance: Brightness.dark,
                          keyboardType: TextInputType.multiline,
                          onTap: () {
                            setState(() {
                              _showEmoji = false;
                            });
                          },
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color?.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      try {
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> images = await picker.pickMultiImage(
                          imageQuality: 50,
                        );

                        for (var image in images) {
                          setState(() => _isUploading = true);
                          await Apis.sendChatImage(
                            widget.user,
                            File(image.path),
                          );
                          setState(() => _isUploading = false);
                        }
                      } catch (e) {
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(Icons.image_outlined, color: Colors.grey),
                  ),
                  IconButton(
                    onPressed: () async {
                      try {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          imageQuality: 50,
                          source: ImageSource.camera,
                        );

                        if (image != null) {
                          setState(() => _isUploading = true);
                          await Apis.sendChatImage(
                            widget.user,
                            File(image.path),
                          );
                          setState(() => _isUploading = false);
                        }
                      } catch (e) {
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(width: md.width * .01),
                ],
              ),
            ),
          ),

          SizedBox(width: md.width * .02),

          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: MaterialButton(
              onPressed: () {
                if (_textEditingController.text.isNotEmpty) {
                  if (list.isEmpty) {
                    Apis.sendFirstMessage(
                      widget.user,
                      _textEditingController.text,
                      MessageType.text,
                    );
                    _textEditingController.clear();
                  } else {
                    Apis.sendMessage(
                      widget.user,
                      _textEditingController.text,
                      MessageType.text,
                    );
                    _textEditingController.clear();
                  }
                }
              },
              minWidth: 0,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF6200EA), // Match brand color
              elevation: 4,
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
