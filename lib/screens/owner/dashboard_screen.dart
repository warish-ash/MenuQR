// lib/screens/owner/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import 'order_detail_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  String _selectedStatus = 'pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status tabs
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatusTab(
                    label: 'Pending',
                    status: 'pending',
                    isSelected: _selectedStatus == 'pending',
                    color: Colors.orange,
                    onTap: () => setState(() => _selectedStatus = 'pending'),
                  ),
                  _StatusTab(
                    label: 'Preparing',
                    status: 'preparing',
                    isSelected: _selectedStatus == 'preparing',
                    color: Colors.blue,
                    onTap: () => setState(() => _selectedStatus = 'preparing'),
                  ),
                  _StatusTab(
                    label: 'Ready',
                    status: 'ready',
                    isSelected: _selectedStatus == 'ready',
                    color: Colors.green,
                    onTap: () => setState(() => _selectedStatus = 'ready'),
                  ),
                  _StatusTab(
                    label: 'Served',
                    status: 'served',
                    isSelected: _selectedStatus == 'served',
                    color: Colors.grey,
                    onTap: () => setState(() => _selectedStatus = 'served'),
                  ),
                ],
              ),
            ),
          ),

          // Orders list
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Error loading orders'),
                        SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No orders yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Orders will appear here',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Filter orders by selected status
                List<Map<String, dynamic>> filteredOrders = snapshot.data!
                    .where((order) => order['status'] == _selectedStatus)
                    .toList();

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No ${_selectedStatus} orders',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return OrderCard(order: filteredOrders[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  final String label;
  final String status;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _StatusTab({
    required this.label,
    required this.status,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? color : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : Colors.grey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Just now';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'served':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = order['items'] as List<dynamic>? ?? [];
    final total = order['total'] ?? 0;
    final tableNumber = order['table_number'] ?? 'N/A';
    final status = order['status'] ?? 'pending';
    final createdAt = order['created_at'] as DateTime?;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(orderId: order['id']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.table_restaurant,
                          color: _getStatusColor(status),
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Table $tableNumber',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getTimeAgo(createdAt),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 8),

              // Items
              ...items.take(3).map((item) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${item['quantity']}x ${item['name']}',
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),

              if (items.length > 3)
                Text(
                  '+${items.length - 3} more items',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),

              SizedBox(height: 12),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'PKR ${total.toStringAsFixed(0)}',
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
      ),
    );
  }
}