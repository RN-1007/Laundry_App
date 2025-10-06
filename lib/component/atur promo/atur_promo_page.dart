import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/promo_model.dart';

class AturPromoPage extends StatefulWidget {
  final List<Promo> promos;
  final Function(Promo) onPromoAdded;
  final Function(Promo) onPromoUpdated;
  final Function(String) onPromoDeleted;

  const AturPromoPage({
    super.key,
    required this.promos,
    required this.onPromoAdded,
    required this.onPromoUpdated,
    required this.onPromoDeleted,
  });

  @override
  State<AturPromoPage> createState() => _AturPromoPageState();
}

class _AturPromoPageState extends State<AturPromoPage> {
  void _showPromoDialog({Promo? existingPromo}) async {
    final bool isEditing = existingPromo != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: existingPromo?.name ?? '',
    );
    final valueController = TextEditingController(
      text: isEditing ? existingPromo.value.toStringAsFixed(0) : '',
    );
    final minTransController = TextEditingController(
      text: isEditing ? existingPromo.minTransaction.toStringAsFixed(0) : '0',
    );
    PromoType selectedType = existingPromo?.type ?? PromoType.percentage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Promo' : 'Buat Promo Baru'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Promo',
                        ),
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      DropdownButtonFormField<PromoType>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Tipe Promo',
                        ),
                        items: PromoType.values
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.displayName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setDialogState(() => selectedType = value!),
                      ),
                      TextFormField(
                        controller: valueController,
                        decoration: InputDecoration(
                          labelText: 'Nilai Promo',
                          suffixText: selectedType == PromoType.percentage
                              ? '%'
                              : '',
                          prefixText: selectedType == PromoType.fixed
                              ? 'Rp '
                              : '',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      TextFormField(
                        controller: minTransController,
                        decoration: const InputDecoration(
                          labelText: 'Minimal Transaksi',
                          prefixText: 'Rp ',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
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
                      final promo = Promo(
                        id:
                            existingPromo?.id ??
                            'PROMO-${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text,
                        type: selectedType,
                        value: double.parse(valueController.text),
                        minTransaction: double.parse(minTransController.text),
                        isActive: existingPromo?.isActive ?? true,
                      );
                      if (isEditing) {
                        widget.onPromoUpdated(promo);
                      } else {
                        widget.onPromoAdded(promo);
                      }
                      Navigator.pop(context);
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atur Promo')),
      body: widget.promos.isEmpty
          ? const Center(child: Text('Belum ada promo yang dibuat.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8).copyWith(bottom: 80),
              itemCount: widget.promos.length,
              itemBuilder: (context, index) {
                final promo = widget.promos[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      promo.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${promo.type.displayName} ${promo.type == PromoType.percentage ? '${promo.value}%' : 'Rp ${promo.value.toStringAsFixed(0)}'}'
                      '\nMin. Transaksi: Rp ${promo.minTransaction.toStringAsFixed(0)}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () =>
                              _showPromoDialog(existingPromo: promo),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => widget.onPromoDeleted(promo.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPromoDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Buat Promo'),
      ),
    );
  }
}
