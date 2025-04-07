import 'dart:math';
import 'package:emi_manager/data/models/tag_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'emi_model.g.dart';

@HiveType(typeId: 0)
class Emi {
  @HiveField(1)
  String id;
  @HiveField(2)
  String title;
  @HiveField(3)
  String emiType;
  @HiveField(4)
  double principalAmount;
  @HiveField(5)
  double interestRate;
  @HiveField(6)
  DateTime startDate;
  @HiveField(7)
  DateTime? endDate;
  @HiveField(8)
  String contactPersonName;
  @HiveField(9)
  String contactPersonEmail;
  @HiveField(10)
  String contactPersonPhone;
  @HiveField(11)
  String otherInfo;
  @HiveField(12)
  double? processingFee;
  @HiveField(13)
  double? otherCharges;
  @HiveField(14)
  double? partPayment;
  @HiveField(15)
  double? advancePayment;
  @HiveField(16)
  double? insuranceCharges;
  @HiveField(17)
  bool? moratorium;
  @HiveField(18)
  int? moratoriumMonth;
  @HiveField(19)
  String? moratoriumType;
  @HiveField(20)
  double? monthlyEmi;
  @HiveField(21)
  double? totalEmi;
  @HiveField(22)
  double? paid;
  @HiveField(23)
  List<Tag> tags;
  @HiveField(24)
  double? selectedYears;
  @HiveField(25)
  double? selectedMonths;

  Emi({
    required this.id,
    required this.title,
    required this.emiType,
    required this.principalAmount,
    required this.interestRate,
    required this.startDate,
    required this.endDate,
    required this.contactPersonName,
    required this.contactPersonPhone,
    required this.contactPersonEmail,
    required this.otherInfo,
    required this.processingFee,
    required this.otherCharges,
    required this.partPayment,
    required this.advancePayment,
    required this.insuranceCharges,
    required this.moratorium,
    required this.moratoriumMonth,
    required this.moratoriumType,
    required this.monthlyEmi,
    required this.totalEmi,
    required this.paid,
    required this.tags,
    this.selectedYears,
    this.selectedMonths,
  }) {
    _calculateEmi();
  }

  void _calculateEmi() {
    if (endDate != null) {
      final tenureInMonths = (endDate!.year - startDate.year) * 12 + (endDate!.month - startDate.month);
      final monthlyInterestRate = interestRate / 12 / 100;
      final powTerm = pow(1 + monthlyInterestRate, tenureInMonths);
      final numerator = principalAmount * monthlyInterestRate * powTerm;
      final denominator = powTerm - 1;
      monthlyEmi = numerator / denominator;
      totalEmi = monthlyEmi! * tenureInMonths;
    }
  }

  void updateTenure(DateTime newEndDate) {
    endDate = newEndDate;
    _calculateEmi();
  }

  int get year => startDate.year;

  Emi copyWith({
    String? id,
    String? title,
    String? emiType,
    double? principalAmount,
    double? interestRate,
    DateTime? startDate,
    DateTime? endDate,
    String? contactPersonName,
    String? contactPersonPhone,
    String? contactPersonEmail,
    String? otherInfo,
    double? processingFee,
    double? otherCharges,
    double? partPayment,
    double? advancePayment,
    double? insuranceCharges,
    bool? moratorium,
    int? moratoriumMonth,
    String? moratoriumType,
    double? monthlyEmi,
    double? totalEmi,
    double? paid,
    List<Tag>? tags,
    double? selectedYears,
    double? selectedMonths,
  }) =>
      Emi(
        id: id ?? this.id,
        title: title ?? this.title,
        emiType: emiType ?? this.emiType,
        principalAmount: principalAmount ?? this.principalAmount,
        interestRate: interestRate ?? this.interestRate,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        contactPersonName: contactPersonName ?? this.contactPersonName,
        contactPersonPhone: contactPersonPhone ?? this.contactPersonPhone,
        contactPersonEmail: contactPersonEmail ?? this.contactPersonEmail,
        otherInfo: otherInfo ?? this.otherInfo,
        processingFee: processingFee ?? this.processingFee,
        otherCharges: otherCharges ?? this.otherCharges,
        partPayment: partPayment ?? this.partPayment,
        advancePayment: advancePayment ?? this.advancePayment,
        insuranceCharges: insuranceCharges ?? this.insuranceCharges,
        moratorium: moratorium ?? this.moratorium,
        moratoriumMonth: moratoriumMonth ?? this.moratoriumMonth,
        moratoriumType: moratoriumType ?? this.moratoriumType,
        monthlyEmi: monthlyEmi ?? this.monthlyEmi,
        totalEmi: totalEmi ?? this.totalEmi,
        paid: paid ?? this.paid,
        tags: tags ?? this.tags,
        selectedYears: selectedYears ?? this.selectedYears,
        selectedMonths: selectedMonths ?? this.selectedMonths,
      );

  factory Emi.fromMap(Map<String, dynamic> map, String id) => Emi(
    id: map["id"],
    title: map["title"],
    emiType: map["emiType"],
    principalAmount: map["principalAmount"]?.toDouble(),
    interestRate: map["interestRate"]?.toDouble(),
    startDate: DateTime.parse(map["startDate"]),
    endDate: DateTime.parse(map["endDate"]),
    contactPersonName: map["contactPersonName"],
    contactPersonPhone: map["contactPersonPhone"],
    contactPersonEmail: map["contactPersonEmail"],
    otherInfo: map["otherInfo"],
    processingFee: map["processingFee"]?.toDouble(),
    otherCharges: map["otherCharges"]?.toDouble(),
    partPayment: map["partPayment"]?.toDouble(),
    advancePayment: map["advancePayment"]?.toDouble(),
    insuranceCharges: map["insuranceCharges"]?.toDouble(),
    moratorium: map["moratorium"],
    moratoriumMonth: map["moratoriumMonth"],
    moratoriumType: map["moratoriumType"],
    monthlyEmi: map["monthlyEmi"]?.toDouble(),
    totalEmi: map["totalEmi"]?.toDouble(),
    paid: map["paid"]?.toDouble(),
    tags: map["tags"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "emiType": emiType,
    "principalAmount": principalAmount,
    "interestRate": interestRate,
    "startDate": startDate.toIso8601String(),
    "endDate": endDate?.toIso8601String(),
    "contactPersonName": contactPersonName,
    "contactPersonPhone": contactPersonPhone,
    "contactPersonEmail": contactPersonEmail,
    "otherInfo": otherInfo,
    "processingFee": processingFee,
    "otherCharges": otherCharges,
    "partPayment": partPayment,
    "advancePayment": advancePayment,
    "insuranceCharges": insuranceCharges,
    "moratorium": moratorium,
    "moratoriumMonth": moratoriumMonth,
    "moratoriumType": moratoriumType,
    "monthlyEmi": monthlyEmi,
    "totalEmi": totalEmi,
    "paid": paid,
    "tags": tags,
    "selectedYears": selectedYears,
    "selectedMonths": selectedMonths,
  };
}
