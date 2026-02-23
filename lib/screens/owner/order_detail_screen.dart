// lib/screens/owner/order_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isUpdating = false;

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);

    try {
      await _firestoreService.updateOrderStatus(widget.orderId, newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _firestoreService.getOrder(widget.orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('Order not found'),
            );
          }

          final order = snapshot.data!;
          final items = order['items'] as List<dynamic>? ?? [];
          final status = order['status'] ?? 'pending';
          final total = order['total'] ?? 0;
          final tableNumber = order['table_number'] ?? 'N/A';
          final createdAt = order['created_at'] as DateTime?;
          final customerName = order['customer_name'] ?? '';
          final customerPhone = order['customer_phone'] ?? '';

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    // Status badge
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Order info card
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            _InfoRow(
                              icon: Icons.table_restaurant,
                              label: 'Table',
                              value: tableNumber,
                            ),
                            if (createdAt != null) ...[
                              SizedBox(height: 12),
                              _InfoRow(
                                icon: Icons.access_time,
                                label: 'Time',
                                value: DateFormat('hh:mm a').format(createdAt),
                              ),
                            ],
                            if (customerName.isNotEmpty) ...[
                              SizedBox(height: 12),
                              _InfoRow(
                                icon: Icons.person,
                                label: 'Customer',
                                value: customerName,
                              ),
                            ],
                            if (customerPhone.isNotEmpty) ...[
                              SizedBox(height: 12),
                              _InfoRow(
                                icon: Icons.phone,
                                label: 'Phone',
                                value: customerPhone,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Items card
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Items',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            ...items.map((item) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item['quantity']}x ${item['name']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Text(
                                      'PKR ${(item['subtotal'] ?? 0).toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 16,
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'PKR ${total.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 20,
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
                  ],
                ),
              ),

              // Action buttons
              if (status != 'served')
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
                    child: _buildActionButtons(status),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(String currentStatus) {
    if (_isUpdating) {
      return Center(child: CircularProgressIndicator());
    }

    switch (currentStatus) {
      case 'pending':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _updateStatus('cancelled'),
                child: Text('Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _updateStatus('preparing'),
                child: Text('Accept Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );

      case 'preparing':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _updateStatus('ready'),
            child: Text('Mark as Ready'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );

      case 'ready':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _updateStatus('served'),
            child: Text('Mark as Served'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );

      default:
        return SizedBox.shrink();
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}