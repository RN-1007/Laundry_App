import 'package:flutter/material.dart';
import '/models/corporate_partner_model.dart';
import '/models/customer_model.dart';
import '/models/member_customer_model.dart';
import '/models/order_model.dart';
import 'customer_history_page.dart';

class CustomerListPage extends StatefulWidget {
  final List<Customer> customers;
  final List<Order> allOrders;
  final Function(Customer) onCustomerUpdated; // Callback untuk update

  const CustomerListPage({
    super.key,
    required this.customers,
    required this.allOrders,
    required this.onCustomerUpdated,
  });

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  String _searchQuery = '';

  List<Customer> get filteredCustomers {
    if (_searchQuery.isEmpty) {
      return widget.customers;
    }
    return widget.customers.where((customer) {
      return customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer.phoneNumber.contains(_searchQuery);
    }).toList();
  }

  void _showEditCustomerDialog(Customer customer) {
    final formKey = GlobalKey<FormState>();
    String customerType = 'Reguler';
    if (customer is MemberCustomer) {
      customerType = 'Member';
    } else if (customer is CorporatePartner) {
      customerType = 'Partner Korporat';
    }

    final memberIdController = TextEditingController(
      text: (customer is MemberCustomer) ? customer.memberId : '',
    );
    final memberTierController = TextEditingController(
      text: (customer is MemberCustomer) ? customer.memberTier : 'Silver',
    );
    final companyNameController = TextEditingController(
      text: (customer is CorporatePartner) ? customer.companyName : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Edit ${customer.name}'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: customerType,
                        decoration: const InputDecoration(
                          labelText: 'Tipe Pelanggan',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Reguler',
                            child: Text('Reguler'),
                          ),
                          DropdownMenuItem(
                            value: 'Member',
                            child: Text('Member'),
                          ),
                          DropdownMenuItem(
                            value: 'Partner Korporat',
                            child: Text('Partner Korporat'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            customerType = value!;
                          });
                        },
                      ),
                      if (customerType == 'Member') ...[
                        TextFormField(
                          controller: memberIdController,
                          decoration: const InputDecoration(
                            labelText: 'Member ID',
                          ),
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                        ),
                        DropdownButtonFormField<String>(
                          value: memberTierController.text,
                          decoration: const InputDecoration(
                            labelText: 'Tier Member',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Silver',
                              child: Text('Silver'),
                            ),
                            DropdownMenuItem(
                              value: 'Gold',
                              child: Text('Gold'),
                            ),
                          ],
                          onChanged: (v) => memberTierController.text = v!,
                        ),
                      ],
                      if (customerType == 'Partner Korporat') ...[
                        TextFormField(
                          controller: companyNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Perusahaan',
                          ),
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Customer updatedCustomer;
                      switch (customerType) {
                        case 'Member':
                          updatedCustomer = MemberCustomer(
                            id: customer.id,
                            name: customer.name,
                            phoneNumber: customer.phoneNumber,
                            memberId: memberIdController.text,
                            memberTier: memberTierController.text,
                          );
                          break;
                        case 'Partner Korporat':
                          updatedCustomer = CorporatePartner(
                            id: customer.id,
                            name: customer.name,
                            phoneNumber: customer.phoneNumber,
                            companyName: companyNameController.text,
                          );
                          break;
                        default:
                          updatedCustomer = RegularCustomer(
                            id: customer.id,
                            name: customer.name,
                            phoneNumber: customer.phoneNumber,
                          );
                      }
                      widget.onCustomerUpdated(updatedCustomer);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data pelanggan berhasil diperbarui!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customers = filteredCustomers;

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pelanggan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama atau nomor telepon...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: customers.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada pelanggan yang ditemukan.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      final customerOrders = widget.allOrders
                          .where((order) => order.customer.id == customer.id)
                          .toList();

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            child: Text(
                              customer.name.substring(0, 1),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            customer.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${customer.customerType} - ${customer.phoneNumber}",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => _showEditCustomerDialog(customer),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerHistoryPage(
                                  customer: customer,
                                  orders: customerOrders,
                                ),
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
}
