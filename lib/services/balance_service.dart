import 'dart:convert';
import 'package:http/http.dart' as http;

class BalanceService {
  static String? _decodeJwtMsisdn(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      String payload = parts[1];
      final pad = 4 - (payload.length % 4);
      if (pad != 4) payload += '=' * pad;
      final decoded = jsonDecode(utf8.decode(base64Decode(payload)));
      return decoded['userInfo']?['msisdn'] ??
             decoded['preferred_username'] ??
             decoded['sub'];
    } catch (_) {
      return null;
    }
  }

  static Future<BalanceResult> getBalance({required String pin}) async {
    try {
      // 1. Seamless
      final seamlessRes = await http.get(
        Uri.parse('http://mobile.vodafone.com.eg/checkSeamless/realms/vf-realm/protocol/openid-connect/auth?client_id=ana-vodafone-app-seamless'),
        headers: {
          'User-Agent': 'okhttp/4.11.0',
          'Connection': 'Keep-Alive',
          'Accept-Encoding': 'gzip',
          'x-dynatrace': 'MT_3_5_2386790616_1-0_a556db1b-4506-43f3-854a-1d2527767923_0_21317_157',
          'x-agent-operatingsystem': '13',
          'clientId': 'AnaVodafoneAndroid',
          'Accept-Language': 'ar',
          'x-agent-device': 'OPPO CPH2235',
          'x-agent-version': '2024.7.2.1',
          'x-agent-build': '1050',
          'digitalId': '24S0M31T0I9RK',
        },
      ).timeout(const Duration(seconds: 8));

      final seamlessData = jsonDecode(seamlessRes.body);
      final seamlessToken = seamlessData['seamlessToken'];
      if (seamlessToken == null) return BalanceResult(success: false, message: 'تأكد من داتا فودافون');

      // 2. Access Token
      final tokenRes = await http.post(
        Uri.parse('https://mobile.vodafone.com.eg/auth/realms/vf-realm/protocol/openid-connect/token'),
        headers: {
          'User-Agent': 'okhttp/4.11.0',
          'Accept': 'application/json, text/plain, */*',
          'Accept-Encoding': 'gzip',
          'silentLogin': 'true',
          'seamlessToken': seamlessToken,
          'firstTimeLogin': 'true',
          'x-dynatrace': 'MT_3_5_2386790616_1-0_a556db1b-4506-43f3-854a-1d2527767923_0_21520_165',
          'x-agent-operatingsystem': '13',
          'clientId': 'AnaVodafoneAndroid',
          'Accept-Language': 'ar',
          'x-agent-device': 'OPPO CPH2235',
          'x-agent-version': '2024.7.2.1',
          'x-agent-build': '1050',
          'digitalId': '24S0M31T0I9RK',
        },
        body: {
          'grant_type': 'password',
          'client_secret': 'b86e30a8-ae29-467a-a71f-65c73f2ff5e3',
          'client_id': 'cash-app',
        },
      ).timeout(const Duration(seconds: 8));

      final accessToken = jsonDecode(tokenRes.body)['access_token'];
      if (accessToken == null) return BalanceResult(success: false, message: 'فشل الحصول على التوكن');

      // 3. جيب الرقم من الـ JWT
      final number = _decodeJwtMsisdn(accessToken);
      if (number == null) return BalanceResult(success: false, message: 'تعذر تحديد رقم الهاتف');

      // 4. الرصيد
      final balanceRes = await http.get(
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
          'Authorization': 'Bearer $accessToken',
          'Accept-Language': 'ar',
          'x-agent-operatingsystem': '12',
          'x-agent-device': 'OPPO CPH2471',
          'x-agent-version': '2026.4.1',
          'x-agent-build': '1139',
          'digitalId': '25N8E4AMYUNL6',
          'clientId': 'AnaVodafoneAndroid',
        },
      ).timeout(const Duration(seconds: 8));

      final data = jsonDecode(balanceRes.body);
      final chars = data['characteristics'] as List?;
      if (chars != null && chars.isNotEmpty) {
        final balance = chars.firstWhere(
          (e) => e['name'] == 'balance',
          orElse: () => chars[0],
        );
        return BalanceResult(success: true, balance: balance['value'], number: number);
      }
      return BalanceResult(success: false, message: 'تعذر الحصول على الرصيد');
    } catch (e) {
      return BalanceResult(success: false, message: 'خطأ في الاتصال');
    }
  }
}

class BalanceResult {
  final bool success;
  final String? balance;
  final String? number;
  final String? message;
  BalanceResult({required this.success, this.balance, this.number, this.message});
}
