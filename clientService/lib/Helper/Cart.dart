

import 'package:project_food/models/cart_item_model.dart';

class Cart{
  Cart._();
  static final Cart instance = Cart._();

  factory Cart(){
    return instance;
  }

  List<CartItem> cartItems = <CartItem>[];

  int getTotalPrice(){
    int totalPrice = 0;
    for (var element in cartItems) {
      totalPrice += element.price * element.count;
    }

    return totalPrice;
  }
}