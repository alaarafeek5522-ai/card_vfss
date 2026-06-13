import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ChargeHistory> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final h = await HistoryService.getHistory();
    setState(() { _history = h; _loading = false; });
  }

  Future<void> _clear() async {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('مسح السجل', style: GoogleFonts.cairo(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('هيتمسح كل سجل الشحنات', style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 14), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkCard,
                      side: const BorderSide(color: AppTheme.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () => Navigator.pop(context),
                    child: Text('إلغاء', style: GoogleFonts.cairo(color: AppTheme.grey)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () async {
                      await HistoryService.clearHistory();
                      Navigator.pop(context);
                      _load();
                    },
                    child: Text('مسح', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('سجل العمليات', style: GoogleFonts.cairo(color: AppTheme.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              onPressed: _clear,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.redVF))
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, color: AppTheme.grey.withOpacity(0.4), size: 80),
                      const SizedBox(height: 16),
                      Text('لا يوجد سجل بعد', style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  itemCount: _history.length,
                  itemBuilder: (ctx, i) => _HistoryTile(record: _history[i])
                      .animate()
                      .fadeIn(delay: (i * 30).ms, duration: 300.ms)
                      .slideX(begin: 0.1),
                ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final ChargeHistory record;
  const _HistoryTile({required this.record});

  void _copyNumber(BuildContext context) {
    Clipboard.setData(ClipboardData(text: record.receiver));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('تم نسخ الرقم: ${record.receiver}', style: GoogleFonts.cairo()),
      backgroundColor: AppTheme.darkRed,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _share() {
    final text = '📱 تفاصيل الشحن\n'
        '━━━━━━━━━━━━━━━\n'
        '🎴 الكارت: ${record.cardName}\n'
        '💰 السعر: ${record.cardPrice} جنيه\n'
        '📞 الرقم: ${record.receiver}\n'
        '🕐 الوقت: ${record.date}\n'
        '${record.success ? "✅ تم الشحن بنجاح" : "❌ فشل الشحن"}\n'
        '━━━━━━━━━━━━━━━\n'
        '𝐂𝐚𝐫𝐝 𝐕𝐨𝐝𝐚𝐟𝐨𝐧𝐞 | Team Mero';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _copyNumber(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: record.success ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: record.success ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
              ),
              child: Icon(
                record.success ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: record.success ? Colors.greenAccent : Colors.redAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(record.cardName,
                        style: GoogleFonts.cairo(color: AppTheme.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      Text('${record.cardPrice} ج',
                        style: GoogleFonts.cairo(color: AppTheme.gold, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.phone_rounded, color: AppTheme.grey, size: 13),
                        const SizedBox(width: 4),
                        Text(record.receiver, style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 12)),
                      ]),
                      Text(record.date, style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // زرار المشاركة
                  GestureDetector(
                    onTap: _share,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.share_rounded, color: AppTheme.redVF.withOpacity(0.7), size: 14),
                        const SizedBox(width: 4),
                        Text('مشاركة', style: GoogleFonts.cairo(color: AppTheme.redVF.withOpacity(0.7), fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
