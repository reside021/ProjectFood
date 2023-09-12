import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_food/Helper/Cart.dart';
import 'package:project_food/Helper/CountCart.dart';
import 'package:project_food/Helper/CurrentCounter.dart';
import 'package:project_food/Helper/IsItemCart.dart';
import 'package:project_food/Helper/TotalSumCart.dart';
import 'package:project_food/models/food_model.dart';
import 'package:project_food/models/order_model.dart';
import 'package:project_food/screens/item_screen.dart';
import 'package:project_food/screens/map_screen.dart';
import 'package:project_food/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localstore/localstore.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../Helper/Counter.dart';
import '../models/cart_item_model.dart';
import '../widgets/window_error.dart';
import '../widgets/window_loading.dart';

class MainScreen extends StatefulWidget {
  static const String id = "main_screen";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<MainScreen> {
  String _addressDelivery = "";
  String coordinates = "";
  final db = Localstore.instance;
  final cart = Cart();
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  ItemScrollController _scrollController = ItemScrollController();

  Future<String> _getAddressDelivery() async {
    final prefs = await SharedPreferences.getInstance();
    String addressDelivery =
        prefs.getString('addressDelivery') ?? "Delivery Address";
    double latitude = prefs.getDouble('latDelivery') ?? 0;
    double longitude = prefs.getDouble('longDelivery') ?? 0;
    coordinates = "$latitude, $longitude";
    _addressDelivery = addressDelivery;
    if (addressDelivery.length > 20) {
      int comma = addressDelivery.indexOf(',') + 1;
      addressDelivery =
          "${addressDelivery.substring(0, 15)}...${addressDelivery.substring(comma)}";
    }
    return addressDelivery;
  }

  void _updateStreamWithData() {
    CountCart.instance.updateCountCart();
    TotalSumCart.instance.updateTotalSumCart();
  }

  void _getCategoryData() {
    FirebaseFirestore.instance
        .collection("category")
        .get()
        .then((querySnapshot) => {
              for (var docSnapshot in querySnapshot.docs)
                {
                  db
                      .collection("category")
                      .doc(docSnapshot.id)
                      .set(docSnapshot.data())
                }
            });
  }

  @override
  void initState() {
    setState(() {
      _updateStreamWithData();
      _getCategoryData();
    });
    super.initState();
  }

  void _show(BuildContext context) {
    final items = db.collection('cart').get();

    final List<Map<String, dynamic>> cartItems = [];

    showModalBottomSheet(
      elevation: 10,
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
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
                    Expanded(
                      child: FutureBuilder<Map<String, dynamic>?>(
                        future: items,
                        builder: (builder, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!snapshot.hasData) {
                            return Center(
                              child: Text(
                                "The cart is empty.",
                                style: GoogleFonts.ubuntu(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          }
                          final data = snapshot.data!;
                          final keys = data.keys.toList();

                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: data.length,
                            itemBuilder: (BuildContext context, int index) {
                              var currentCounter = CurrentCounter();

                              var cartItem = CartItem(
                                id: data[keys[index]]['id'],
                                name: data[keys[index]]['name'],
                                previewImage: data[keys[index]]['previewImage'],
                                price: data[keys[index]]['price'],
                                weight: data[keys[index]]['weight'],
                                count: data[keys[index]]['count'],
                              );

                              cartItems.add(cartItem.toMap());

                              currentCounter.update(cartItem.count);

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                  vertical: 10.0,
                                ),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        ItemScreen.id,
                                        arguments: data[keys[index]]['id']);
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                data[keys[index]]
                                                    ['previewImage']),
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
                                                  Flexible(
                                                    child: Text(
                                                      data[keys[index]]['name'],
                                                      style: GoogleFonts.ubuntu(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(3.0),
                                                        child: Text(
                                                          "${data[keys[index]]['price'] * data[keys[index]]['count']}",
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
                                                          currentCounter
                                                              .decrement();
                                                          cartItem.count =
                                                              currentCounter
                                                                  .lastUpdate!;
                                                          db
                                                              .collection(
                                                                  "cart")
                                                              .doc(data[keys[
                                                                  index]]['id'])
                                                              .set(cartItem
                                                                  .toMap());
                                                          _updateStreamWithData();
                                                        },
                                                        style:
                                                            const ButtonStyle(
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
                                                          style: GoogleFonts
                                                              .ubuntu(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    10.0),
                                                        child:
                                                            StreamBuilder<int>(
                                                          initialData:
                                                              currentCounter
                                                                  .lastUpdate,
                                                          stream: currentCounter
                                                              .onChange,
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
                                                          currentCounter
                                                              .increment();
                                                          cartItem.count =
                                                              currentCounter
                                                                  .lastUpdate!;
                                                          db
                                                              .collection(
                                                                  "cart")
                                                              .doc(data[keys[
                                                                  index]]['id'])
                                                              .set(cartItem
                                                                  .toMap());
                                                          _updateStreamWithData();
                                                        },
                                                        style:
                                                            const ButtonStyle(
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
                                                          style: GoogleFonts
                                                              .ubuntu(
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
                                                      onPressed: () {
                                                        db
                                                            .collection("cart")
                                                            .doc(data[
                                                                    keys[index]]
                                                                ['id'])
                                                            .delete();
                                                        _updateStreamWithData();
                                                        Navigator.pop(context);
                                                        _show(context);
                                                        setState(() {});
                                                      },
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
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    child: StreamBuilder<int>(
                                      initialData:
                                          TotalSumCart.instance.lastUpdate,
                                      stream: TotalSumCart.instance.onChange,
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data.toString(),
                                          style: GoogleFonts.ubuntu(
                                              fontWeight: FontWeight.w500),
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image:
                                            AssetImage('lib/assets/ruble.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        image:
                                            AssetImage('lib/assets/ruble.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    child: StreamBuilder<int>(
                                      initialData:
                                          TotalSumCart.instance.lastUpdate,
                                      stream: TotalSumCart.instance.onChange,
                                      builder: (context, snapshot) {
                                        var data = snapshot.data;
                                        if (data != null && data != 0) {
                                          data += 250;
                                        }
                                        return Text(
                                          data.toString(),
                                          style: GoogleFonts.ubuntu(
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFFe41f26),
                                          ),
                                        );
                                      },
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
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    // set up the button
                                    Widget okButton = TextButton(
                                      child: const Text("OK"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _updateStreamWithData();
                                        Navigator.pop(context);
                                        _show(context);
                                        setState(() {});
                                      },
                                    );

                                    // set up the AlertDialog
                                    AlertDialog alert = AlertDialog(
                                      title: const Text("Order status"),
                                      content: const Text(
                                          "The order has been successfully placed."),
                                      actions: [
                                        okButton,
                                      ],
                                    );

                                    DateFormat dateFormat =
                                        DateFormat("yyyy-MM-dd HH:mm");
                                    var dateTime =
                                        dateFormat.format(DateTime.now());

                                    final order = OrderFood(
                                        id: Timestamp.now().seconds.toString(),
                                        userId: currentUserId,
                                        items: cartItems,
                                        addressDelivery: _addressDelivery,
                                        coordinates: coordinates,
                                        price:
                                            TotalSumCart.instance.lastUpdate!,
                                        deliveryPrice: 250,
                                        ended: false,
                                        dateTime: dateTime);

                                    FirebaseFirestore.instance
                                        .collection("orders")
                                        .doc(order.id)
                                        .set(order.toMap())
                                        .then((value) => {
                                              alert = AlertDialog(
                                                title:
                                                    const Text("Order status"),
                                                content: const Text(
                                                    "The order has been successfully placed."),
                                                actions: [
                                                  okButton,
                                                ],
                                              ),
                                              db.collection("cart").delete()
                                            })
                                        .catchError((onError) => {
                                              alert = AlertDialog(
                                                title:
                                                    const Text("Order status"),
                                                content: const Text(
                                                    "Error, please try again later."),
                                                actions: [
                                                  okButton,
                                                ],
                                              )
                                            });
                                    return alert;
                                  });
                            },
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
                    ),
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

          return FutureBuilder(
            future: db.collection("category").get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const WindowError();
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const WindowLoading();
              }

              final category = <String, dynamic>{};
              final listItems = <String, List<FoodModel>>{};
              final categoryIndex = <String, int>{};

              snapshot.data!.forEach((key, value) {
                var id = value['id'];
                var cat = value['category'];
                category[id] = cat;
                listItems[id] = <FoodModel>[];
              });

              final List<Widget> tabsCategory = List.generate(
                category.length,
                (index) => ElevatedButton(
                  key: GlobalObjectKey(category.keys.elementAt(index)),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xFFe41f26)),
                    shape: MaterialStateProperty.all(
                      ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  child: Text(
                    "${category.values.elementAt(index)}",
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    var key = category.keys.elementAt(index);
                    _scrollController.scrollTo(
                        index: categoryIndex[key]!,
                        duration: const Duration(milliseconds: 300));
                  },
                ),
              );

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
                                Navigator.of(context)
                                    .pushNamed(ProfileScreen.id);
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
                            vertical: 10.0, horizontal: 15.0),
                        child: TextField(
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Search',
                          ),
                          onSubmitted: (value) {
                            for (var element in listItems.keys) {
                              var items = listItems[element];
                              items?.removeWhere(
                                  (element) => !element.name.contains(value));
                              if (items!.isEmpty){
                                category.removeWhere((key, value) => key == element);
                              }
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 8.0,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Wrap(
                            spacing: 10,
                            children: tabsCategory,
                          ),
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection("food")
                              .orderBy("category")
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const WindowError();
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const WindowLoading();
                            }

                            for (var element in snapshot.data!.docs) {
                              final map =
                                  element.data() as Map<String, dynamic>;
                              final foodModel = FoodModel(
                                category: map['category'],
                                description: map['description'],
                                id: map['id'],
                                name: map['name'],
                                previewImage: map['previewImage'],
                                price: map['price'],
                                urlImage: List<String>.from(map['urlImage']),
                                weight: map['weight'],
                              );

                              listItems[foodModel.category]!.add(foodModel);
                            }

                            print(listItems);

                            var itemsForDisplay = <Widget>[];

                            category.forEach((key, value) {
                              final List<Widget> items = List.generate(
                                  listItems[key]!.length, (index) {
                                var foodModel =
                                    listItems[key]!.elementAt(index);

                                return FutureBuilder<Map<String, dynamic>?>(
                                    future: db
                                        .collection('cart')
                                        .doc(foodModel.id)
                                        .get(),
                                    builder: (builder, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      var isItemCart = IsItemCart();
                                      isItemCart.update(false);

                                      if (snapshot.hasData) {
                                        Counter.instance
                                            .update(snapshot.data!['count']);
                                        isItemCart.update(true);
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          elevation: 4.0,
                                          child: GestureDetector(
                                            behavior:
                                                HitTestBehavior.translucent,
                                            onTap: () {
                                              Navigator.of(context).pushNamed(
                                                  ItemScreen.id,
                                                  arguments: foodModel.id);
                                            },
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: Container(
                                                    width: 136,
                                                    height: 125,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            foodModel
                                                                .previewImage),
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          foodModel.name,
                                                          style: GoogleFonts
                                                              .ubuntu(
                                                            fontSize: 18,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 2,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Text(
                                                              "${foodModel.price} г",
                                                              style: GoogleFonts
                                                                  .ubuntu(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            Text(
                                                              "${foodModel.weight} Р",
                                                              style: GoogleFonts
                                                                  .ubuntu(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        StreamBuilder<bool>(
                                                            initialData:
                                                                isItemCart
                                                                    .lastUpdate,
                                                            stream: isItemCart
                                                                .onChange,
                                                            builder: (context,
                                                                snapshot) {
                                                              return ElevatedButton(
                                                                onPressed: () {
                                                                  if (isItemCart
                                                                      .lastUpdate!)
                                                                    return;
                                                                  final cartItem =
                                                                      CartItem(
                                                                    id: foodModel
                                                                        .id,
                                                                    name: foodModel
                                                                        .name,
                                                                    previewImage:
                                                                        foodModel
                                                                            .previewImage,
                                                                    price: foodModel
                                                                        .price,
                                                                    weight: foodModel
                                                                        .weight,
                                                                    count: 1,
                                                                  );
                                                                  db
                                                                      .collection(
                                                                          "cart")
                                                                      .doc(cartItem
                                                                          .id)
                                                                      .set(cartItem
                                                                          .toMap());
                                                                  _updateStreamWithData();
                                                                  isItemCart
                                                                      .update(
                                                                          true);
                                                                },
                                                                style:
                                                                    ButtonStyle(
                                                                  backgroundColor:
                                                                      MaterialStatePropertyAll(
                                                                    snapshot.data!
                                                                        ? const Color(
                                                                            0xFF8f8b8b)
                                                                        : const Color(
                                                                            0xFFe41f26),
                                                                  ),
                                                                  fixedSize:
                                                                      const MaterialStatePropertyAll(
                                                                    Size(150,
                                                                        30),
                                                                  ),
                                                                  shape:
                                                                      const MaterialStatePropertyAll(
                                                                    RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            20.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  snapshot.data!
                                                                      ? "In the cart"
                                                                      : "Add to cart",
                                                                  style: GoogleFonts.ubuntu(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              );
                                                            }),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                              });
                              var categoryBlock = Center(
                                child: Card(
                                  margin: const EdgeInsets.all(10.0),
                                  elevation: 4.0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      child: Center(
                                        child: Text(
                                          value,
                                          style: GoogleFonts.ubuntu(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 23,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              itemsForDisplay.add(categoryBlock);
                              categoryIndex[key] = itemsForDisplay.length - 1;
                              itemsForDisplay.addAll(items);
                            });

                            return ScrollablePositionedList.builder(
                              physics: const ClampingScrollPhysics(),
                              itemScrollController: _scrollController,
                              itemCount: itemsForDisplay.length,
                              itemBuilder: (context, index) {
                                return itemsForDisplay[index];
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
                                      child: StreamBuilder<int>(
                                        initialData:
                                            CountCart.instance.lastUpdate,
                                        stream: CountCart.instance.onChange,
                                        builder: (context, snapshot) {
                                          return Text(
                                            snapshot.data.toString(),
                                            style: GoogleFonts.ubuntu(
                                                color: Colors.white,
                                                fontSize: 27,
                                                fontWeight: FontWeight.w700),
                                          );
                                        },
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
                                      child: StreamBuilder<int>(
                                        initialData:
                                            TotalSumCart.instance.lastUpdate,
                                        stream: TotalSumCart.instance.onChange,
                                        builder: (context, snapshot) {
                                          return Text(
                                            snapshot.data.toString(),
                                            style: GoogleFonts.ubuntu(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 27,
                                                color: Colors.white),
                                          );
                                        },
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
            },
          );
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
