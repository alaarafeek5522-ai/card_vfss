import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChargeHistory {
  final String cardName;
  final String cardPrice;
  final String receiver;
  final String date;
  final bool success;

  ChargeHistory({
    required this.cardName,
    required this.cardPrice,
    required this.receiver,
    required this.date,
    required this.success,
  });

  Map<String, dynamic> toJson() => {
    'cardName': cardName,
    'cardPrice': cardPrice,
    'receiver': receiver,
    'date': date,
    'success': success,
  };

  factory ChargeHistory.fromJson(Map<String, dynamic> j) => ChargeHistory(
    cardName: j['cardName'],
    cardPrice: j['cardPrice'],
    receiver: j['receiver'],
    date: j['date'],
    success: j['success'],
  );
}

class HistoryService {
  static const String _historyKey = 'charge_history';
  static const String _lastReceiverKey = 'last_receiver';
  static const int _maxHistory = 50;

  static Future<void> addRecord(ChargeHistory record) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getHistory();
    list.insert(0, record);
    if (list.length > _maxHistory) list.removeLast();
    await prefs.setString(
      _historyKey,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
    if (record.success) {
      await prefs.setString(_lastReceiverKey, record.receiver);
    }
  }

  static Future<List<ChargeHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => ChargeHistory.fromJson(e)).toList();
  }

  static Future<String?> getLastReceiver() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastReceiverKey);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await prefs.remove(_lastReceiverKey);
  }
}
