//lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // IMPORTANT: Replace this with your actual restaurant ID from Firebase
  static const String RESTAURANT_ID = "JevlrjzZf9cCo51gv8Cq";

  // ========================================
  // MENU ITEMS
  // ========================================

  /// Get all menu items for the restaurant
  Stream<List<Map<String, dynamic>>> getMenuItems() {
    return _db
        .collection('menu_items')
        .where('restaurant_id', isEqualTo: RESTAURANT_ID)
        .where('is_available', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  /// Get single menu item by ID
  Future<Map<String, dynamic>?> getMenuItem(String itemId) async {
    try {
      DocumentSnapshot doc = await _db.collection('menu_items').doc(itemId).get();
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      print('Error getting menu item: $e');
      return null;
    }
  }

  // ========================================
  // ORDERS
  // ========================================

  /// Place a new order
  Future<String> placeOrder({
    required String tableNumber,
    required List<Map<String, dynamic>> items,
    required double total,
    String? customerName,
    String? customerPhone,
  }) async {
    try {
      DocumentReference orderRef = await _db.collection('orders').add({
        'restaurant_id': RESTAURANT_ID,
        'table_number': tableNumber,
        'items': items,
        'total': total,
        'customer_name': customerName ?? '',
        'customer_phone': customerPhone ?? '',
        'status': 'pending',
        'payment_method': 'cash',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      return orderRef.id;
    } catch (e) {
      print('Error placing order: $e');
      rethrow;
    }
  }

  /// Get real-time orders stream for restaurant
  Stream<List<Map<String, dynamic>>> getOrders() {
    return _db
        .collection('orders')
        .where('restaurant_id', isEqualTo: RESTAURANT_ID)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return {
          'id': doc.id,
          ...data,
          // Convert Timestamp to DateTime for easier handling
          'created_at': (data['created_at'] as Timestamp?)?.toDate(),
          'updated_at': (data['updated_at'] as Timestamp?)?.toDate(),
        };
      }).toList();
    });
  }

  /// Get single order by ID
  Stream<Map<String, dynamic>?> getOrder(String orderId) {
    return _db
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
          'created_at': (data['created_at'] as Timestamp?)?.toDate(),
          'updated_at': (data['updated_at'] as Timestamp?)?.toDate(),
        };
      }
      return null;
    });
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  // ========================================
  // RESTAURANT
  // ========================================

  /// Get restaurant details
  Future<Map<String, dynamic>?> getRestaurant() async {
    try {
      DocumentSnapshot doc = await _db.collection('restaurants').doc(RESTAURANT_ID).get();
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      print('Error getting restaurant: $e');
      return null;
    }
  }

  // ========================================
  // TABLES
  // ========================================

  /// Get all tables
  Future<List<Map<String, dynamic>>> getTables() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('tables')
          .where('restaurant_id', isEqualTo: RESTAURANT_ID)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      print('Error getting tables: $e');
      return [];
    }
  }
}