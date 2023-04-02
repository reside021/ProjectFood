import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_food/models/chat_model.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageListStyle extends StatelessWidget {
  final ChatModel chatModel;

  MessageListStyle(this.chatModel);

  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFe41f26),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            bottomLeft: chatModel.userID == currentUserId
                ? const Radius.circular(15)
                : Radius.zero,
            topRight: const Radius.circular(15),
            bottomRight: chatModel.userID == currentUserId
                ? Radius.zero
                : const Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: chatModel.userID == currentUserId
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisAlignment: chatModel.userID == currentUserId
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Text(
                chatModel.message,
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
