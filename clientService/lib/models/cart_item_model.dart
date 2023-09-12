class CartItem {
  final String id;
  final String name;
  final String previewImage;
  final int price;
  final int weight;
  int count;

  CartItem({
    required this.id,
    required this.name,
    required this.previewImage,
    required this.price,
    required this.weight,
    required this.count,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'previewImage': previewImage,
      'price': price,
      'weight': weight,
      'count': count
    };
  }
}
