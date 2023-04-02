class FoodModel {
  final String category;
  final String description;
  final String id;
  final String name;
  final String previewImage;
  final int price;
  final List<String> urlImage;
  final int weight;

  FoodModel({
    required this.category,
    required this.description,
    required this.id,
    required this.name,
    required this.previewImage,
    required this.price,
    required this.urlImage,
    required this.weight,
  });
}
