import 'package:flutter/material.dart';
import 'package:act4_productsinventoryapp/models/product.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false, // the red debug banner
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.lightBlue)),
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
  final List<Product> _products = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              Expanded(
                child: _products.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        itemCount: _products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _products[index];
                          return Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              title: Text(item.name),
                              subtitle: item.quantity == 0
                                  ? null
                                  : Text('Quantity: ${item.quantity}'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
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
