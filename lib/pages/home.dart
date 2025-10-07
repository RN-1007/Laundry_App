import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../component/tambah pesanan/add_order_page.dart';
import '../component/daftar pesanan/order_list_page.dart';
import '../component/kelola pelanggan/customer_list_page.dart';
import '../component/kelola layanan/template_layanan_page.dart';
import '../component/laporan penjualan/laporan_penjualan_page.dart';
import '../component/atur promo/atur_promo_page.dart';

import '/models/promo_model.dart';
import '/models/laundy_template_model.dart';
import '/models/customer_model.dart';
import '/models/order_model.dart';

class HomePage extends StatelessWidget {
  // Menerima semua data dan fungsi dari parent (MyHomePage)
  final List<Customer> customers;
  final List<Order> orders;
  final List<LaundryTemplate> templates;
  final List<Promo> promos;
  final Function(Order) onAddOrder;
  final Function(Order) onUpdateOrder;
  final Function(String) onDeleteOrder;
  final Function(Customer) onUpdateCustomer;
  final Function(LaundryTemplate) onAddTemplate;
  final Function(LaundryTemplate) onUpdateTemplate;
  final Function(String) onDeleteTemplate;
  final Function(Promo) onAddPromo;
  final Function(Promo) onUpdatePromo;
  final Function(String) onDeletePromo;

  const HomePage({
    super.key,
    required this.customers,
    required this.orders,
    required this.templates,
    required this.promos,
    required this.onAddOrder,
    required this.onUpdateOrder,
    required this.onDeleteOrder,
    required this.onUpdateCustomer,
    required this.onAddTemplate,
    required this.onUpdateTemplate,
    required this.onDeleteTemplate,
    required this.onAddPromo,
    required this.onUpdatePromo,
    required this.onDeletePromo,
  });

  // Data untuk UI Menu dikembalikan ke warna solid
  final List<Map<String, dynamic>> mainMenuItems = const [
    {
      "name": "Tambah Pesanan",
      "icon": Icons.add_shopping_cart,
      "color": Colors.green,
    },
    {"name": "Daftar Pesanan", "icon": Icons.list_alt, "color": Colors.blue},
    {
      "name": "Kelola Layanan",
      "icon": Icons.local_laundry_service,
      "color": Colors.orange,
    },
    {"name": "Kelola Pelanggan", "icon": Icons.group, "color": Colors.purple},
    {
      "name": "Laporan Penjualan",
      "icon": Icons.assessment,
      "color": Colors.redAccent,
    },
    {"name": "Atur Promo", "icon": Icons.discount, "color": Colors.pink},
  ];

  @override
  Widget build(BuildContext context) {
    final totalPendapatan = orders.fold<double>(
      0,
      (sum, order) => sum + order.finalTotalValue,
    );
    final jumlahPesanan = orders.length;
    final pesananSelesai = orders
        .where((o) => o.status == OrderStatus.selesai)
        .length;
    final pelangganAktif = orders.map((o) => o.customer.id).toSet().length;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Mengembalikan ke struktur awal dengan SingleChildScrollView
    return SingleChildScrollView(
      padding: const EdgeInsets.all(
        16.0,
      ).copyWith(bottom: 80), // Tambah padding bawah
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Halo, Admin!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Ringkasan kinerja laundry Anda hari ini.",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          const Text(
            "Ringkasan Kinerja",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
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
                childAspectRatio: (crossAxisCount == 2) ? 1.3 : 2.2,
                children: [
                  SummaryCard(
                    title: "Total Pendapatan",
                    value: currencyFormatter.format(totalPendapatan),
                    icon: Icons.monetization_on,
                    color: Colors.deepPurple,
                  ),
                  SummaryCard(
                    title: "Jumlah Pesanan",
                    value: "$jumlahPesanan Pesanan",
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                  ),
                  SummaryCard(
                    title: "Pesanan Selesai",
                    value: "$pesananSelesai Pesanan",
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  SummaryCard(
                    title: "Pelanggan Aktif",
                    value: "$pelangganAktif Pelanggan",
                    icon: Icons.people_alt,
                    color: Colors.orange,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          const Text(
            "Menu Utama",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = (constraints.maxWidth > 1000)
                  ? 6
                  : (constraints.maxWidth > 600 ? 3 : 2);
              return GridView.builder(
                itemCount: mainMenuItems.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final item = mainMenuItems[index];
                  VoidCallback onTapAction;
                  switch (item['name']) {
                    case "Tambah Pesanan":
                      onTapAction = () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddOrderPage(
                            onOrderAdded: onAddOrder,
                            existingCustomers: customers,
                            templates: templates,
                          ),
                        ),
                      );
                      break;
                    case "Daftar Pesanan":
                      onTapAction = () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderListPage(
                            orders: orders,
                            onOrderUpdated: onUpdateOrder,
                            onOrderDeleted: onDeleteOrder,
                          ),
                        ),
                      );
                      break;
                    case "Kelola Pelanggan":
                      onTapAction = () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerListPage(
                            customers: customers,
                            allOrders: orders,
                            onCustomerUpdated: onUpdateCustomer,
                          ),
                        ),
                      );
                      break;
                    case "Kelola Layanan":
                      onTapAction = () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TemplateLayananPage(
                            templates: templates,
                            onTemplateAdded: onAddTemplate,
                            onTemplateUpdated: onUpdateTemplate,
                            onTemplateDeleted: onDeleteTemplate,
                          ),
                        ),
                      );
                      break;
                    case "Laporan Penjualan":
                      onTapAction = () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LaporanPenjualanPage(allOrders: orders),
                        ),
                      );
                      break;
                    case "Atur Promo":
                      onTapAction = () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AturPromoPage(
                            promos: promos,
                            onPromoAdded: onAddPromo,
                            onPromoUpdated: onUpdatePromo,
                            onPromoDeleted: onDeletePromo,
                          ),
                        ),
                      );
                      break;
                    default:
                      onTapAction = () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Fitur '${item['name']}' belum diimplementasikan.",
                              ),
                            ),
                          );
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

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Mengembalikan gaya kartu ke tema terang
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
            Align(
              alignment: Alignment.topRight,
              child: Icon(icon, color: Colors.white70, size: 30),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
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

  const QuickActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Mengembalikan gaya tombol ke tema terang
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
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
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
