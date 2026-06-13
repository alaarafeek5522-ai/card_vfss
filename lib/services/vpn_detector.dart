import 'dart:io';
import 'package:flutter/services.dart';

class VpnDetector {
  static const _channel = MethodChannel('com.card.vodafone.alaa/vpn');

  static Future<bool> isVpnActive() async {
    try {
      // طريقة 1 — MethodChannel (الأقوى)
      final bool result = await _channel.invokeMethod('isVpnConnected');
      if (result) return true;
    } catch (_) {}

    try {
      // طريقة 2 — فحص الـ network interfaces
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.any,
      );
      for (final iface in interfaces) {
        final name = iface.name.toLowerCase();
        if (name.contains('tun') ||
            name.contains('tap') ||
            name.contains('pptp') ||
            name.contains('l2tp') ||
            name.contains('ipsec') ||
            name.contains('vpn') ||
            name.contains('wg') ||
            name.contains('proton') ||
            name.contains('nord')) {
          return true;
        }
      }
    } catch (_) {}

    return false;
  }
}
