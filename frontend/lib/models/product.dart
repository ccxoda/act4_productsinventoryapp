class Product {
  final int id;
  final String name;
  final double price;
  final String description;
  final int quantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as int,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    description: json['description'] as String? ?? '',
    quantity: json['quantity'] as int? ?? 0,
  );
}
