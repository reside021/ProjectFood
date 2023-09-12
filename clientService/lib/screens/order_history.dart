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

  final Stream<QuerySnapshot> streamWithData = FirebaseFirestore.instance
      .collection("orders")
      .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .orderBy('id', descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order history"),
        backgroundColor: const Color(0xFFe41f26),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: streamWithData,
          builder: (builder, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
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
                        Navigator.of(context).pushNamed(OrderInfo.id, arguments: data["id"]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text("Order date: ${data["dateTime"]}"),
                          subtitle: Text("Order cost: ${data["price"]}"),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
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
