import 'package:dotenv/dotenv.dart';
import 'package:mysql1/mysql1.dart';

class MysqlRepository {
  final DotEnv _env = DotEnv(includePlatformEnvironment: true)..load();

  ConnectionSettings get _settings => ConnectionSettings(
    host: _env['DB_HOST'] ?? '127.0.0.1',
    port: int.parse(_env['DB_PORT'] ?? '3306'),
    user: _env['DB_USER'] ?? 'root',
    password: (_env['DB_PASS'] ?? '').isEmpty ? null : _env['DB_PASS'],
    db: _env['DB_NAME'] ?? 'product',
  );

  Future<MySqlConnection> _connect() => MySqlConnection.connect(_settings);

  Future<List<Map<String, dynamic>>> getProducts() async {
    final conn = await _connect();
    try {
      final results = await conn.query(
        'SELECT id, name, description, price, quantity FROM products',
      );
      return results.map((row) {
        return {
          'id': row['id'],
          'name': row['name'].toString(),
          'description': row['description'].toString(),
          'price': row['price'],
          'quantity': row['quantity'],
        };
      }).toList();
    } finally {
      await conn.close();
    }
  }

  Future<int> insertProduct(
    String name,
    double price,
    String description,
    int quantity,
  ) async {
    final conn = await _connect();
    try {
      final result = await conn.query(
        'INSERT INTO products (name, price, description, quantity) VALUES (?, ?, ?, ?)',
        [name, price, description, quantity],
      );
      return result.insertId ?? 0;
    } finally {
      await conn.close();
    }
  }

  Future<int> updateProduct(Map<String, dynamic> product) async {
    final conn = await _connect();
    try {
      final result = await conn.query(
        'UPDATE products SET name = ?, description = ?, price = ?, quantity = ? WHERE id = ?',
        [
          product['name'],
          product['description'],
          product['price'],
          product['quantity'],
          product['id'],
        ],
      );
      return result.affectedRows;
    } finally {
      await conn.close();
    }
  }

  Future<int> deleteProduct(int id) async {
    final conn = await _connect();
    try {
      final result = await conn.query('DELETE FROM products WHERE id = ?', [
        id,
      ]);
      return result.affectedRows;
    } finally {
      await conn.close();
    }
  }
}
