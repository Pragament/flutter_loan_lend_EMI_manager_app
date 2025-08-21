import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:version/version.dart';

class EulaProvider {
  static const String _acceptedEulaKey = 'accepted_eula';
  static const String _lastCheckedKey = 'eula_last_checked';

  /// Fetch the latest active EULA from the API for the given language
  static Future<Map<String, dynamic>?> getActiveEula(
      [String? languageCode]) async {
    String url;
    switch (languageCode) {
      case 'hi':
        url = 'https://staticapis.pragament.com/eula/emi_app-hi.json';
        break;
      case 'te':
        url = 'https://staticapis.pragament.com/eula/emi_app-te.json';
        break;
      case 'en':
      default:
        url = 'https://staticapis.pragament.com/eula/emi_app.json';
        break;
    }
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final agreementsRaw = json['agreements'];
        List<dynamic> eulas;
        if (agreementsRaw is List) {
          eulas = agreementsRaw;
        } else if (agreementsRaw is Map) {
          eulas = [agreementsRaw];
        } else {
          return null;
        }

        final active = eulas.where((e) => e['is_active'] == true).toList();
        if (active.isEmpty) return null;
        active.sort((a, b) =>
            Version.parse(a['version']).compareTo(Version.parse(b['version'])));
        return active.last;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Check if EULA acceptance is needed
  static Future<bool> needsEulaAcceptance() async {
    final prefs = await SharedPreferences.getInstance();
    final acceptedEulaJson = prefs.getString(_acceptedEulaKey);
    String? lastAcceptedVersion;
    if (acceptedEulaJson != null) {
      try {
        final acceptedEula = jsonDecode(acceptedEulaJson);
        lastAcceptedVersion = acceptedEula['accepted_eula_version'];
      } catch (_) {}
    } else {
      return false;
    }
    final lastChecked = prefs.getInt(_lastCheckedKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const thirtyDaysMs = 30 * 24 * 60 * 60 * 1000;

    final shouldCheck =
        (now - lastChecked) > thirtyDaysMs || lastAcceptedVersion == null;

    if (shouldCheck) {
      final activeEula = await getActiveEula();
      if (activeEula == null) return false; // No active EULA, allow app
      final currentVersion = activeEula['version'];
      if (lastAcceptedVersion != currentVersion) {
        return true;
      }
      await prefs.setInt(_lastCheckedKey, now);
      return false;
    }
    return false;
  }

  /// Accept the EULA and save version and acceptance date as JSON
  static Future<void> acceptEula(String? version) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final acceptedEula = {
      'accepted_eula_version': version ?? '',
      'accepted_date':
          "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}"
    };
    await prefs.setString(_acceptedEulaKey, jsonEncode(acceptedEula));
    await prefs.setInt(_lastCheckedKey, now.millisecondsSinceEpoch);
  }
}
