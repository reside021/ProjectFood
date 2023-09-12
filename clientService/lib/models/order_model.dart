import 'cart_item_model.dart';

class OrderFood{
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final String addressDelivery;
  final String coordinates;
  final int price;
  final int deliveryPrice;
  final bool ended;
  final String dateTime;

  OrderFood({
    required this.id,
    required this.userId,
    required this.items,
    required this.addressDelivery,
    required this.coordinates,
    required this.price,
    required this.deliveryPrice,
    required this.ended,
    required this.dateTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items,
      'addressDelivery': addressDelivery,
      'coordinates': coordinates,
      'price': price,
      'deliveryPrice': deliveryPrice,
      'ended' : ended,
      'dateTime' : dateTime
    };
  }
}
