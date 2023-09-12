import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_food/models/support_model.dart';
import 'package:project_food/widgets/theme_msg_dialog.dart';

import '../widgets/window_error.dart';
import '../widgets/window_loading.dart';
import 'chat_support_screen.dart';

class TextSupportScreen extends StatefulWidget {
  static const String id = "text_support_screen";


  @override
  State<TextSupportScreen> createState() => _TextSupportScreenState();
}

class _TextSupportScreenState extends State<TextSupportScreen> {
  final Stream<QuerySnapshot> _streamWithData = FirebaseFirestore.instance
      .collection("support")
      .where("idUser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  Future<void> _createNewRequest() async {
    // create id
    var nowDateTime = DateTime.now().toString();
    nowDateTime = nowDateTime.substring(0, nowDateTime.indexOf('.'));

    String themeMessage = await showDialog<String>(
            context: context, builder: (_) => ThemeMsgDialog()) ??
        "";
    if (themeMessage.trim().isEmpty) return;

    var idUser = FirebaseAuth.instance.currentUser!.uid;

    final supportModel = SupportModel(
      timeCreate: Timestamp.now(),
      theme: themeMessage,
      id: nowDateTime,
      idUser: idUser,
      isOpen: true
    ).toMap();

    FirebaseFirestore.instance
        .collection("support")
        .add(supportModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: _createNewRequest,
          backgroundColor: const Color(0xFFe41f26),
          label: const Text("New request"),
          icon: const Icon(Icons.add)),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _streamWithData,
          builder: (builder, snapshot) {
            if (snapshot.hasError) {
              return const WindowError();
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const WindowLoading();
            }
            return ListView(
              children: snapshot.data!.docs
                  .map((DocumentSnapshot doc) {
                    Map<String, dynamic> data =
                        doc.data()! as Map<String, dynamic>;
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(ChatScreen.id, arguments: doc.id);
                      },
                      child: ListTile(
                        title: Text(data["theme"]),
                        subtitle: Text(data["id"]),
                      ),
                    );
                  })
                  .toList()
                  .cast(),
            );
          },
        ),
      ),
    );
  }
}
