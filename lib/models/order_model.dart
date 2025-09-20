import 'package:flutter/material.dart';
import 'customer_model.dart';

enum OrderStatus {
  prosesCuci('Proses Cuci', Colors.blue),
  menungguDiambil('Menunggu Diambil', Colors.orange),
  selesai('Selesai', Colors.green);

  const OrderStatus(this.displayName, this.color);
  final String displayName;
  final Color color;
}

abstract class Order {
  final String id;
  final Customer customer;
  final String entryDate;
  final OrderStatus status;

  Order({
    required this.id,
    required this.customer,
    required this.entryDate,
    required this.status,
  });

  String get totalDisplay;
  double get finalTotalValue;
  String get itemsDescription;

  double calculateFinalTotal(double baseTotal) {
    final discountAmount = baseTotal * customer.discountPercentage;
    return baseTotal - discountAmount;
  }
}