import 'customer_model.dart';

class CorporatePartner extends Customer {
  final String companyName;

  CorporatePartner({
    required super.id,
    required super.name,
    required super.phoneNumber,
    required this.companyName,
  });

  @override
  double get discountPercentage => 0.25;

  @override
  String get customerType => "Partner Korporat";
}