import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'models/product.dart';

class ApiService {
  // Fetch products from the backend API
  Future<List<Product>> fetchProducts() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/products'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load products (${response.statusCode})');
    }
  }

  // Add a new product to the backend API
  Future<void> addProduct(
    String name,
    double price,
    String description,
    int quantity,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to add product (${response.statusCode})');
    }
  }

  // Update an existing product in the backend API
  Future<void> updateProduct(
    int id,
    String name,
    double price,
    String description,
    int quantity,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update product (${response.statusCode})');
    }
  }

  // Delete a product from the backend API
  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/products/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete product (${response.statusCode})');
    }
  }
}
