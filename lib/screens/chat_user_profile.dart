import 'package:cached_network_image/cached_network_image.dart';
import 'package:tellme/helper/my_date_util.dart';
import 'package:tellme/models/chat_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:tellme/main.dart';

class ChatUserProfile extends StatefulWidget {
  const ChatUserProfile({super.key, required this.user});
  final ChatUser user;

  @override
  State<ChatUserProfile> createState() => _ChatUserProfileState();
}

class _ChatUserProfileState extends State<ChatUserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'User Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: md.height * 0.03),

            // Profile Card
            Center(
              child: Container(
                width: md.width * 0.85,
                padding: EdgeInsets.symmetric(vertical: md.height * 0.04),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withAlpha(50)
                              : Colors.black.withAlpha(15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(md.height * 0.1),
                      child: CachedNetworkImage(
                        width: md.height * 0.18,
                        height: md.height * 0.18,
                        fit: BoxFit.cover,
                        imageUrl: widget.user.image ?? '',
                        placeholder:
                            (context, url) => const CircularProgressIndicator(),
                        errorWidget:
                            (context, url, error) => const CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: Icon(
                                CupertinoIcons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                      ),
                    ),
                    SizedBox(height: md.height * 0.03),
                    Text(
                      widget.user.name ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.user.email ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: md.height * 0.04),

            // Details Section
            Container(
              width: md.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withAlpha(50)
                            : Colors.black.withAlpha(15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(
                    context,
                    Icons.info_outline,
                    'About',
                    widget.user.about ?? '',
                  ),
                  const Divider(height: 30),
                  _infoRow(
                    context,
                    Icons.calendar_today_outlined,
                    'Joined On',
                    MyDateUtil.getLastMessageTime(
                      context: context,
                      time: widget.user.createdAt ?? '',
                      showYear: true,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: md.height * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF6200EA), size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
