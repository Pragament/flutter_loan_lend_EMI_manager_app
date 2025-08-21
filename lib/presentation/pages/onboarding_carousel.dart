import 'package:emi_manager/logic/eula_provider.dart';
import 'package:emi_manager/logic/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod for state management
import 'package:emi_manager/presentation/l10n/app_localizations.dart'; // Import localization
import 'package:emi_manager/presentation/pages/eula_page.dart';

void completeOnboarding(BuildContext context) {
  var prefsBox = Hive.box('preferences');
  prefsBox.put('isFirstRun', false);
  context.go('/'); // Navigate to the home screen after onboarding
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int currentIndex = 0;
  final PageController _pageController = PageController();
  Locale? selectedLocale = const Locale('en'); // Track the selected locale

  @override
  Widget build(BuildContext context) {
    final localeNotifier =
        ref.read(localeNotifierProvider.notifier); // Get the locale notifier
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index; // Update current index on swipe
              });
            },
            children: [
              _buildFirstPage(localeNotifier),
              _buildSecondPage(),
              _buildThirdPage(),
              _buildFourthPage(),
            ],
          ),
          // Dot indicators
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => _buildDot(index)),
            ),
          ),
          // "Skip" button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
                completeOnboarding(
                    context); // Complete onboarding and go to home
              },
              child: Text(
                AppLocalizations.of(context)!.skip,
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstPage(LocaleNotifier localeNotifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Select Language",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 40),
            _buildLanguageRadio(localeNotifier, const Locale('en'), 'English',
                Colors.blueAccent),
            const SizedBox(height: 20),
            _buildLanguageRadio(localeNotifier, const Locale('hi'),
                'हिन्दी    ', Colors.orangeAccent),
            const SizedBox(height: 20),
            _buildLanguageRadio(localeNotifier, const Locale('te'), 'తెలుగు',
                Colors.greenAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageRadio(LocaleNotifier localeNotifier, Locale locale,
      String label, Color backgroundColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLocale = locale; // Update the selected locale
        });
        localeNotifier.changeLanguage(locale);
      },
      child: Container(
        decoration: BoxDecoration(
          color: selectedLocale == locale
              ? backgroundColor.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(
            color: selectedLocale == locale ? backgroundColor : Colors.grey,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<Locale>(
              value: locale,
              groupValue: selectedLocale,
              onChanged: (Locale? value) {
                setState(() {
                  selectedLocale = value; // Update the selected locale
                });
                localeNotifier.changeLanguage(locale);
              },
            ),
            Text(label, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondPage() {
    String imageAsset;
    String welcomeText;

    // Determine the image and text based on the selected locale
    if (selectedLocale == const Locale('en')) {
      imageAsset = 'assets/english.png';
      welcomeText = AppLocalizations.of(context)!.welcome;
    } else if (selectedLocale == const Locale('hi')) {
      imageAsset = 'assets/hindi.png';
      welcomeText = AppLocalizations.of(context)!.welcome;
    } else if (selectedLocale == const Locale('te')) {
      imageAsset = 'assets/telugu.png';
      welcomeText = AppLocalizations.of(context)!.welcome;
    } else {
      imageAsset = 'assets/english.png'; // Default image
      welcomeText = AppLocalizations.of(context)!.welcome; // Default text
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200, // Adjust the width as needed
            child: Image.asset(imageAsset),
          ),
          const SizedBox(height: 20),
          Text(
            welcomeText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildThirdPage() {
    String imageAsset;
    String welcomeText;

    // Determine the image and text based on the selected locale
    if (selectedLocale == const Locale('en')) {
      imageAsset = 'assets/english1.png';
      welcomeText = AppLocalizations.of(context)!.welcome;
    } else if (selectedLocale == const Locale('hi')) {
      imageAsset = 'assets/hindi1.png';
      welcomeText = AppLocalizations.of(context)!.welcome;
    } else if (selectedLocale == const Locale('te')) {
      imageAsset = 'assets/telugu1.png';
      welcomeText = AppLocalizations.of(context)!.welcome;
    } else {
      imageAsset = 'assets/english1.png'; // Default image
      welcomeText = AppLocalizations.of(context)!.welcome; // Default text
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200, // Adjust the width as needed
            child: Image.asset(imageAsset),
          ),
          const SizedBox(height: 20),
          Text(
            welcomeText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFourthPage() {
    final langCode = (selectedLocale ?? const Locale('en')).languageCode;
    return EulaPage(
      languageCode: langCode,
      onAccepted: () async {
        final activeEula = await EulaProvider.getActiveEula(langCode);
        await EulaProvider.acceptEula(activeEula?['version']);
        completeOnboarding(context);
      },
      onDeclined: () {
        final localizations = AppLocalizations.of(context)!;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(
                  localizations.eulaDeclined,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  localizations.eulaAlertDialog,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(localizations.close),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build a dot indicator to show the current page
  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 12,
      width: currentIndex == index ? 24 : 12,
      decoration: BoxDecoration(
        color: currentIndex == index ? Colors.blueAccent : Colors.grey,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
