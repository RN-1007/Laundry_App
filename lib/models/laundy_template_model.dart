enum TemplateType { kiloan, satuan }

class LaundryTemplate {
  final String id;
  final String name;
  final TemplateType type;
  final double price;

  LaundryTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
  });
}
