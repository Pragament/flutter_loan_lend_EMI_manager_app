import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emi_manager/logic/locale_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive package
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import for localization

void completeOnboarding(BuildContext context) {
  var prefsBox = Hive.box('preferences');
  prefsBox.put('isFirstRun', false);
  context.go('/'); // Navigate to the home screen after onboarding
}

class OnboardingCarousel extends ConsumerWidget {
  const OnboardingCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PageController pageController = PageController();
    final localeNotifier = ref.read(localeNotifierProvider.notifier);

    return Scaffold(
      body: PageView(
        controller: pageController,
        children: [
          firstPage(context, localeNotifier, pageController),
          const SecondPage(),
        ],
      ),
    );
  }
}


Center firstPage(BuildContext context, LocaleNotifier localeNotifier, PageController pageController) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Select Language", // Localized text for "Select Language"
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              localeNotifier.changeLanguage(const Locale('en'));
              pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: const Icon(Icons.language, color: Colors.white),
            label: const Text('English'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, // Background color
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0), // Rounded corners
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              localeNotifier.changeLanguage(const Locale('hi'));
              pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: const Icon(Icons.language, color: Colors.white),
            label: const Text('हिन्दी'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent, // Background color
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0), // Rounded corners
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              localeNotifier.changeLanguage(const Locale('te'));
              pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: const Icon(Icons.language, color: Colors.white),
            label: const Text('తెలుగు'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent, // Background color
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0), // Rounded corners
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  double loanAmount = 1000000; // Default loan amount
  double interestRate = 7.2; // Default annual interest rate
  double tenure = 120; // Default tenure in months

  // Method to calculate EMI
  double calculateEMI(double principal, double annualRate, double months) {
    double r = annualRate / 12 / 100; // Monthly interest rate
    double emi =
        principal * r * pow((1 + r), months) / (pow((1 + r), months) - 1);
    return emi;
  }

  @override
  Widget build(BuildContext context) {
    double emi = calculateEMI(loanAmount, interestRate, tenure);
    double totalAmount = emi * tenure;
    double interestAmount = totalAmount - loanAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.caroselHeading),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${AppLocalizations.of(context)!.loanAmount}: ₹${loanAmount.toStringAsFixed(0)}',
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 40,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText:
                          loanAmount.toStringAsFixed(0), // Dynamic hint text
                      border: const OutlineInputBorder(), // Box style
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      double? inputValue = double.tryParse(value);
                      if (inputValue != null &&
                          inputValue >= 100000 &&
                          inputValue <= 10000000) {
                        setState(() {
                          loanAmount = inputValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            Slider(
              value: loanAmount,
              min: 100000,
              max: 10000000,
              divisions: 90,
              label: loanAmount.toStringAsFixed(0),
              onChanged: (value) {
                setState(() {
                  loanAmount = value;
                });
              },
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${AppLocalizations.of(context)!.interestRate}: ${interestRate.toStringAsFixed(1)}%',
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 40,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText:
                          interestRate.toStringAsFixed(1), // Dynamic hint text
                      border: const OutlineInputBorder(), // Box style
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,1}'))
                    ],
                    onChanged: (value) {
                      double? inputValue = double.tryParse(value);
                      if (inputValue != null &&
                          inputValue >= 1 &&
                          inputValue <= 20) {
                        setState(() {
                          interestRate = inputValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            Slider(
              value: interestRate,
              min: 1,
              max: 20,
              divisions: 19,
              label: '${interestRate.toStringAsFixed(1)}%',
              onChanged: (value) {
                setState(() {
                  interestRate = value;
                });
              },
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${AppLocalizations.of(context)!.tenure}: ${tenure.toStringAsFixed(0)} ${AppLocalizations.of(context)!.months}',
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 40,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: tenure.toStringAsFixed(0), // Dynamic hint text
                      border: const OutlineInputBorder(), // Box style
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      double? inputValue = double.tryParse(value);
                      if (inputValue != null &&
                          inputValue >= 3 &&
                          inputValue <= 360) {
                        setState(() {
                          tenure = inputValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            Slider(
              value: tenure,
              min: 3,
              max: 360,
              divisions: 348,
              label: tenure.toStringAsFixed(0),
              onChanged: (value) {
                setState(() {
                  tenure = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
                '${AppLocalizations.of(context)!.emi}: ₹${emi.toStringAsFixed(0)}'),
            Text(
                '${AppLocalizations.of(context)!.interestAmount}: ₹${interestAmount.toStringAsFixed(0)}'),
            Text(
                '${AppLocalizations.of(context)!.totalAmount}: ₹${totalAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 20),
            // Wrapped PieChart in a Container with a fixed height
            SizedBox(
              height: 200, // Specify a fixed height for the pie chart
              child: EmiPie(
                  loanAmount: loanAmount, interestAmount: interestAmount),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                completeOnboarding(context);
              },
              child: Text(AppLocalizations.of(context)!.completeOnboarding),
            ),
          ],
        ),
      ),
    );
  }
}

class EmiPie extends StatelessWidget {
  const EmiPie({
    super.key,
    required this.loanAmount,
    required this.interestAmount,
  });

  final double loanAmount;
  final double interestAmount;

  @override
  Widget build(BuildContext context) {
    double total = loanAmount + interestAmount;
    double loanPercentage = (loanAmount / total) * 100;
    double interestPercentage = (interestAmount / total) * 100;

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.green,
            value: loanAmount,
            title:
                '${loanPercentage.toStringAsFixed(1)}%', // Display as percentage
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.orange,
            value: interestAmount,
            title:
                '${interestPercentage.toStringAsFixed(1)}%', // Display as percentage
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
        sectionsSpace: 4,
        centerSpaceRadius: 0,
      ),
    );
  }
}
