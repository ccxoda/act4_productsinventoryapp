import 'package:flutter/material.dart';
import 'package:act4_productsinventoryapp/models/product.dart';

class ProductInventoryApp extends StatelessWidget {
  const ProductInventoryApp({super.key, required this.title});
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

                              // edit and delete buttons sit at the side
                              // trailing: Row(
                              //   mainAxisSize: MainAxisSize.min,
                              //   children: [
                              //     IconButton(
                              //       tooltip: 'Edit',
                              //       icon: const Icon(Icons.edit_outlined),
                              //       onPressed: () => _editItem(index),
                              //     ),
                              //     IconButton(
                              //       tooltip: 'Delete',
                              //       icon: const Icon(Icons.delete_outline),
                              //       onPressed: () => _deleteItem(index),
                              //     ),
                              //   ],
                              // ),
                            ),
                          );
                        },
                      ),
              ),
              // elevated add button
              // SafeArea(
              //   top: false,
              //   child: Padding(
              //     padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              //     child: SizedBox(
              //       width: double.infinity,
              //       child: ElevatedButton.icon(
              //         onPressed: _addItem,
              //         icon: const Icon(Icons.add),
              //         label: const Text('Add Item'),
              //         style: ElevatedButton.styleFrom(
              //           padding: const EdgeInsets.symmetric(vertical: 16),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
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
              'Your list is empty',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap Add item to start your list.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// item dialog for adding or editing an item
// class ProductDialog extends StatefulWidget {
//   const ProductDialog({super.key, this.existingItem});

//   final Product? existingItem; // null = adding; not null = editing

//   @override
//   State<ProductDialog> createState() => _ProductDialogState();
// }

// class _ProductDialogState extends State<ProductDialog> {
//   late final TextEditingController _nameController;
//   late final TextEditingController _quantityController;
//   final _formKey = GlobalKey<FormState>();

//   bool get _isEditing => widget.existingItem != null;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(
//       text: widget.existingItem?.name ?? '',
//     );
//     _quantityController = TextEditingController(
//       text: widget.existingItem?.quantity ?? '',
//     );
//   }
//   // void _save() {
//   //   if (!_formKey.currentState!.validate()) return;
//   //   Navigator.of(context).pop(
//   //     Product(
//   //       name: _nameController.text.trim(),
//   //       quantity: _quantityController.text.trim(),
//   //     ),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text(_isEditing ? 'Edit Item' : 'Add Item'),
//       content: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextFormField(
//               controller: _nameController,
//               autofocus: true,
//               textCapitalization: TextCapitalization.sentences,
//               decoration: const InputDecoration(labelText: 'Item Name'),
//               validator: (value) => (value == null || value.trim().isEmpty)
//                   ? 'Please enter an item name'
//                   : null,
//               // onFieldSubmitted: (_) => _save(),
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: _quantityController,
//               decoration: const InputDecoration(
//                 labelText: 'Quantity (optional)',
//                 hintText: 'e.g. 1 kg, 2 packs, 3 bottles',
//               ),
//               // onFieldSubmitted: (_) => _save(),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         // ElevatedButton(onPressed: _save, child: const Text('Save')),
//         // FilledButton(
//         //   onPressed: _save,
//         //   child: Text(_isEditing ? 'Save Changes' : 'Add Item'),
//         // ),
//       ],
//     );
//   }
// }
