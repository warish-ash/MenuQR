// lib/screens/customer/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/firestore_service.dart';
import '../../../provider/cart_provider.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  final String tableNumber;

  const MenuScreen({
    Key? key,
    required this.tableNumber,
  }) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(
              'Table ${widget.tableNumber}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_basket_outlined, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartScreen(
                            tableNumber: widget.tableNumber,
                          ),
                        ),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B6B),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getMenuItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B6B)));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading menu'));
          }

          List<Map<String, dynamic>> items = snapshot.data ?? [];

          Set<String> categories = {'All'};
          for (var item in items) {
            if (item['category'] != null) categories.add(item['category']);
          }

          List<Map<String, dynamic>> filteredItems = _selectedCategory == 'All'
              ? items
              : items.where((item) => item['category'] == _selectedCategory).toList();

          return Column(
            children: [
              // Categories List
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  children: categories.map((category) {
                    bool isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                        },
                        selectedColor: const Color(0xFFFF6B6B),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // RESPONSIVE GRID
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220, // Prevents cards from getting too wide
                    childAspectRatio: 0.75,  // Controls height-to-width ratio
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    return MenuItemCard(item: filteredItems[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const MenuItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed Height Image to prevent stretching
          Container(
            height: 110,
            width: double.infinity,
            color: Colors.grey[200],
            child: Image.network(
              item['image_url'] ?? 'https://via.placeholder.com/150',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, color: Colors.grey),
            ),
          ),

          // Card Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PKR ${item['price']}',
                    style: const TextStyle(
                      color: Color(0xFFFF6B6B),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(), // Pushes the button to the very bottom
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false).addItem(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to cart'),
                            duration: Duration(milliseconds: 500),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Add', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}