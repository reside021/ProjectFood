import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_food/models/order_model.dart';
import 'package:project_food/screens/list_items_orders.dart';

import '../widgets/window_error.dart';
import '../widgets/window_loading.dart';

class OrderInfo extends StatefulWidget {
  static const String id = "order_info_screen";

  @override
  State<OrderInfo> createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {
  @override
  Widget build(BuildContext context) {
    final String docID = ModalRoute.of(context)!.settings.arguments as String;

    Future<Map<String, dynamic>> getDataAboutOrder() async {
      var db = FirebaseFirestore.instance;
      final docRef = db.collection("orders").doc(docID);
      final data = docRef.get().then(
        (DocumentSnapshot doc) {
          return doc.data() as Map<String, dynamic>;
        },
        onError: (e) => print("Error getting document: $e"),
      );

      return data;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Order № $docID"),
        backgroundColor: const Color(0xFFe41f26),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: getDataAboutOrder(),
                builder: (builder, snapshot) {
                  if (snapshot.hasError) {
                    return const WindowError();
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const WindowLoading();
                  }

                  if (!snapshot.hasData) {
                    return const WindowLoading();
                  }

                  final data = snapshot.data!;

                  var items = data['items'];

                  final orderFood = OrderFood(
                      id: data['id'],
                      userId: data['userId'],
                      items: List<Map<String, dynamic>>.from(items),
                      addressDelivery: data['addressDelivery'],
                      coordinates: data['coordinates'],
                      price: data['price'],
                      deliveryPrice: data['deliveryPrice'],
                      ended: data['ended'],
                      dateTime: data['dateTime']);

                  return Center(
                    child: Column(
                      children: [
                        Card(
                          margin: EdgeInsets.all(10),
                          elevation: 4.0,
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  "Order details",
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 23,
                                  ),
                                ),
                              ),
                              const Divider(color: Colors.black),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Order Time",
                                            style: GoogleFonts.ubuntu(
                                              fontSize: 15,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10.0,
                                              left: 15.0,
                                              bottom: 10.0,
                                            ),
                                            child: Text(
                                              orderFood.dateTime,
                                              style: GoogleFonts.ubuntu(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "Delivery address",
                                            style: GoogleFonts.ubuntu(
                                              fontSize: 15,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10.0,
                                              left: 15.0,
                                              bottom: 10.0,
                                            ),
                                            child: Text(
                                              orderFood.addressDelivery,
                                              style: GoogleFonts.ubuntu(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "Coordinates",
                                            style: GoogleFonts.ubuntu(
                                              fontSize: 15,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10.0,
                                              left: 15.0,
                                              bottom: 10.0,
                                            ),
                                            child: Text(
                                              orderFood.coordinates,
                                              style: GoogleFonts.ubuntu(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          margin: EdgeInsets.all(10),
                          elevation: 4.0,
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  "Total cost",
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 23,
                                  ),
                                ),
                              ),
                              const Divider(color: Colors.black),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          "Sum",
                                          style: GoogleFonts.ubuntu(
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          orderFood.price.toString(),
                                          style: GoogleFonts.ubuntu(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: const Color(0xFFe41f26),
                          margin: EdgeInsets.all(10),
                          elevation: 8,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  ListItemsOrders.id,
                                  arguments: orderFood.items);
                            },
                            child: ListTile(
                              title: Text(
                                "Products",
                                style: GoogleFonts.ubuntu(
                                  fontSize: 23,
                                  color: const Color(0xFFFFFFFF),
                                ),
                              ),
                              trailing: Text(
                                "${orderFood.items.length} items",
                                style: GoogleFonts.ubuntu(
                                  fontSize: 23,
                                  color: const Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
