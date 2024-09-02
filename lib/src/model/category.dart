class Category {
  final int id;
  final String name;
  final String image;
  bool isSelected;

  // Constructor with required parameters for id, name, and image
  Category({
    required this.id,
    required this.name,
    required this.image,
    this.isSelected = false,
  });
}
