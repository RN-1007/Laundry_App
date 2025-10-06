enum PromoType {
  percentage('Persentase (%)'),
  fixed('Potongan Tetap (Rp)');

  const PromoType(this.displayName);
  final String displayName;
}

class Promo {
  final String id;
  String name;
  PromoType type;
  double value; // Berisi persentase (misal: 15) atau nominal (misal: 5000)
  double minTransaction; // Minimal transaksi untuk promo berlaku
  bool isActive;

  Promo({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.minTransaction = 0,
    this.isActive = true,
  });
}
