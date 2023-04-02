import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_food/screens/order_info.dart';
import '../widgets/window_error.dart';
import '../widgets/window_loading.dart';

class OrderHistory extends StatefulWidget {
  static const String id = "order_history";

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  final Stream<QuerySnapshot> _streamWithData = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("requestForHelp")
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        Navigator.of(context).pushNamed(OrderInfo.id);
                      },
                      child: ListTile(
                        title: Text(data["theme"]),
                        subtitle: Text(doc["id"]),
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
