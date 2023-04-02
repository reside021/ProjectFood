import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_food/Helper/Cart.dart';
import 'package:project_food/models/food_model.dart';
import 'package:project_food/screens/item_screen.dart';
import 'package:project_food/screens/map_screen.dart';
import 'package:project_food/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Helper/Counter.dart';
import '../models/cart_item_model.dart';
import '../widgets/window_error.dart';
import '../widgets/window_loading.dart';

class MainScreen extends StatefulWidget {
  static const String id = "main_screen";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _addressDelivery = "";

  final cart = Cart();
  final counter = Counter();

  Future<String> _getAddressDelivery() async {
    final prefs = await SharedPreferences.getInstance();
    String addressDelivery =
        prefs.getString('addressDelivery') ?? "Delivery Address";
    _addressDelivery = addressDelivery;
    if (addressDelivery.length > 20) {
      int comma = addressDelivery.indexOf(',') + 1;
      addressDelivery =
          "${addressDelivery.substring(0, 15)}...${addressDelivery.substring(comma)}";
    }
    return addressDelivery;
  }

  void _show(BuildContext ctx) {
    final items = cart.cartItems;

    showModalBottomSheet(
      elevation: 10,
      backgroundColor: Colors.transparent,
      context: ctx,
      isScrollControlled: true,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.9,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Container(
                height: 8,
                width: MediaQuery.of(context).size.width / 4.5,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 17.0,
                        right: 17.0,
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ClipOval(
                          child: Material(
                            color: const Color(0xFFe41f26),
                            // Button color
                            child: InkWell(
                              splashColor: Colors.white,
                              // Splash color
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const SizedBox(
                                width: 25,
                                height: 25,
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5.0,
                        left: 15.0,
                        bottom: 10.0,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Cart",
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFe41f26),
                            fontSize: 26,
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15.0,
                            vertical: 10.0,
                          ),
                          child: Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          items[index].previewImage),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                items[index].name,
                                                style: GoogleFonts.ubuntu(
                                                  fontWeight:
                                                      FontWeight.w500,
                                                ),
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets
                                                            .all(3.0),
                                                    child: Text(
                                                      "${items[index].price * items[index].count}",
                                                      style: GoogleFonts
                                                          .ubuntu(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration:
                                                        const BoxDecoration(
                                                      image:
                                                          DecorationImage(
                                                        image: AssetImage(
                                                            'lib/assets/ruble.png'),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Counter.instance.decrement();
                                                  },
                                                  style: const ButtonStyle(
                                                    minimumSize:
                                                        MaterialStatePropertyAll(
                                                      Size(20, 30),
                                                    ),
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                      Color(0xFFebebeb),
                                                    ),
                                                    foregroundColor:
                                                        MaterialStatePropertyAll(
                                                            Colors.black),
                                                    shape:
                                                        MaterialStatePropertyAll(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .all(
                                                          Radius.circular(
                                                              10.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "-",
                                                    style:
                                                        GoogleFonts.ubuntu(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10.0),
                                                  child: StreamBuilder<int>(
                                                    initialData:
                                                        items[index].count,
                                                    stream:
                                                        Counter.instance.onChange,
                                                    builder: (context,
                                                        snapshot) {
                                                      return Text(
                                                        snapshot.data
                                                            .toString(),
                                                        style: GoogleFonts
                                                            .ubuntu(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w700,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Counter.instance.increment();
                                                  },
                                                  style: const ButtonStyle(
                                                    minimumSize:
                                                        MaterialStatePropertyAll(
                                                      Size(20, 30),
                                                    ),
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                      Color(0xFFebebeb),
                                                    ),
                                                    foregroundColor:
                                                        MaterialStatePropertyAll(
                                                            Colors.black),
                                                    shape:
                                                        MaterialStatePropertyAll(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .all(
                                                          Radius.circular(
                                                              10.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "+",
                                                    style:
                                                        GoogleFonts.ubuntu(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: IconButton(
                                                onPressed: () {},
                                                icon: Image.asset(
                                                    "lib/assets/delete.png"),
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
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Order amount",
                                style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Text(
                                      "${cart.getTotalPrice()}",
                                      style: GoogleFonts.ubuntu(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'lib/assets/ruble.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Delivery",
                                style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Text(
                                      "250",
                                      style: GoogleFonts.ubuntu(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'lib/assets/ruble.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total",
                                style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFe41f26),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Text(
                                      "2097",
                                      style: GoogleFonts.ubuntu(
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFe41f26),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'lib/assets/ruble-red.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 2,
                      width: MediaQuery.of(context).size.width / 1.1,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 15.0,
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Delivery to the address",
                              style: GoogleFonts.ubuntu(
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFe41f26),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _addressDelivery,
                                style: GoogleFonts.ubuntu(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              backgroundColor: const MaterialStatePropertyAll(
                                Colors.white,
                              ),
                              foregroundColor: const MaterialStatePropertyAll(
                                Color(0xFFe41f26),
                              ),
                              fixedSize: MaterialStatePropertyAll(
                                Size(MediaQuery.of(context).size.width / 2.5,
                                    50),
                              ),
                              shape: const MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                  side: BorderSide(
                                    color: Color(0xFFe41f26),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            child: Text(
                              "Clear",
                              style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              backgroundColor: const MaterialStatePropertyAll(
                                Color(0xFFe41f26),
                              ),
                              fixedSize: MaterialStatePropertyAll(
                                Size(MediaQuery.of(context).size.width / 2.5,
                                    50),
                              ),
                              shape: const MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                            child: Text(
                              "Buy",
                              style: GoogleFonts.ubuntu(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getAddressDelivery(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (!snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Center(child: CircularProgressIndicator()),
            ],
          );
        } else if (snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Error",
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        } else {
          var addressDelivery = snapshot.data!;
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(ProfileScreen.id);
                          }, // Handle your callback.
                          splashColor: Colors.brown.withOpacity(0.5),
                          child: Ink(
                            height: 50,
                            width: 50,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('images/user.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(MapScreen.id)
                              .then((_) => setState(() {}));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.black,
                            ),
                            Text(
                              addressDelivery,
                              style: GoogleFonts.ubuntu(
                                fontSize: 22,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 35.0),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search,
                            size: 30,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Search for a dish",
                            style: GoogleFonts.ubuntu(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("food")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const WindowError();
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const WindowLoading();
                        }
                        return ListView.builder(
                          itemCount: snapshot.data?.docs.length ?? 0,
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[index];

                            final FoodModel foodModel = FoodModel(
                              category: doc["category"],
                              description: doc["description"],
                              id: doc["id"],
                              name: doc["name"],
                              previewImage: doc["previewImage"],
                              price: doc["price"],
                              urlImage: List<String>.from(doc["urlImage"]),
                              weight: doc["weight"],
                            );
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: SizedBox(
                                height: 150,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  elevation: 4.0,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Container(
                                          width: 136,
                                          height: 125,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  foodModel.previewImage),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                foodModel.name,
                                                style: GoogleFonts.ubuntu(
                                                  fontSize: 18,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                    "${foodModel.price} г",
                                                    style: GoogleFonts.ubuntu(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${foodModel.weight} Р",
                                                    style: GoogleFonts.ubuntu(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushNamed(ItemScreen.id,
                                                          arguments:
                                                              foodModel.id);
                                                },
                                                style: const ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                    Color(0xFFe41f26),
                                                  ),
                                                  fixedSize:
                                                      MaterialStatePropertyAll(
                                                    Size(150, 30),
                                                  ),
                                                  shape:
                                                      MaterialStatePropertyAll(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(20.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  "В корзину",
                                                  style: GoogleFonts.ubuntu(
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
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
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _show(context);
                    },
                    child: Container(
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Color(0xFFe41f26),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 5,
                            offset: Offset(0, -0.1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'lib/assets/shopping-cart.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    "3",
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white,
                                        fontSize: 27,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Cart",
                            style: GoogleFonts.ubuntu(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Text(
                                    "1032",
                                    style: GoogleFonts.ubuntu(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 27,
                                        color: Colors.white),
                                  ),
                                ),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'lib/assets/ruble-white.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
