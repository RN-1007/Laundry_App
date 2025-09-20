import 'package:flutter/material.dart';
import 'order_detail_page.dart';
import '../models/order_model.dart';

class OrderListPage extends StatelessWidget {
  final List<Order> orders;

  const OrderListPage({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Semua Pesanan"),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(
                backgroundColor: order.status.color,
                child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
              ),
              title: Text(order.customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Status: ${order.status.displayName} (${order.customer.customerType})"),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailPage(order: order),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}