import 'package:flutter/material.dart';

import '../models/product.dart';

enum ProductAction { edit, delete }

class ProductDetailsDialog extends StatelessWidget {
  const ProductDetailsDialog({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AlertDialog(
      title: Text(product.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              icon: Icons.sell_outlined,
              label: 'Price',
              value: '₱${product.price.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.inventory_2_outlined,
              label: 'Quantity',
              value: '${product.quantity}',
            ),
            const SizedBox(height: 16),
            Text(
              'Description:',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.description.isEmpty
                  ? 'No description'
                  : product.description,
              style: product.description.isEmpty
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
          onPressed: () => Navigator.of(context).pop(ProductAction.delete),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete'),
        ),
        FilledButton.tonalIcon(
          onPressed: () => Navigator.of(context).pop(ProductAction.edit),
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
