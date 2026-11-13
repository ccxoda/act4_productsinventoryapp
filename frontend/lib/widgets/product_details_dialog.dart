import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductDetailsDialog extends StatefulWidget {
  const ProductDetailsDialog({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;

  final Future<Product?> Function(Product product) onEdit;

  final Future<bool> Function(Product product) onDelete;

  @override
  State<ProductDetailsDialog> createState() => _ProductDetailsDialogState();
}

class _ProductDetailsDialogState extends State<ProductDetailsDialog> {
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  Future<void> _edit() async {
    final updated = await widget.onEdit(_product);
    if (updated != null && mounted) {
      setState(() => _product = updated); // dialog stays open, shows new info
    }
  }

  Future<void> _delete() async {
    final deleted = await widget.onDelete(_product);
    if (deleted && mounted) {
      Navigator.of(context).pop(); // product is gone, so close the details
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AlertDialog(
      title: Text(_product.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              icon: Icons.sell_outlined,
              label: 'Price',
              value: '₱${_product.price.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.inventory_2_outlined,
              label: 'Quantity',
              value: '${_product.quantity}',
            ),
            const SizedBox(height: 16),
            Text(
              'Description',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _product.description.isEmpty
                  ? 'No description'
                  : _product.description,
              style: _product.description.isEmpty
                  ? theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: scheme.onSurfaceVariant,
                    )
                  : theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: scheme.error),
          onPressed: _delete,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete'),
        ),
        FilledButton.tonalIcon(
          onPressed: _edit,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: scheme.onSurfaceVariant)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
