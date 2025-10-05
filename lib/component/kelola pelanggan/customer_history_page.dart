import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/models/customer_model.dart';
import '/models/order_model.dart';
import '../order_detail_page.dart';

class CustomerHistoryPage extends StatelessWidget {
  final Customer customer;
  final List<Order> orders;

  const CustomerHistoryPage({
    super.key,
    required this.customer,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    final sortedOrders = List<Order>.from(orders)
      ..sort((a, b) => b.entryDate.compareTo(a.entryDate));

    final totalSpent = orders.fold<double>(
      0,
      (sum, order) => sum + order.finalTotalValue,
    );
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Riwayat ${customer.name}')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.phone, customer.phoneNumber),
                  _buildInfoRow(Icons.card_membership, customer.customerType),
                  const Divider(height: 24),
                  _buildSummaryRow("Total Transaksi:", "${orders.length} kali"),
                  _buildSummaryRow(
                    "Total Pengeluaran:",
                    currencyFormatter.format(totalSpent),
                  ),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Daftar Transaksi",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: sortedOrders.isEmpty
                ? const Center(child: Text("Tidak ada riwayat transaksi."))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sortedOrders.length,
                    itemBuilder: (context, index) {
                      final order = sortedOrders[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: order.status.color,
                            child: const Icon(
                              Icons.receipt_long,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text("Invoice: ${order.id}"),
                          subtitle: Text(
                            "Tanggal: ${order.entryDate}\nTotal: ${order.totalDisplay}",
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          isThreeLine: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OrderDetailPage(order: order),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
