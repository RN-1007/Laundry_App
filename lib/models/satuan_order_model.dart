import 'order_model.dart';

class LaundryItem {
  final String name;
  final int quantity;
  final double price;

  LaundryItem({required this.name, required this.quantity, required this.price});
}

class SatuanOrder extends Order {
  final List<LaundryItem> items;

  SatuanOrder({
    required super.id,
    required super.customer,
    required super.entryDate,
    required super.status,
    required this.items,
  });

  @override
  String get totalDisplay {
    return "Rp ${finalTotalValue.toStringAsFixed(0)}";
  }

  @override
  double get finalTotalValue {
    final baseTotal = items.fold(0.0, (sum, item) => sum + (item.quantity * item.price));
    return calculateFinalTotal(baseTotal);
  }

  @override
  String get itemsDescription {
    return items.map((item) => "${item.quantity} ${item.name}").join(', ');
  }
}