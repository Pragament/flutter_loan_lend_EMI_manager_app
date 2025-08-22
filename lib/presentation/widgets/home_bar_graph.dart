import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/emi_model.dart';

class HomeBarGraph extends StatelessWidget {
  final List<Emi> allEmis;

  const HomeBarGraph({
    super.key,
    required this.allEmis,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    late int tenureMonths;
    // Maps to store amortized principal and interest for each year per EMI
    Map<int, Map<String, double>> yearlyData = {};
    List<Color> loanColors = [
      Colors.deepPurple.shade700,
      Colors.pink.shade700,
      Colors.green.shade700,
      Colors.orange.shade700,
      Colors.purple.shade700,
      Colors.teal.shade700,
      Colors.yellow.shade700,
      Colors.indigo.shade700,
    ];
    List<Color> interestColors = [
      Colors.deepPurple.shade300,
      Colors.pink.shade300,
      Colors.green.shade300,
      Colors.orange.shade300,
      Colors.purple.shade300,
      Colors.teal.shade300,
      Colors.yellow.shade300,
      Colors.indigo.shade300,
    ];

    // Generate yearly principal and interest breakdown for each EMI
    for (int i = 0; i < allEmis.length; i++) {
      var emi = allEmis[i];
      int startYear = emi.startDate.year;
      int endYear = emi.endDate?.year ?? startYear;
      double remainingPrincipal = emi.principalAmount;
      double monthlyInterestRate = emi.interestRate / 12 / 100;
      tenureMonths = (endYear - startYear + 1) * 12;

      // Monthly EMI calculation
      double monthlyEmi;
      if (monthlyInterestRate == 0 || tenureMonths == 0) {
        monthlyEmi = tenureMonths > 0
            ? remainingPrincipal / tenureMonths
            : remainingPrincipal;
      } else {
        monthlyEmi = (remainingPrincipal * monthlyInterestRate) /
            (1 - pow(1 + monthlyInterestRate, -tenureMonths));
      }

      // Amortization loop to split EMI payments into yearly principal and interest
      for (int month = 0; month < tenureMonths; month++) {
        int currentYear = startYear + (month ~/ 12);
        double monthlyInterest = monthlyInterestRate == 0
            ? 0
            : remainingPrincipal * monthlyInterestRate;
        double monthlyPrincipal = monthlyEmi - monthlyInterest;

        // Deduct principal paid from the remaining principal
        remainingPrincipal -= monthlyPrincipal;

        // Initialize the yearly data map for the year if not already initialized
        yearlyData.putIfAbsent(currentYear, () => {});

        // Accumulate principal and interest for each year
        yearlyData[currentYear]!['principal_${emi.id}'] =
            (yearlyData[currentYear]!['principal_${emi.id}'] ?? 0) +
                monthlyPrincipal;
        yearlyData[currentYear]!['interest_${emi.id}'] =
            (yearlyData[currentYear]!['interest_${emi.id}'] ?? 0) +
                monthlyInterest;
      }
    }

    // Prepare the data for the graph
    List<BarChartGroupData> barGroups = [];
    List<int> years = yearlyData.keys.toList()..sort();

    for (int year in years) {
      List<BarChartRodData> rods = [];
      final currentDate = DateTime.now();
      final monthsLeft = 12 - currentDate.month;

      for (int i = 0; i < allEmis.length; i++) {
        var emi = allEmis[i];
        Color principalColor = loanColors[i % loanColors.length];
        Color interestColor = interestColors[i % interestColors.length];
        // Total principal and interest for each loan per year
        double principal = yearlyData[year]?['principal_${emi.id}'] ?? 0.0;
        double interest = yearlyData[year]?['interest_${emi.id}'] ?? 0.0;

        // Calculate the remaining balance for the current year
        if (currentDate.year == year) {
          principal = (principal * monthsLeft) / 12.0;
          interest = (interest * monthsLeft) / 12.0;
        }

        rods.add(
          BarChartRodData(
            toY: principal + interest,
            width: 15,
            color: null, // Set color to null to apply gradient
            rodStackItems: [
              BarChartRodStackItem(0, principal, principalColor),
              BarChartRodStackItem(
                  principal, principal + interest, interestColor),
            ],
            borderRadius: BorderRadius.zero,
          ),
        );
      }

      barGroups.add(
        BarChartGroupData(
          x: year,
          barRods: rods,
        ),
      );
    }

    // Find the maximum Y value for proper scaling
    final maxY = barGroups
        .map((group) => group.barRods.map((rod) => rod.toY).reduce(max))
        .reduce(max);
    var total = tenureMonths * allEmis.length;
    // print("Total: $total");
    if (total < 500) {
      total = 2 * total;
    }
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: w * total * 0.01,
              height: 320,
              child: AspectRatio(
                aspectRatio: 0.5,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 2, right: 2),
                  child: BarChart(
                    BarChartData(
                      barGroups: barGroups,
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 11),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize:
                                45, // Adjust this value to increase left margin
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  '${(value / 1000).toStringAsFixed(0)}K',
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(enabled: true),
                      gridData: const FlGridData(show: true),
                      backgroundColor: Colors.white,
                      maxY: maxY * 1.1, // 10% margin
                      minY: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                allEmis.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          ClipPath(
                            clipper: DiagonalClipper(isTopLeft: true),
                            child: Container(
                              width: 12,
                              height: 12,
                              color:
                                  interestColors[index % interestColors.length],
                            ),
                          ),
                          ClipPath(
                            clipper: DiagonalClipper(isTopLeft: false),
                            child: Container(
                              width: 12,
                              height: 12,
                              color: loanColors[index % loanColors.length],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 5),
                      Text(
                        allEmis[index].title,
                        style: TextStyle(
                            color: allEmis[index].emiType == 'loan'
                                ? Colors.red
                                : Colors.blueAccent,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiagonalClipper extends CustomClipper<Path> {
  final bool isTopLeft;

  DiagonalClipper({this.isTopLeft = true});

  @override
  Path getClip(Size size) {
    Path path = Path();
    if (isTopLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
