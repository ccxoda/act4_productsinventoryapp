import 'package:flutter/material.dart';

import '../api_service.dart';
import '../models/product.dart';

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

enum ConnectionStatus { idle, connecting, connected, failed }

class InventoryApp extends StatefulWidget {
  const InventoryApp({super.key, required this.title});
  final String title;

  @override
  State<InventoryApp> createState() => _InventoryAppState();
}

class _InventoryAppState extends State<InventoryApp> {
  final ApiService _api = ApiService();
  final List<Product> _products = [];

  ConnectionStatus _status = ConnectionStatus.idle;
  String? _errorMessage;

  Future<void> _connect() async {
    setState(() {
      _status = ConnectionStatus.connecting;
      _errorMessage = null;
    });

    try {
      final products = await _api.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products
          ..clear()
          ..addAll(products);
        _status = ConnectionStatus.connected;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected! Loaded ${products.length} product(s).'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = ConnectionStatus.failed;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _status == ConnectionStatus.connecting;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Refresh from server',
            onPressed: isLoading ? null : _connect,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _ConnectionBanner(
            status: _status,
            errorMessage: _errorMessage,
            onConnect: isLoading ? null : _connect,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _connect,
              child: _products.isEmpty
                  ? ListView(
                      // ListView so pull-to-refresh works on the empty state
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: _EmptyState(status: _status),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                            subtitle: Text('Quantity: ${item.quantity}'),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows connection state and the Connect button.
class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner({
    required this.status,
    required this.errorMessage,
    required this.onConnect,
  });

  final ConnectionStatus status;
  final String? errorMessage;
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    late final Color bg;
    late final Color fg;
    late final IconData icon;
    late final String label;

    switch (status) {
      case ConnectionStatus.idle:
        bg = scheme.surfaceContainerHighest;
        fg = scheme.onSurfaceVariant;
        icon = Icons.cloud_off_outlined;
        label = 'Not connected to server';
      case ConnectionStatus.connecting:
        bg = scheme.secondaryContainer;
        fg = scheme.onSecondaryContainer;
        icon = Icons.cloud_sync_outlined;
        label = 'Connecting…';
      case ConnectionStatus.connected:
        bg = scheme.primaryContainer;
        fg = scheme.onPrimaryContainer;
        icon = Icons.cloud_done_outlined;
        label = 'Connected to server';
      case ConnectionStatus.failed:
        bg = scheme.errorContainer;
        fg = scheme.onErrorContainer;
        icon = Icons.cloud_off;
        label = errorMessage ?? 'Could not reach server';
    }

    final isConnecting = status == ConnectionStatus.connecting;

    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          isConnecting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                )
              : Icon(icon, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: fg),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onConnect,
            icon: Icon(
              status == ConnectionStatus.connected ? Icons.sync : Icons.link,
              size: 18,
            ),
            label: Text(
              status == ConnectionStatus.connected
                  ? 'Sync'
                  : status == ConnectionStatus.failed
                  ? 'Retry'
                  : 'Connect',
            ),
          ),
        ],
      ),
    );
  }
}

// If list is empty
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.status});
  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final connected = status == ConnectionStatus.connected;

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
              connected ? 'Your inventory is empty' : 'No data yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              connected
                  ? 'Your server has no products yet.'
                  : 'Tap Connect to load products from the server.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
