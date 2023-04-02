import 'package:flutter/material.dart';
import 'package:project_food/models/chat_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/message_list_style.dart';
import '../widgets/window_error.dart';
import '../widgets/window_loading.dart';

class ChatScreen extends StatefulWidget {
  static const String id = "chat_support_screen";


  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  late TextEditingController _enteredMessageController;

  @override
  void initState() {
    _enteredMessageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _enteredMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String docID = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Support chat"),
        backgroundColor: const Color(0xFFe41f26),
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection("requestForHelp")
                  .doc(docID)
                  .collection("messages")
                  .orderBy("timestamp")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const WindowError();
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const WindowLoading();
                }
                return ListView.builder(
                  itemCount: snapshot.data?.docs.length ?? 0,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];

                    final ChatModel chatModel = ChatModel(
                      userID: doc["userID"],
                      message: doc["message"],
                      timestamp: doc["timestamp"],
                    );
                    return Align(
                      alignment: chatModel.userID == currentUserId
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: MessageListStyle(chatModel),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            height: 60,
            child: Material(
              elevation: 20,
              shadowColor: Colors.black,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: TextField(
                        controller: _enteredMessageController,
                        maxLines: 2,
                        decoration: const InputDecoration.collapsed(
                          hintText: "Enter message",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        final data = ChatModel(
                          userID: FirebaseAuth.instance.currentUser!.uid,
                          message: _enteredMessageController.text,
                          timestamp: Timestamp.now(),
                        ).toMap();

                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection("requestForHelp")
                            .doc(docID)
                            .collection("messages")
                            .add(data)
                            .then((value) => print("add new message"))
                            .catchError(
                                (onError) => print("error add new message"));

                        _enteredMessageController.clear();
                      },
                      icon: const Icon(Icons.arrow_forward_ios_rounded))
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
