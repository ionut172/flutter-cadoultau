class Product {
  final int id;
  final String name;
  final String category;
  final String image;
  final double price;
  final bool isliked;
  bool isSelected;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.price,
    this.isliked = false,
    this.isSelected = false,
  });
}
