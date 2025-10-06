import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart'; // Import auto_size_text
import '../../models/order_model.dart';
import '../../models/satuan_order_model.dart';
import '../../models/kiloan_order_model.dart';

enum ReportPeriod { today, thisWeek, thisMonth, allTime }

class LaporanPenjualanPage extends StatefulWidget {
  final List<Order> allOrders;

  const LaporanPenjualanPage({super.key, required this.allOrders});

  @override
  State<LaporanPenjualanPage> createState() => _LaporanPenjualanPageState();
}

class _LaporanPenjualanPageState extends State<LaporanPenjualanPage> {
  ReportPeriod _selectedPeriod = ReportPeriod.allTime;
  late List<Order> _filteredOrders;

  @override
  void initState() {
    super.initState();
    _filterOrders();
  }

  void _filterOrders() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final DateFormat format = DateFormat("d MMM yyyy", "id_ID");

    setState(() {
      switch (_selectedPeriod) {
        case ReportPeriod.today:
          _filteredOrders = widget.allOrders.where((order) {
            try {
              final orderDate = format.parse(order.entryDate);
              return orderDate.isAtSameMomentAs(today);
            } catch (e) {
              return false;
            }
          }).toList();
          break;
        case ReportPeriod.thisWeek:
          final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
          _filteredOrders = widget.allOrders.where((order) {
            try {
              final orderDate = format.parse(order.entryDate);
              return orderDate.isAfter(
                    startOfWeek.subtract(const Duration(days: 1)),
                  ) &&
                  orderDate.isBefore(now.add(const Duration(days: 1)));
            } catch (e) {
              return false;
            }
          }).toList();
          break;
        case ReportPeriod.thisMonth:
          _filteredOrders = widget.allOrders.where((order) {
            try {
              final orderDate = format.parse(order.entryDate);
              return orderDate.year == now.year && orderDate.month == now.month;
            } catch (e) {
              return false;
            }
          }).toList();
          break;
        case ReportPeriod.allTime:
        default:
          _filteredOrders = List.from(widget.allOrders);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalPendapatan = _filteredOrders.fold<double>(
      0,
      (sum, order) => sum + order.finalTotalValue,
    );
    final totalPesanan = _filteredOrders.length;
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Penjualan')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SegmentedButton<ReportPeriod>(
              segments: const [
                ButtonSegment(
                  value: ReportPeriod.today,
                  label: Text('Hari Ini'),
                ),
                ButtonSegment(
                  value: ReportPeriod.thisWeek,
                  label: Text('Minggu Ini'),
                ),
                ButtonSegment(
                  value: ReportPeriod.thisMonth,
                  label: Text('Bulan Ini'),
                ),
                ButtonSegment(
                  value: ReportPeriod.allTime,
                  label: Text('Semua'),
                ),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _selectedPeriod = newSelection.first;
                  _filterOrders();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              // --- PERUBAHAN 1: Memberi lebih banyak ruang vertikal pada kartu ---
              childAspectRatio: 1.8,
              children: [
                _buildSummaryCard(
                  'Total Pendapatan',
                  currencyFormatter.format(totalPendapatan),
                  Icons.monetization_on,
                  Colors.green,
                ),
                _buildSummaryCard(
                  'Total Pesanan',
                  '$totalPesanan Pesanan',
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _filteredOrders.isEmpty
                ? const Center(child: Text('Tidak ada data untuk periode ini.'))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildTopListCard(
                        title: 'Layanan Terlaris',
                        icon: Icons.star,
                        data: _getTopServices(),
                      ),
                      const SizedBox(height: 16),
                      _buildTopListCard(
                        title: 'Pelanggan Teratas',
                        icon: Icons.person,
                        data: _getTopCustomers(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getTopServices() {
    var serviceCounts = <String, int>{};
    for (var order in _filteredOrders) {
      if (order is KiloanOrder) {
        serviceCounts.update(
          'Pakaian Harian (Kiloan)',
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      } else if (order is SatuanOrder) {
        for (var item in order.items) {
          serviceCounts.update(
            item.name,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
        }
      }
    }
    var sortedServices = serviceCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedServices.take(5));
  }

  Map<String, int> _getTopCustomers() {
    var customerCounts = <String, int>{};
    for (var order in _filteredOrders) {
      customerCounts.update(
        order.customer.name,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    var sortedCustomers = customerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedCustomers.take(5));
  }

  // --- PERUBAHAN 2: Memperbaiki tata letak kartu agar lebih responsif ---
  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(icon, color: color, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                AutoSizeText(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  minFontSize: 14, // Ukuran font minimum
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopListCard({
    required String title,
    required IconData icon,
    required Map<String, int> data,
  }) {
    // ... (kode ini tidak perlu diubah)
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            if (data.isEmpty)
              const Text('Tidak ada data.')
            else
              ...data.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(entry.key, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.value}x',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
