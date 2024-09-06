class Hobby {
  final int id;
  final String title;  // Use 'title' instead of 'name' as per your API data
  final String description;
  final String category;
  final String image;
  final double price;
  bool isliked;
  bool isSelected;
  int quantity;  // Add quantity field

  Hobby({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.image,
    required this.price,
    this.isliked = false,
    this.isSelected = false,
    this.quantity = 1,
  });

 
}
