// lib/screens/customer/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/cart_provider.dart';
import '../../../services/firestore_service.dart';

class CheckoutScreen extends StatefulWidget {
  final String tableNumber;

  const CheckoutScreen({
    Key? key,
    required this.tableNumber,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      // Place order
      String orderId = await _firestoreService.placeOrder(
        tableNumber: widget.tableNumber,
        items: cart.getOrderItems(),
        total: cart.totalAmount,
        customerName: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        customerPhone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      // Clear cart
      cart.clear();

      // Navigate to confirmation screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(
            orderId: orderId,
            tableNumber: widget.tableNumber,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isPlacingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Table number
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.table_restaurant, color: Color(0xFFFF6B6B)),
                    SizedBox(width: 12),
                    Text(
                      'Table ${widget.tableNumber}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Customer details (optional)
            Text(
              'Your Details (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),

            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                hintText: '03XX-XXXXXXX',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: 24),

            // Payment method
            Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),

            Card(
              child: ListTile(
                leading: Icon(Icons.money, color: Colors.green),
                title: Text('Cash'),
                subtitle: Text('Pay when served'),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
            ),

            SizedBox(height: 24),

            // Order summary
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),

            Consumer<CartProvider>(
              builder: (context, cart, child) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ...cart.items.values.map((item) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x ${item.name}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  'PKR ${item.subtotal.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        Divider(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'PKR ${cart.totalAmount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6B6B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPlacingOrder ? null : _placeOrder,
              child: _isPlacingOrder
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                'Place Order',
                style: TextStyle(fontSize: 18),
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
        ),
      ),
    );
  }
}

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  final String tableNumber;

  const OrderConfirmationScreen({
    Key? key,
    required this.orderId,
    required this.tableNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green,
                ),
              ),

              SizedBox(height: 32),

              Text(
                'Order Placed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 16),

              Text(
                'Your order has been sent to the kitchen',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: 32),

              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order ID:'),
                          Text(
                            orderId.substring(0, 8).toUpperCase(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Table:'),
                          Text(
                            tableNumber,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your order will be ready in approximately 15-20 minutes',
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Go back to menu (pop all screens)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text('Done', style: TextStyle(fontSize: 16)),
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
    );
  }
}