import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/models/laundy_template_model.dart';

class TemplateLayananPage extends StatefulWidget {
  final List<LaundryTemplate> templates;
  final Function(LaundryTemplate) onTemplateAdded;
  final Function(LaundryTemplate) onTemplateUpdated;
  final Function(String) onTemplateDeleted;

  const TemplateLayananPage({
    super.key,
    required this.templates,
    required this.onTemplateAdded,
    required this.onTemplateUpdated,
    required this.onTemplateDeleted,
  });

  @override
  State<TemplateLayananPage> createState() => _TemplateLayananPageState();
}

class _TemplateLayananPageState extends State<TemplateLayananPage> {
  // Mengubah fungsi menjadi async
  void _showTemplateDialog({LaundryTemplate? existingTemplate}) async {
    final bool isEditing = existingTemplate != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: existingTemplate?.name ?? '',
    );
    final priceController = TextEditingController(
      text: existingTemplate?.price.toStringAsFixed(0) ?? '',
    );
    TemplateType selectedType = existingTemplate?.type ?? TemplateType.kiloan;

    // Menunggu dialog ditutup
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Template' : 'Buat Template Baru'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Layanan',
                          hintText: 'Contoh: Cuci Setrika Ekspress',
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<TemplateType>(
                        value: selectedType,
                        decoration: const InputDecoration(labelText: 'Tipe'),
                        items: const [
                          DropdownMenuItem(
                            value: TemplateType.kiloan,
                            child: Text('Kiloan'),
                          ),
                          DropdownMenuItem(
                            value: TemplateType.satuan,
                            child: Text('Satuan'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Harga',
                          prefixText: 'Rp ',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) =>
                            v!.isEmpty ? 'Harga tidak boleh kosong' : null,
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
                      final template = LaundryTemplate(
                        id:
                            existingTemplate?.id ??
                            'TMP-${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text,
                        type: selectedType,
                        price: double.parse(priceController.text),
                      );

                      if (isEditing) {
                        widget.onTemplateUpdated(template);
                      } else {
                        widget.onTemplateAdded(template);
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

    // Memanggil setState() SETELAH dialog ditutup untuk me-refresh UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final kiloanTemplates = widget.templates
        .where((t) => t.type == TemplateType.kiloan)
        .toList();
    final satuanTemplates = widget.templates
        .where((t) => t.type == TemplateType.satuan)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Template Layanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16).copyWith(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Template Kiloan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            kiloanTemplates.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Belum ada template kiloan.'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: kiloanTemplates.length,
                    itemBuilder: (context, index) {
                      final template = kiloanTemplates[index];
                      return Card(
                        child: ListTile(
                          title: Text(template.name),
                          subtitle: Text(
                            'Rp ${template.price.toStringAsFixed(0)} /kg',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () => _showTemplateDialog(
                                  existingTemplate: template,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    widget.onTemplateDeleted(template.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 24),
            const Text(
              'Template Satuan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            satuanTemplates.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Belum ada template satuan.'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: satuanTemplates.length,
                    itemBuilder: (context, index) {
                      final template = satuanTemplates[index];
                      return Card(
                        child: ListTile(
                          title: Text(template.name),
                          subtitle: Text(
                            'Rp ${template.price.toStringAsFixed(0)} /item',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () => _showTemplateDialog(
                                  existingTemplate: template,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    widget.onTemplateDeleted(template.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTemplateDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Buat Template'),
      ),
    );
  }
}
