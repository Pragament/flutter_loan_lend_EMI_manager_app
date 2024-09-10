class Emi {
  final String id;
  final String title;
  final String emiType;
  final double principalAmount;
  final double totalEmi;
  final DateTime startDate;
  final DateTime endDate;
  final double monthlyEmi;

  Emi({
    required this.id,
    required this.title,
    required this.emiType,
    required this.principalAmount,
    required this.totalEmi,
    required this.startDate,
    required this.endDate,
    required this.monthlyEmi,
  });
}