# Flutter Loan Lend EMI Manager App
by nik testing3
## Project Description

The Flutter Loan Lend EMI Manager App is designed to help users efficiently manage their loans, lending activities, and EMI schedules. It provides a user-friendly interface to track transactions, set reminders, and visualize financial data. The app exists to simplify financial management and ensure users never miss an EMI payment or lending record.

### Goal

The app aims to solve the problem of disorganized financial tracking by offering a centralized platform for managing loans, EMIs, and lending activities.

---

## Features

- **Loan and EMI Management**: Track loans and EMIs with detailed records.
- **Lending Records**: Manage lending activities and keep track of borrowers.
- **Localization**: Supports multiple languages (English, Hindi, Telugu).
- **Dark Mode**: Seamless light and dark theme support.
- **Interactive Onboarding**: Showcase features for first-time users.
- **Lottie Animations**: Engaging animations for better user experience.
- **Hive Database**: Efficient local storage for offline access.

---

## Getting Started

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-repo/flutter_loan_lend_EMI_manager_app.git
   cd flutter_loan_lend_EMI_manager_app
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

4. **Build for Production**:
   ```bash
   flutter build apk
   ```

---

## Roadmap

- [ ] Add support for more languages.
- [ ] Integrate cloud sync for data backup.
- [ ] Add advanced analytics and reporting features.
- [ ] Implement push notifications for EMI reminders.
- [ ] Enhance UI/UX with more animations and themes.

---

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request. Here's how you can contribute:

1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add your feature description"
   ```
4. Push to the branch:
   ```bash
   git push origin feature/your-feature-name
   ```
5. Open a pull request.

---

## Current App screenshots

<div style="display: flex; flex-wrap: wrap; gap: 10px;">
  <img src="https://github.com/user-attachments/assets/3d01ab75-a65b-436d-8239-4f05da7b9df3" alt="Screenshot 1" width="200">
  <img src="https://github.com/user-attachments/assets/bb3e5da7-88ec-4f14-b5e9-afba5aa15330" alt="Screenshot 2" width="200">
  <img src="https://github.com/user-attachments/assets/9f7d7541-aa3b-4ac4-9ccb-b4671a571492" alt="Screenshot 3" width="200">
  <img src="https://github.com/user-attachments/assets/aa824bcc-516f-4c7c-a42b-6266098602a4" alt="Screenshot 4" width="200">
</div>

---

## Code Flow

This section explains the structure and flow of the Flutter app to help new contributors understand the codebase.

### 1. **Entry Point**
- The app starts from the `main()` function in `lib/main.dart`.
- Hive is initialized for local storage, and adapters for models like `Emi`, `Tag`, and `Transaction` are registered.
- The `MainApp` widget is launched with a `ProviderScope` to enable state management using Riverpod.

### 2. **Splash Screen**
- The `SplashScreen` widget is displayed first.
- It shows a Lottie animation (`assets/animations/coin_stack.json`) and navigates to the main app content after a 3-second delay.

### 3. **Main App Content**
- The `MainAppContent` widget is the core of the app.
- It uses `MaterialApp.router` for navigation and integrates Riverpod for state management.
- Localization is handled using `AppLocalizations` with support for English, Hindi, and Telugu.

### 4. **Routing**
- The app's navigation is managed by the `routerProvider` in `lib/presentation/router/router.dart`.
- Define routes and their corresponding screens in the router configuration.

### 5. **State Management**
- Riverpod is used for state management.
- Example: `localeNotifierProvider` is used to manage the app's locale.

### 6. **Data Models**
- Data models like `Emi`, `Tag`, and `Transaction` are defined in `lib/data/models/`.
- These models are registered with Hive for local storage.

### 7. **Localization**
- Localization files are stored in `lib/presentation/l10n/`.
- Add new translations to support additional languages.

### 8. **Themes**
- Light and dark themes are defined using `ThemeData` and `_colorScheme` in `lib/main.dart`.

### 9. **Showcase View**
- The `ShowCaseWidget` is used to provide an interactive onboarding experience for first-time users.

### 10. **Animations**
- Lottie animations are used to enhance the user experience.
- Animation files are stored in the `assets/animations/` directory.

---

### Suggested Workflow for New Contributors

1. **Understand the App Flow**:
   - Start by reviewing `lib/main.dart` to understand the app's entry point and initialization.

2. **Explore Features**:
   - Check the widgets and screens in `lib/presentation/` to understand the UI components.

3. **Review State Management**:
   - Look into Riverpod providers in `lib/logic/` to see how state is managed.

4. **Work on Localization**:
   - Add or update translations in `lib/presentation/l10n/`.

5. **Test Your Changes**:
   - Use `flutter run` to test changes locally.

---

## Git Pre-commit Hook

To enforce code quality locally before each commit, set up the following pre-commit hook:

1. Create a file at `.git/hooks/pre-commit` with the following content:
    ```sh
    #!/bin/sh
    flutter analyze --no-fatal-infos --no-fatal-warnings
    if [ $? -ne 0 ]; then
      echo "Flutter analyze failed. Commit aborted."
      exit 1
    fi

    echo "Running flutter test..."
    flutter test
    if [ $? -ne 0 ]; then
      echo "Flutter tests failed. Commit aborted."
      #exit 1
    fi

    echo "All checks passed."
    exit 0
    ```
2. Make it executable:
    ```sh
    chmod +x .git/hooks/pre-commit
    ```

This will prevent commits if formatting, analysis, or tests fail.
