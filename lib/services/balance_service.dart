import 'dart:convert';
import 'package:http/http.dart' as http;

class BalanceService {
  static Future<String?> getBalance({
    required String number,
    required String pin,
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('https://mobile.vodafone.com.eg/services/dxl/pm/paymentMethod/$number').replace(
          queryParameters: {
            '@type': 'DigitalWallet',
            '@referredType': 'CashBalance',
          },
        ),
        headers: {
          'User-Agent': 'okhttp/4.12.0',
          'Connection': 'close',
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip',
          'pinCode': pin,
          'X-Request-ID': '2e3a365d-b3f3-4494-bb86-9318096d30fc',
          'X-App-StackTrace': '',
          'device-id': '48ad4d6d0e273340',
          'Content-Type': 'application/json',
          'api-version': 'v2',
          'msisdn': number,
          'Authorization': 'Bearer $token',
          'Accept-Language': 'ar',
          'x-agent-operatingsystem': '12',
          'x-agent-device': 'OPPO CPH2471',
          'x-agent-version': '2026.4.1',
          'x-agent-build': '1139',
          'digitalId': '25N8E4AMYUNL6',
          'clientId': 'AnaVodafoneAndroid',
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body);
      final chars = data['characteristics'] as List?;
      if (chars != null) {
        final balance = chars.firstWhere(
          (e) => e['name'] == 'balance',
          orElse: () => null,
        );
        if (balance != null) return balance['value'];
      }
      final desc = data['description'];
      if (desc != null) return desc;
    } catch (_) {}
    return null;
  }
}
