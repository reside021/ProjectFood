import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:project_food/models/cart_item_model.dart';
import 'package:localstore/localstore.dart';

import '../Helper/CountCart.dart';
import '../Helper/Counter.dart';
import '../Helper/TotalSumCart.dart';
import '../widgets/window_error.dart';
import '../widgets/window_loading.dart';

class ItemScreen extends StatefulWidget {
  static const String id = "item_screen";

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  final db = Localstore.instance;

  List<String> getUrlImage(data) {
    List<String> urlImageList = [];
    String previewImage = data["previewImage"];
    urlImageList.add(previewImage);
    List<String> images = List<String>.from(data["urlImage"]);
    images = images.where((element) => element != previewImage).toList();
    urlImageList.addAll(images);
    return urlImageList;
  }

  @override
  void initState() {
    Counter.instance.update(1);
    TotalSumCart.instance.updateTotalSumCart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String docID = ModalRoute.of(context)!.settings.arguments as String;

    Future<Map<String, dynamic>> getDataAboutItems() async {
      var db = FirebaseFirestore.instance;
      final docRef = db.collection("food").doc(docID);
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
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFe41f26),
        actions: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: StreamBuilder<int>(
                  initialData: TotalSumCart.instance.lastUpdate,
                  stream: TotalSumCart.instance.onChange,
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data.toString(),
                      style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w700,
                          fontSize: 23,
                          color: Colors.black),
                    );
                  },
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/assets/ruble.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 10.0, left: 5.0),
                child: Icon(
                  Icons.shopping_basket_outlined,
                  size: 35,
                ),
              )
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: getDataAboutItems(),
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

            final urlImageList = getUrlImage(data);

            var isHasInCart = false;

            return FutureBuilder<Map<String, dynamic>?>(
              future: db.collection('cart').doc(data["id"]).get(),
              builder: (builder, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const WindowLoading();
                }

                if (snapshot.hasData) {
                  Counter.instance.update(snapshot.data!['count']);
                  isHasInCart = true;
                }

                return Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              CarouselSlider.builder(
                                itemCount: urlImageList.length,
                                options: CarouselOptions(
                                  enlargeCenterPage: false,
                                  height: 275,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 7),
                                  reverse: false,
                                  viewportFraction: 1.0,
                                ),
                                itemBuilder: (context, i, id) {
                                  return Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(urlImageList[i]),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      "${data["weight"]} г",
                                      style: GoogleFonts.ubuntu(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child: Text(
                                            "${data["price"]}",
                                            style: GoogleFonts.ubuntu(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 15,
                                          height: 15,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'lib/assets/ruble.png'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        data["name"],
                                        style: GoogleFonts.ubuntu(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                  vertical: 10.0,
                                ),
                                child: Text(
                                  data["description"],
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
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
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50.0, vertical: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Counter.instance.decrement();
                                    if (isHasInCart) {
                                      if (Counter.instance.lastUpdate == 1) {
                                        db
                                            .collection("cart")
                                            .doc(data["id"])
                                            .delete();
                                        setState(() {});
                                      }
                                      final cartItem = CartItem(
                                        id: data["id"],
                                        name: data["name"],
                                        previewImage: data["previewImage"],
                                        price: data["price"],
                                        weight: data["weight"],
                                        count: Counter.instance.lastUpdate!,
                                      );
                                      db
                                          .collection("cart")
                                          .doc(cartItem.id)
                                          .set(cartItem.toMap());
                                      TotalSumCart.instance.updateTotalSumCart();
                                    }
                                  },
                                  style: const ButtonStyle(
                                    minimumSize: MaterialStatePropertyAll(
                                      Size(60, 50),
                                    ),
                                    backgroundColor: MaterialStatePropertyAll(
                                      Color(0xFFebebeb),
                                    ),
                                    foregroundColor:
                                        MaterialStatePropertyAll(Colors.black),
                                    shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "-",
                                    style: GoogleFonts.ubuntu(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                StreamBuilder<int>(
                                  initialData: Counter.instance.lastUpdate,
                                  stream: Counter.instance.onChange,
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data.toString(),
                                      style: GoogleFonts.ubuntu(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    );
                                  },
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Counter.instance.increment();
                                    if (isHasInCart) {
                                      final cartItem = CartItem(
                                        id: data["id"],
                                        name: data["name"],
                                        previewImage: data["previewImage"],
                                        price: data["price"],
                                        weight: data["weight"],
                                        count: Counter.instance.lastUpdate!,
                                      );
                                      db
                                          .collection("cart")
                                          .doc(cartItem.id)
                                          .set(cartItem.toMap());
                                      TotalSumCart.instance.updateTotalSumCart();
                                    }
                                  },
                                  style: const ButtonStyle(
                                    minimumSize: MaterialStatePropertyAll(
                                      Size(60, 50),
                                    ),
                                    backgroundColor: MaterialStatePropertyAll(
                                      Color(0xFFebebeb),
                                    ),
                                    foregroundColor:
                                        MaterialStatePropertyAll(Colors.black),
                                    shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "+",
                                    style: GoogleFonts.ubuntu(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: ElevatedButton(
                              onPressed: () {
                                if (isHasInCart) return;
                                final cartItem = CartItem(
                                  id: data["id"],
                                  name: data["name"],
                                  previewImage: data["previewImage"],
                                  price: data["price"],
                                  weight: data["weight"],
                                  count: Counter.instance.lastUpdate!,
                                );
                                db
                                    .collection("cart")
                                    .doc(cartItem.id)
                                    .set(cartItem.toMap());
                                CountCart.instance.updateCountCart();
                                TotalSumCart.instance.updateTotalSumCart();
                                setState(() {});
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                  isHasInCart
                                      ? const Color(0xFF8f8b8b)
                                      : const Color(0xFFe41f26),
                                ),
                                fixedSize: const MaterialStatePropertyAll(
                                  Size(270, 50),
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
                                isHasInCart
                                    ? "Already in the cart"
                                    : "Add to cart",
                                style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
