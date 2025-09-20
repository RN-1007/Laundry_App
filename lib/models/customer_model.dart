abstract class Customer {
  final String id;
  final String name;
  final String phoneNumber;

  Customer({required this.id, required this.name, required this.phoneNumber});

  double get discountPercentage;
  String get customerType;
}

class RegularCustomer extends Customer {
  RegularCustomer({required super.id, required super.name, required super.phoneNumber});

  @override
  double get discountPercentage => 0.0;

  @override
  String get customerType => "Reguler";
}