import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'item_screen.dart';

class ListItemsOrders extends StatefulWidget {
  static const String id = "list_items_orders";

  @override
  State<ListItemsOrders> createState() => _ListItemsOrdersState();
}

class _ListItemsOrdersState extends State<ListItemsOrders> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = ModalRoute.of(context)!
        .settings
        .arguments as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
        backgroundColor: const Color(0xFFe41f26),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: 120,
              child: Card(
                elevation: 4,
                margin: EdgeInsets.all(5),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(context).pushNamed(ItemScreen.id,
                        arguments: items[index]["id"]);
                  },
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              width: 105,
                              height: 95,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      items[index]["previewImage"]),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                items[index]["name"],
                                maxLines: 2,
                                style: GoogleFonts.ubuntu(
                                  fontSize: 17,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${items[index]["count"]} ",
                                        style: GoogleFonts.ubuntu(
                                          fontSize: 17,
                                        ),
                                      ),
                                      Text(
                                        "pcs",
                                        style: GoogleFonts.ubuntu(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "${items[index]["price"]} ",
                                        style: GoogleFonts.ubuntu(
                                          fontSize: 17,
                                        ),
                                      ),
                                      Text(
                                        "p.",
                                        style: GoogleFonts.ubuntu(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
