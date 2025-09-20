import 'customer_model.dart';

class MemberCustomer extends Customer {
  final String memberId;
  final String memberTier;

  MemberCustomer({
    required super.id,
    required super.name,
    required super.phoneNumber,
    required this.memberId,
    required this.memberTier,
  });

  @override
  double get discountPercentage {
    if (memberTier == "Gold") {
      return 0.20;
    }
    return 0.10;
  }

  @override
  String get customerType => "Member $memberTier";
}