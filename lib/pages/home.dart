import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '/component/order_list_page.dart';

import '/models/customer_model.dart';
import '/models/member_customer_model.dart';
import '/models/corporate_partner_model.dart';
import '/models/order_model.dart';
import '/models/kiloan_order_model.dart';
import '/models/satuan_order_model.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // Data dummy kita\
  // letakkan di sini agar bisa diakses
  static final budi = MemberCustomer(id: "CUST-01", name: "Budi Santoso", phoneNumber: "08123", memberId: "MEM-001", memberTier: "Gold");
  static final citra = CorporatePartner(id: "CUST-02", name: "Ibu Citra", phoneNumber: "08124", companyName: "Hotel Merdeka");
  static final ahmad = RegularCustomer(id: "CUST-03", name: "Ahmad Yani", phoneNumber: "08125");
  static final dewi = MemberCustomer(id: "CUST-04", name: "Dewi Anggraini", phoneNumber: "08126", memberId: "MEM-002", memberTier: "Silver");

  final List<Order> orders =[
    KiloanOrder(id: "INV-001", customer: budi, status: OrderStatus.selesai, entryDate: "16 Sep 2025", weightInKg: 3, pricePerKg: 15000),
    KiloanOrder(id: "INV-002", customer: citra, status: OrderStatus.prosesCuci, entryDate: "16 Sep 2025", weightInKg: 25, pricePerKg: 12000),
    SatuanOrder(id: "INV-003", customer: ahmad, status: OrderStatus.menungguDiambil, entryDate: "15 Sep 2025", items: [
        LaundryItem(name: "Jaket", quantity: 1, price: 20000), LaundryItem(name: "Celana Jeans", quantity: 1, price: 12000),
    ]),
    SatuanOrder(id: "INV-004", customer: dewi, status: OrderStatus.selesai, entryDate: "15 Sep 2025", items: [
        LaundryItem(name: "Set Sprei", quantity: 1, price: 60000), LaundryItem(name: "Gorden", quantity: 2, price: 25000),
    ]),
  ];

  // Data untuk menu utama
  final List<Map<String, dynamic>> mainMenuItems = const [
    {"name": "Tambah Pesanan", "icon": Icons.add_shopping_cart, "color": Colors.green},
    {"name": "Daftar Pesanan", "icon": Icons.list_alt, "color": Colors.blue},
    {"name": "Kelola Layanan", "icon": Icons.local_laundry_service, "color": Colors.orange},
    {"name": "Kelola Pelanggan", "icon": Icons.group, "color": Colors.purple},
    {"name": "Laporan Penjualan", "icon": Icons.assessment, "color": Colors.redAccent},
    {"name": "Atur Promo", "icon": Icons.discount, "color": Colors.pink},
  ];

  @override
  Widget build(BuildContext context) {
    // Kalkulasi dinamis dari data model
    final totalPendapatan = orders.fold<double>(0, (sum, order) => sum + order.finalTotalValue);
    final jumlahPesanan = orders.length;
    final pesananSelesai = orders.where((o) => o.status == OrderStatus.selesai).length;
    final pelangganAktif = orders.map((o) => o.customer.id).toSet().length;

    // Formatter untuk menampilkan angka sebagai Rupiah
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Halo, Admin!",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            "Ringkasan kinerja laundry Anda hari ini.",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          const Text(
            "Ringkasan Kinerja",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = (constraints.maxWidth > 800) ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: (crossAxisCount == 2) ? 1.8 : 2.2,
                children: [
                  SummaryCard(title: "Total Pendapatan", value: currencyFormatter.format(totalPendapatan), icon: Icons.monetization_on, color: Colors.deepPurple),
                  SummaryCard(title: "Jumlah Pesanan", value: "$jumlahPesanan Pesanan", icon: Icons.receipt_long, color: Colors.blue),
                  SummaryCard(title: "Pesanan Selesai", value: "$pesananSelesai Pesanan", icon: Icons.check_circle, color: Colors.green),
                  SummaryCard(title: "Pelanggan Aktif", value: "$pelangganAktif Pelanggan", icon: Icons.people_alt, color: Colors.orange),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          const Text(
            "Menu Utama",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = (constraints.maxWidth > 1000) ? 6 : (constraints.maxWidth > 600 ? 4 : 3);
              return GridView.builder(
                itemCount: mainMenuItems.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final item = mainMenuItems[index];
                  VoidCallback onTapAction;

                  if (item['name'] == "Daftar Pesanan") {
                    onTapAction = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderListPage(orders: orders)),
                      );
                    };
                  } else {
                    onTapAction = () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Anda memilih ${item['name']}")),
                      );
                    };
                  }
                  
                  return QuickActionButton(
                    title: item['name']!,
                    icon: item['icon'],
                    color: item['color'],
                    onTap: onTapAction,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({super.key, required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(alignment: Alignment.topRight, child: Icon(icon, color: Colors.white70, size: 30)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionButton({super.key, required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}