import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/models/order_model.dart';
import '/models/kiloan_order_model.dart';
import '/models/satuan_order_model.dart';

class EditOrderPage extends StatefulWidget {
  final Order order;
  final Function(Order) onOrderUpdated;

  const EditOrderPage({
    super.key,
    required this.order,
    required this.onOrderUpdated,
  });

  @override
  State<EditOrderPage> createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  final _formKey = GlobalKey<FormState>();

  late OrderStatus _status;
  late TextEditingController _weightController;
  late TextEditingController _pricePerKgController;
  late List<LaundryItem> _satuanItems;

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;

    if (widget.order is KiloanOrder) {
      final kiloanOrder = widget.order as KiloanOrder;
      _weightController = TextEditingController(
        text: kiloanOrder.weightInKg.toString(),
      );
      _pricePerKgController = TextEditingController(
        text: kiloanOrder.pricePerKg.toStringAsFixed(0),
      );
      _satuanItems = [];
    } else if (widget.order is SatuanOrder) {
      final satuanOrder = widget.order as SatuanOrder;
      _weightController = TextEditingController();
      _pricePerKgController = TextEditingController();
      _satuanItems = List.from(satuanOrder.items);
    } else {
      _weightController = TextEditingController();
      _pricePerKgController = TextEditingController();
      _satuanItems = [];
    }
  }

  void _addSatuanItem() {
    showDialog(
      context: context,
      builder: (context) {
        String itemName = '';
        int quantity = 1;
        double price = 0;

        return AlertDialog(
          title: const Text('Tambah Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nama Item',
                  hintText: 'Contoh: Kemeja, Celana',
                ),
                onChanged: (value) => itemName = value,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => quantity = int.tryParse(value) ?? 1,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Harga per Item',
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => price = double.tryParse(value) ?? 0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (itemName.isNotEmpty && price > 0) {
                  setState(() {
                    _satuanItems.add(
                      LaundryItem(
                        name: itemName,
                        quantity: quantity,
                        price: price,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _updateOrder() {
    if (_formKey.currentState!.validate()) {
      Order updatedOrder;

      if (widget.order is KiloanOrder) {
        final weight = double.tryParse(_weightController.text) ?? 0;
        final pricePerKg = double.tryParse(_pricePerKgController.text) ?? 15000;

        if (weight <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berat harus diisi dengan benar')),
          );
          return;
        }

        updatedOrder = KiloanOrder(
          id: widget.order.id,
          customer: widget.order.customer,
          entryDate: widget.order.entryDate,
          status: _status,
          weightInKg: weight,
          pricePerKg: pricePerKg,
        );
      } else if (widget.order is SatuanOrder) {
        if (_satuanItems.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tambahkan minimal 1 item')),
          );
          return;
        }

        updatedOrder = SatuanOrder(
          id: widget.order.id,
          customer: widget.order.customer,
          entryDate: widget.order.entryDate,
          status: _status,
          items: _satuanItems,
        );
      } else {
        return;
      }

      widget.onOrderUpdated(updatedOrder);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Pesanan ${widget.order.id}')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Information (Read-only)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'INFORMASI PESANAN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('No. Invoice:', widget.order.id),
                      _buildInfoRow('Pelanggan:', widget.order.customer.name),
                      _buildInfoRow(
                        'Tipe Pelanggan:',
                        widget.order.customer.customerType,
                      ),
                      _buildInfoRow('Tanggal Masuk:', widget.order.entryDate),
                      if (widget.order.customer.discountPercentage > 0)
                        _buildInfoRow(
                          'Diskon:',
                          '${(widget.order.customer.discountPercentage * 100).toStringAsFixed(0)}%',
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Status Update
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'UPDATE STATUS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<OrderStatus>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status Pesanan',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.pending_actions),
                        ),
                        items: OrderStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: status.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(status.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _status = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Order Details (Editable)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DETAIL CUCIAN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (widget.order is KiloanOrder) ...[
                        TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                            labelText: 'Berat (kg)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.scale),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Berat harus diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _pricePerKgController,
                          decoration: const InputDecoration(
                            labelText: 'Harga per kg',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                            prefixText: 'Rp ',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ] else if (widget.order is SatuanOrder) ...[
                        ElevatedButton.icon(
                          onPressed: _addSatuanItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Item'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_satuanItems.isNotEmpty) ...[
                          const Text(
                            'Daftar Item:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ..._satuanItems.map((item) {
                            return Card(
                              child: ListTile(
                                title: Text('${item.name} (${item.quantity}x)'),
                                subtitle: Text(
                                  'Rp ${item.price.toStringAsFixed(0)} per item',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Rp ${(item.quantity * item.price).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _satuanItems.remove(item);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Total Preview
              Card(
                elevation: 2,
                color: Colors.deepPurple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Estimasi:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _calculateTotal(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _calculateTotal() {
    double total = 0;

    if (widget.order is KiloanOrder) {
      final weight = double.tryParse(_weightController.text) ?? 0;
      final pricePerKg = double.tryParse(_pricePerKgController.text) ?? 0;
      total = weight * pricePerKg;
    } else if (widget.order is SatuanOrder) {
      total = _satuanItems.fold(
        0,
        (sum, item) => sum + (item.quantity * item.price),
      );
    }

    // Apply discount
    final discountAmount = total * widget.order.customer.discountPercentage;
    total = total - discountAmount;

    return 'Rp ${total.toStringAsFixed(0)}';
  }

  @override
  void dispose() {
    _weightController.dispose();
    _pricePerKgController.dispose();
    super.dispose();
  }
}
