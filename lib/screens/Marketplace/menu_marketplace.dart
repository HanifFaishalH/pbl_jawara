import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class MarketplaceMenu extends StatefulWidget {
  const MarketplaceMenu({super.key});

  @override
  State<MarketplaceMenu> createState() => _MarketplaceMenuState();
}

class _MarketplaceMenuState extends State<MarketplaceMenu> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      extendBody: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 24, right: 16, left: 16),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarketplaceHeader(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MarketplaceItem extends StatefulWidget {
  const MarketplaceItem({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  State<MarketplaceItem> createState() => _MarketplaceItemState();
}

class _MarketplaceItemState extends State<MarketplaceItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => context.go(widget.route),
      onHover: (hovering) {
        setState(() {
          _isHovering = hovering;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: _isHovering ? colorScheme.surfaceVariant : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FaIcon(widget.icon, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MarketplaceHeader extends StatelessWidget {
  const MarketplaceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final items = [
      {
        'label': 'Jual Batik',
        'icon': FontAwesomeIcons.shop,
        'route': '/daftar-barang-jual',
      },
      {
        'label': 'Beli Batik',
        'icon': FontAwesomeIcons.cartShopping,
        'route': '/daftar-pembelian',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilih Menu Marketplace', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((e) {
              return Expanded(
                child: MarketplaceItem(
                  icon: e['icon'] as IconData,
                  label: e['label'] as String,
                  route: e['route'] as String,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
