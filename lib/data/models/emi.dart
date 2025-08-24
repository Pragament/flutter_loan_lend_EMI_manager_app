class Emi {
  final String id;
  final String title;
  final String emiType; // "loan" or "lend"
  final double principalAmount;
  final double totalEmi;
  final DateTime startDate;
  final DateTime endDate;
  final double monthlyEmi;
  final double balance;
  final int tenure; // Duration in years
  // Color for the bar

  Emi({
    required this.id,
    required this.title,
    required this.emiType,
    required this.principalAmount,
    required this.totalEmi,
    required this.startDate,
    required this.endDate,
    required this.monthlyEmi,
    required this.balance,
    required this.tenure,
  });
}
