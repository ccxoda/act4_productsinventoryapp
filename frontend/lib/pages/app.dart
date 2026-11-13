import 'package:flutter/material.dart';

import '../api_service.dart';
import '../models/product.dart';
import '../widgets/product_dialog.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: const InventoryApp(title: 'Product Inventory'),
    );
  }
}

class InventoryApp extends StatefulWidget {
  const InventoryApp({super.key, required this.title});
  final String title;

  @override
  State<InventoryApp> createState() => _InventoryAppState();
}

class _InventoryAppState extends State<InventoryApp> {
  final ApiService _api = ApiService();
  final List<Product> _products = [];

  bool _loaded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _api.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products
          ..clear()
          ..addAll(products);
        _error = null;
        _loaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loaded = true;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ---- Add ----
  Future<void> _addProduct() async {
    final result = await showDialog<Product>(
      context: context,
      builder: (_) => const ProductDialog(),
    );
    if (result == null) return;

    try {
      await _api.addProduct(
        result.name,
        result.price,
        result.description,
        result.quantity,
      );
      await _loadProducts();
      if (!mounted) return;
      _showMessage('"${result.name}" added');
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ---- Edit ----
  Future<void> _editProduct(Product product) async {
    final result = await showDialog<Product>(
      context: context,
      builder: (_) => ProductDialog(product: product),
    );
    if (result == null) return;

    try {
      await _api.updateProduct(
        product.id,
        result.name,
        result.price,
        result.description,
        result.quantity,
      );
      await _loadProducts();
      if (!mounted) return;
      _showMessage('"${result.name}" updated');
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ---- Delete (with confirmation) ----
  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(
          'Are you sure you want to delete "${product.name}"? '
          'This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _api.deleteProduct(product.id);
      await _loadProducts();
      if (!mounted) return;
      _showMessage('"${product.name}" deleted');
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _buildBody(),
      floatingActionButton: _loaded
          ? FloatingActionButton.extended(
              onPressed: _addProduct,
              icon: const Icon(Icons.add),
              label: const Text('Add product'),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (!_loaded) return const SizedBox.shrink();

    if (_error != null && _products.isEmpty) {
      return _ErrorState(message: _error!, onRetry: _loadProducts);
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: _products.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: const _EmptyState(),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              // extra bottom padding so the button doesn't cover the last item
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
              itemCount: _products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _products[index];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.inventory_2_outlined),
                    ),
                    title: Text(item.name),
                    subtitle: Text(
                      '₱${item.price.toStringAsFixed(2)}  •  Qty: ${item.quantity}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _editProduct(item),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _deleteProduct(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// If list is empty
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Your inventory is empty',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap Add product to add to your inventory.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Only shown if the server can't be reached
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 56, color: scheme.error),
            const SizedBox(height: 12),
            Text(
              "Couldn't load products",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
