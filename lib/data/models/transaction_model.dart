import 'package:hive_flutter/hive_flutter.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 2)
class Transaction {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String description;
  @HiveField(3)
  double amount;
  @HiveField(4)
  String type; // "DR" for Debit, "CR" for Credit
  @HiveField(5)
  DateTime datetime;
  @HiveField(6)
  String loanLendId;

  Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.datetime,
    required this.loanLendId,
  });

  Transaction copyWith({
    String? id,
    String? title,
    String? description,
    double? amount,
    String? type,
    DateTime? datetime,
    String? loanLendId,
  }) =>
      Transaction(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        datetime: datetime ?? this.datetime,
        loanLendId: loanLendId ?? this.loanLendId,
      );

  Transaction duplicate() {
    return Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // new unique ID
      title: this.title,
      description: this.description,
      amount: this.amount,
      type: this.type,
      datetime: DateTime.now(), // current date/time
      loanLendId: this.loanLendId,
    );
  }

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map["id"].toString(),
        title: map["title"],
        description: map["description"],
        amount: map["amount"].toDouble(),
        type: map["type"],
        datetime: DateTime.parse(map["datetime"]),
        loanLendId: map["loan_lend_id"].toString(),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "description": description,
        "amount": amount,
        "type": type,
        "datetime": datetime.toIso8601String(),
        "loan_lend_id": loanLendId,
      };
}
