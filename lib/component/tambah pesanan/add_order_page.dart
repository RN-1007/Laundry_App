import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:LAUNDRY_APP/models/laundy_template_model.dart';
import '/models/customer_model.dart';
import '/models/member_customer_model.dart';
import '/models/corporate_partner_model.dart';
import '/models/order_model.dart';
import '/models/kiloan_order_model.dart';
import '/models/satuan_order_model.dart';

class AddOrderPage extends StatefulWidget {
  final Function(Order) onOrderAdded;
  final List<Customer> existingCustomers;
  final List<LaundryTemplate> templates;

  const AddOrderPage({
    super.key,
    required this.onOrderAdded,
    required this.existingCustomers,
    required this.templates,
  });

  @override
  State<AddOrderPage> createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrderPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _invoiceController = TextEditingController();
  final _weightController = TextEditingController();
  final _pricePerKgController = TextEditingController(text: '15000');

  // Variables
  String _orderType = 'kiloan';
  Customer? _selectedCustomer;
  bool _isNewCustomer = false;
  OrderStatus _status = OrderStatus.prosesCuci;
  List<LaundryItem> _satuanItems = [];

  // New customer fields
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  String _customerType = 'regular';
  final _memberIdController = TextEditingController();
  String _memberTier = 'Silver';
  final _companyNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateInvoiceNumber();
  }

  void _generateInvoiceNumber() {
    final now = DateTime.now();
    _invoiceController.text =
        'INV-${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  void _showKiloanTemplatePicker() {
    final kiloanTemplates = widget.templates
        .where((t) => t.type == TemplateType.kiloan)
        .toList();
    if (kiloanTemplates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada template kiloan.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Pilih Template Kiloan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: kiloanTemplates.length,
                itemBuilder: (context, index) {
                  final template = kiloanTemplates[index];
                  return ListTile(
                    title: Text(template.name),
                    trailing: Text('Rp ${template.price.toStringAsFixed(0)}'),
                    onTap: () {
                      setState(() {
                        _pricePerKgController.text = template.price
                            .toStringAsFixed(0);
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSatuanTemplatePicker() {
    final satuanTemplates = widget.templates
        .where((t) => t.type == TemplateType.satuan)
        .toList();
    if (satuanTemplates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada template satuan.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Pilih Template Satuan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: satuanTemplates.length,
                itemBuilder: (context, index) {
                  final template = satuanTemplates[index];
                  return ListTile(
                    title: Text(template.name),
                    trailing: Text('Rp ${template.price.toStringAsFixed(0)}'),
                    onTap: () {
                      setState(() {
                        _satuanItems.add(
                          LaundryItem(
                            name: template.name,
                            quantity: 1,
                            price: template.price,
                          ),
                        );
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _addSatuanItem() {
    showDialog(
      context: context,
      builder: (context) {
        String itemName = '';
        int quantity = 1;
        double price = 0;

        return AlertDialog(
          title: const Text('Tambah Item Manual'),
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

  Customer? _createNewCustomer() {
    final customerId =
        'CUST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    switch (_customerType) {
      case 'member':
        return MemberCustomer(
          id: customerId,
          name: _customerNameController.text,
          phoneNumber: _customerPhoneController.text,
          memberId: _memberIdController.text,
          memberTier: _memberTier,
        );
      case 'corporate':
        return CorporatePartner(
          id: customerId,
          name: _customerNameController.text,
          phoneNumber: _customerPhoneController.text,
          companyName: _companyNameController.text,
        );
      default:
        return RegularCustomer(
          id: customerId,
          name: _customerNameController.text,
          phoneNumber: _customerPhoneController.text,
        );
    }
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      if (!_isNewCustomer && _selectedCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih pelanggan')),
        );
        return;
      }

      if (_isNewCustomer && _customerNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan isi data pelanggan')),
        );
        return;
      }

      final customer = _isNewCustomer
          ? _createNewCustomer()!
          : _selectedCustomer!;
      final entryDate =
          '${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}';

      Order? newOrder;

      if (_orderType == 'kiloan') {
        final weight = double.tryParse(_weightController.text) ?? 0;
        final pricePerKg = double.tryParse(_pricePerKgController.text) ?? 15000;

        if (weight <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berat harus diisi dengan benar')),
          );
          return;
        }

        newOrder = KiloanOrder(
          id: _invoiceController.text,
          customer: customer,
          entryDate: entryDate,
          status: _status,
          weightInKg: weight,
          pricePerKg: pricePerKg,
        );
      } else {
        if (_satuanItems.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tambahkan minimal 1 item')),
          );
          return;
        }

        newOrder = SatuanOrder(
          id: _invoiceController.text,
          customer: customer,
          entryDate: entryDate,
          status: _status,
          items: _satuanItems,
        );
      }

      widget.onOrderAdded(newOrder);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pesanan Baru')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
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
                      TextFormField(
                        controller: _invoiceController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Invoice',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.receipt),
                        ),
                        readOnly: true,
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
                        onChanged: (value) => setState(() => _status = value!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DATA PELANGGAN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Lama'),
                              value: false,
                              groupValue: _isNewCustomer,
                              onChanged: (v) =>
                                  setState(() => _isNewCustomer = v!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('Baru'),
                              value: true,
                              groupValue: _isNewCustomer,
                              onChanged: (v) =>
                                  setState(() => _isNewCustomer = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!_isNewCustomer)
                        DropdownButtonFormField<Customer>(
                          value: _selectedCustomer,
                          decoration: const InputDecoration(
                            labelText: 'Pilih Pelanggan',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          // --- PERUBAHAN DI SINI ---
                          isExpanded: true, // Membuat dropdown memenuhi lebar
                          items: widget.existingCustomers.map((customer) {
                            return DropdownMenuItem(
                              value: customer,
                              child: Text(
                                '${customer.name} (${customer.customerType})',
                                overflow: TextOverflow
                                    .ellipsis, // Menambahkan elipsis jika teks terlalu panjang
                              ),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedCustomer = value),
                        )
                      else ...[
                        TextFormField(
                          controller: _customerNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Pelanggan',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (v) =>
                              (_isNewCustomer && (v == null || v.isEmpty))
                              ? 'Nama pelanggan harus diisi'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _customerPhoneController,
                          decoration: const InputDecoration(
                            labelText: 'Nomor Telepon',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _customerType,
                          decoration: const InputDecoration(
                            labelText: 'Tipe Pelanggan',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'regular',
                              child: Text('Reguler'),
                            ),
                            DropdownMenuItem(
                              value: 'member',
                              child: Text('Member'),
                            ),
                            DropdownMenuItem(
                              value: 'corporate',
                              child: Text('Partner Korporat'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _customerType = value!),
                        ),
                        if (_customerType == 'member') ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _memberIdController,
                            decoration: const InputDecoration(
                              labelText: 'Member ID',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.card_membership),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _memberTier,
                            decoration: const InputDecoration(
                              labelText: 'Tier Member',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.star),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Silver',
                                child: Text('Silver (10% diskon)'),
                              ),
                              DropdownMenuItem(
                                value: 'Gold',
                                child: Text('Gold (20% diskon)'),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _memberTier = value!),
                          ),
                        ],
                        if (_customerType == 'corporate') ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _companyNameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Perusahaan',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.business),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
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
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Kiloan'),
                              value: 'kiloan',
                              groupValue: _orderType,
                              onChanged: (v) => setState(() => _orderType = v!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Satuan'),
                              value: 'satuan',
                              groupValue: _orderType,
                              onChanged: (v) => setState(() => _orderType = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_orderType == 'kiloan') ...[
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
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Berat harus diisi'
                              : null,
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
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _showKiloanTemplatePicker,
                            icon: const Icon(Icons.bolt, size: 18),
                            label: const Text('Gunakan Template'),
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _addSatuanItem,
                                icon: const Icon(Icons.add),
                                label: const Text('Tambah Manual'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _showSatuanTemplatePicker,
                                icon: const Icon(Icons.bolt),
                                label: const Text('Dari Template'),
                              ),
                            ),
                          ],
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
                                      onPressed: () => setState(
                                        () => _satuanItems.remove(item),
                                      ),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Pesanan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _weightController.dispose();
    _pricePerKgController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _memberIdController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }
}
