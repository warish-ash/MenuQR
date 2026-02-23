// lib/screens/customer/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final String tableNumber;

  const CartScreen({
    Key? key,
    required this.tableNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add items from the menu',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Browse Menu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF6B6B),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart items list
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (context, index) => Divider(height: 32),
                  itemBuilder: (context, index) {
                    final item = cart.items.values.toList()[index];
                    return CartItemTile(item: item);
                  },
                ),
              ),

              // Bottom summary and checkout
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'PKR ${cart.totalAmount.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'PKR ${cart.totalAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B6B),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutScreen(
                                  tableNumber: tableNumber,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Proceed to Checkout',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF6B6B),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.imageUrl ?? 'https://via.placeholder.com/80',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: Icon(Icons.restaurant, color: Colors.grey),
              );
            },
          ),
        ),
        SizedBox(width: 12),

        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'PKR ${item.price.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  // Decrease button
                  InkWell(
                    onTap: () {
                      Provider.of<CartProvider>(context, listen: false)
                          .decreaseQuantity(item.id);
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(Icons.remove, size: 16),
                    ),
                  ),

                  // Quantity
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${item.quantity}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Increase button
                  InkWell(
                    onTap: () {
                      Provider.of<CartProvider>(context, listen: false)
                          .increaseQuantity(item.id);
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(Icons.add, size: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Subtotal and remove
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false)
                    .removeItem(item.id);
              },
            ),
            Text(
              'PKR ${item.subtotal.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}