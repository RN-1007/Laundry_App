import 'order_model.dart';

class KiloanOrder extends Order {
  final double weightInKg;
  final double pricePerKg;

  KiloanOrder({
    required super.id,
    required super.customer,
    required super.entryDate,
    required super.status,
    required this.weightInKg,
    required this.pricePerKg,
  });

  @override
  String get totalDisplay {
    return "Rp ${finalTotalValue.toStringAsFixed(0)}";
  }

  @override
  double get finalTotalValue {
    final baseTotal = weightInKg * pricePerKg;
    return calculateFinalTotal(baseTotal);
  }

  @override
  String get itemsDescription {
    return "$weightInKg kg Pakaian Harian";
  }
}