import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

class LicenseService {
  static const String _gistId = '627420ffd8eae5b8b13ccfdd35371a24';
  static String get _token {
    final parts = [
      'g','h','o','_','B','K','t','Z','Z','E',
      'A','o','j','2','n','r','a','J','A','Q',
      'H','C','a','0','X','9','H','W','L','C',
      'V','2','R','y','2','3','I','A','Y','R'
    ];
    return parts.join();
  }
  static const String _fileName = 'keys.json';

  static const List<String> _validKeys = [
    'ALAA-A1B2-C3D4', 'ALAA-E5F6-G7H8', 'ALAA-I9J0-K1L2',
    'ALAA-M3N4-O5P6', 'ALAA-Q7R8-S9T0', 'ALAA-U1V2-W3X4',
    'ALAA-Y5Z6-A7B8', 'ALAA-C9D0-E1F2', 'ALAA-G3H4-I5J6',
    'ALAA-K7L8-M9N0', 'MERO-A1B2-C3D4', 'MERO-E5F6-G7H8',
    'MERO-I9J0-K1L2', 'MERO-M3N4-O5P6', 'MERO-Q7R8-S9T0',
    'MERO-U1V2-W3X4', 'MERO-Y5Z6-A7B8', 'MERO-C9D0-E1F2',
    'MERO-G3H4-I5J6', 'MERO-K7L8-M9N0', 'VF00-A1B2-C3D4',
    'VF00-E5F6-G7H8', 'VF00-I9J0-K1L2', 'VF00-M3N4-O5P6',
    'VF00-Q7R8-S9T0', 'VF00-U1V2-W3X4', 'VF00-Y5Z6-A7B8',
    'VF00-C9D0-E1F2', 'VF00-G3H4-I5J6', 'VF00-K7L8-M9N0',
    'CARD-A1B2-C3D4', 'CARD-E5F6-G7H8', 'CARD-I9J0-K1L2',
    'CARD-M3N4-O5P6', 'CARD-Q7R8-S9T0', 'CARD-U1V2-W3X4',
    'CARD-Y5Z6-A7B8', 'CARD-C9D0-E1F2', 'CARD-G3H4-I5J6',
    'CARD-K7L8-M9N0', 'PY00-A1B2-C3D4', 'PY00-E5F6-G7H8',
    'PY00-I9J0-K1L2', 'PY00-M3N4-O5P6', 'PY00-Q7R8-S9T0',
    'PY00-U1V2-W3X4', 'PY00-Y5Z6-A7B8', 'PY00-C9D0-E1F2',
    'PY00-G3H4-I5J6', 'PY00-K7L8-M9N0', 'CODE-A1B2-C3D4',
    'CODE-E5F6-G7H8', 'CODE-I9J0-K1L2', 'CODE-M3N4-O5P6',
    'CODE-Q7R8-S9T0', 'CODE-U1V2-W3X4', 'CODE-Y5Z6-A7B8',
    'CODE-C9D0-E1F2', 'CODE-G3H4-I5J6', 'CODE-K7L8-M9N0',
  ];

  static Future<String> getDeviceId() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        return android.id;
      }
    } catch (_) {}
    return 'unknown-device';
  }

  static Future<Map<String, dynamic>> _fetchGist() async {
    final res = await http.get(
      Uri.parse('https://api.github.com/gists/$_gistId'),
      headers: {
        'Authorization': 'token ${_token}',
        'Accept': 'application/vnd.github.v3+json',
      },
    ).timeout(const Duration(seconds: 6));
    final data = jsonDecode(res.body);
    final content = data['files'][_fileName]['content'];
    return jsonDecode(content);
  }

  static Future<void> _updateGist(Map<String, dynamic> data) async {
    await http.patch(
      Uri.parse('https://api.github.com/gists/$_gistId'),
      headers: {
        'Authorization': 'token ${_token}',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'files': {
          _fileName: {'content': jsonEncode(data)}
        }
      }),
    ).timeout(const Duration(seconds: 6));
  }

  static Future<LicenseResult> validateKey(String inputKey) async {
    try {
      final key = inputKey.trim().toUpperCase();
      if (!_validKeys.contains(key)) {
        return LicenseResult(success: false, message: 'المفتاح غير صحيح ❌', isConnectionError: false);
      }
      final deviceId = await getDeviceId();
      final gistData = await _fetchGist();
      final keys = gistData['keys'] as Map<String, dynamic>? ?? {};
      final now = DateTime.now().toIso8601String();

      if (keys.containsKey(key)) {
        final saved = keys[key];
        if (saved['active'] == false) {
          return LicenseResult(success: false, message: 'هذا المفتاح موقوف ⛔', isConnectionError: false);
        }
        final savedDevice = saved['device_id'];
        if (savedDevice == null || savedDevice == deviceId) {
          keys[key] = {'device_id': deviceId, 'active': true, 'registered_at': saved['registered_at'] ?? now};
          gistData['keys'] = keys;
          await _updateGist(gistData);
          return LicenseResult(success: true, message: 'مرحباً بك ✅', isConnectionError: false);
        }
        return LicenseResult(success: false, message: 'هذا المفتاح مستخدم على جهاز آخر ⛔\nكل مفتاح لجهاز واحد فقط', isConnectionError: false);
      } else {
        keys[key] = {'device_id': deviceId, 'active': true, 'registered_at': now};
        gistData['keys'] = keys;
        await _updateGist(gistData);
        return LicenseResult(success: true, message: 'تم التفعيل بنجاح ✅', isConnectionError: false);
      }
    } catch (e) {
      return LicenseResult(success: false, message: 'خطأ في الاتصال، حاول مرة أخرى', isConnectionError: true);
    }
  }

  static Future<LicenseResult> validateSavedKey() async {
    try {
      final deviceId = await getDeviceId();
      final gistData = await _fetchGist();
      final keys = gistData['keys'] as Map<String, dynamic>? ?? {};
      for (final entry in keys.entries) {
        if (entry.value['device_id'] == deviceId) {
          if (entry.value['active'] == false) {
            return LicenseResult(success: false, message: 'تم إيقاف تفعيلك ⛔', isConnectionError: false);
          }
          return LicenseResult(success: true, message: 'مرحباً بك ✅', isConnectionError: false);
        }
      }
      return LicenseResult(success: false, message: 'غير مفعّل', isConnectionError: false);
    } catch (_) {
      return LicenseResult(success: false, message: 'خطأ في الاتصال', isConnectionError: true);
    }
  }
}

class LicenseResult {
  final bool success;
  final String message;
  final bool isConnectionError;
  LicenseResult({required this.success, required this.message, required this.isConnectionError});
}
