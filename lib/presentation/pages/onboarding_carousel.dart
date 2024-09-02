import 'dart:math';
import 'package:emi_manager/presentation/widgets/pie.dart';
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

Center firstPage(BuildContext context, LocaleNotifier localeNotifier,
    PageController pageController) {
  const buttonWidth = 200.0; // Define a fixed width for all buttons

  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Select Language", // Localized text for "Select Language"
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: buttonWidth,
            child: ElevatedButton.icon(
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
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // Rounded corners
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: buttonWidth,
            child: ElevatedButton.icon(
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
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // Rounded corners
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: buttonWidth,
            child: ElevatedButton.icon(
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
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // Rounded corners
                ),
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
  bool isTenureInYears = false; // New state variable to track tenure toggle

  // Method to calculate EMI
  double calculateEMI(double principal, double annualRate, double months) {
    double r = annualRate / 12 / 100; // Monthly interest rate
    double emi =
        principal * r * pow((1 + r), months) / (pow((1 + r), months) - 1);
    return emi;
  }

  @override
  Widget build(BuildContext context) {
    // Convert tenure to months if it is in years for calculations
    double displayTenure = isTenureInYears ? tenure / 12 : tenure;
    double emi = calculateEMI(loanAmount, interestRate, tenure);
    double totalAmount = emi * tenure;
    double interestAmount = totalAmount - loanAmount;

    // Correcting the slider value if it goes out of bounds
    double minTenure = isTenureInYears ? 0.25 : 3;
    double maxTenure = isTenureInYears ? 30 : 360;

    if (displayTenure < minTenure) {
      displayTenure = minTenure;
    } else if (displayTenure > maxTenure) {
      displayTenure = maxTenure;
    }

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
                  width: 150,
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
                  width: 150,
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
                    '${AppLocalizations.of(context)!.tenure}: ',
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: displayTenure.toStringAsFixed(0),
                            border: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.zero,
                                    bottomRight: Radius.zero)), // Box style
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) {
                            double? inputValue = double.tryParse(value);
                            if (inputValue != null &&
                                inputValue >=
                                    (isTenureInYears
                                        ? 0.25
                                        : 3) && // Minimum 3 months or 0.25 years
                                inputValue <= (isTenureInYears ? 30 : 360)) {
                              // Maximum 360 months or 30 years
                              setState(() {
                                tenure = isTenureInYears
                                    ? inputValue * 12
                                    : inputValue; // Convert years to months if needed
                              });
                            }
                          },
                        ),
                      ),
                      // Two selectable boxes for years and months
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                isTenureInYears = false;
                                tenure =
                                    displayTenure; // Convert years to months if needed
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 8),
                              decoration: BoxDecoration(
                                color: isTenureInYears
                                    ? Colors.grey[200]
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(0),
                                border: Border.all(
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                'Mo',
                                style: TextStyle(
                                  color: isTenureInYears
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isTenureInYears = true;
                                tenure = displayTenure *
                                    12; // Convert months to years if needed
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 8),
                              decoration: BoxDecoration(
                                color: isTenureInYears
                                    ? Colors.orange
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(0),
                                border: Border.all(
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                'Yr',
                                style: TextStyle(
                                  color: isTenureInYears
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Slider(
              value: displayTenure,
              min: minTenure,
              max: maxTenure,
              divisions: isTenureInYears ? 30 : 348,
              label: displayTenure.toStringAsFixed(0),
              onChanged: (value) {
                setState(() {
                  tenure = isTenureInYears
                      ? value * 12
                      : value; // Convert slider value to months if needed
                });
              },
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.emi}:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${emi.toStringAsFixed(0)}',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.interestAmount}:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${interestAmount.toStringAsFixed(0)}',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.totalAmount}:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${totalAmount.toStringAsFixed(0)}',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),

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
