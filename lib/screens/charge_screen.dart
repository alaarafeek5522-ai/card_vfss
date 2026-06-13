import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/card_model.dart';
import '../services/vodafone_service.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';

class ChargeScreen extends StatefulWidget {
  final CardModel card;
  const ChargeScreen({super.key, required this.card});
  @override
  State<ChargeScreen> createState() => _ChargeScreenState();
}

class _ChargeScreenState extends State<ChargeScreen> {
  final _receiverCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _loading = false;
  bool _pinVisible = false;
  String? _resultMsg;
  bool? _success;
  String? _lastReceiver;

  @override
  void initState() {
    super.initState();
    _loadLastReceiver();
  }

  Future<void> _loadLastReceiver() async {
    final last = await HistoryService.getLastReceiver();
    setState(() => _lastReceiver = last);
  }

  Future<void> _pickContact() async {
    final status = await Permission.contacts.request();
    if (!status.isGranted) return;
    try {
      final contact = await FlutterContacts.openExternalPick();
      if (contact == null) return;
      final full = await FlutterContacts.getContact(contact.id);
      final phone = full?.phones.firstOrNull?.number
          .replaceAll(RegExp(r'\s|-|\+20'), '')
          .trim();
      if (phone != null && phone.isNotEmpty) {
        final normalized = phone.startsWith('0') ? phone : '0$phone';
        setState(() => _receiverCtrl.text = normalized);
      }
    } catch (_) {}
  }

  Future<void> _charge() async {
    final receiver = _receiverCtrl.text.trim();
    final pin = _pinCtrl.text.trim();

    if (!receiver.startsWith('01') || receiver.length != 11) {
      _showSnack('رقم الهاتف غير صحيح');
      return;
    }
    if (pin.isEmpty) {
      _showSnack('ادخل الرقم السري');
      return;
    }

    setState(() { _loading = true; _resultMsg = null; _success = null; });

    final isVF = await VodafoneService.isVodafoneNetwork();
    if (!isVF) {
      setState(() => _loading = false);
      _showNetworkDialog();
      return;
    }

    try {
      final seamless = await VodafoneService.getSeamlessData();
      final seamlessToken = seamless['seamlessToken'];
      final senderMsisdn = seamless['msisdn']?.toString() ?? '';

      if (seamlessToken == null) throw Exception('فشل تسجيل الدخول - تأكد من داتا فودافون');

      final accessToken = await VodafoneService.getAccessToken(seamlessToken);
      if (accessToken == null) throw Exception('فشل الحصول على token');

      final result = await VodafoneService.chargeCard(
        productId: widget.card.productId,
        receiver: receiver,
        pin: pin,
        senderMsisdn: senderMsisdn,
        accessToken: accessToken,
      );

      final ok = result['state'] == 'Completed' || result['complete'] == true;

      // حفظ في السجل
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';
      await HistoryService.addRecord(ChargeHistory(
        cardName: widget.card.name,
        cardPrice: widget.card.netCharge,
        receiver: receiver,
        date: dateStr,
        success: ok,
      ));

      setState(() {
        _success = ok;
        _resultMsg = ok ? '✅ تم الشحن بنجاح!' : (result['message'] ?? '❌ فشل الشحن');
        if (ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(
                'تم شحن ${widget.card.name} للرقم $receiver بنجاح! 🎉',
                style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
              )),
            ]),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
          ));
        }
        if (ok) _lastReceiver = receiver;
      });
    } catch (e) {
      await HistoryService.addRecord(ChargeHistory(
        cardName: widget.card.name,
        cardPrice: widget.card.netCharge,
        receiver: receiver,
        date: DateTime.now().toString().substring(0, 16),
        success: false,
      ));
      setState(() { _success = false; _resultMsg = '❌ ${e.toString()}'; });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showNetworkDialog() {
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
              Container(padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.orange.withOpacity(0.15)),
                child: const Icon(Icons.signal_cellular_off_rounded, color: Colors.orange, size: 40)),
              const SizedBox(height: 16),
              Text('شبكة غير مدعومة', style: GoogleFonts.cairo(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('التطبيق يعمل فقط على داتا فودافون\nتأكد أنك متصل بداتا فودافون وليس واي فاي',
                style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 14), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.redVF,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () => Navigator.pop(context),
                  child: Text('حسناً', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                )),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.cairo()),
      backgroundColor: AppTheme.darkRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(card.name, style: GoogleFonts.cairo(color: AppTheme.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _CardDetails(card: card)
                .animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

            const SizedBox(height: 28),

            _SectionLabel(label: 'رقم المستلم'),
            const SizedBox(height: 8),
            TextField(
              controller: _receiverCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 11,
              style: GoogleFonts.cairo(color: AppTheme.white, fontSize: 18, letterSpacing: 2),
              decoration: _inputDec(
                hint: '01XXXXXXXXX',
                suffix: IconButton(
                  icon: const Icon(Icons.contacts_rounded, color: AppTheme.gold),
                  onPressed: _pickContact,
                ),
              ),
            ),

            // آخر رقم شحنت له
            if (_lastReceiver != null) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => setState(() => _receiverCtrl.text = _lastReceiver!),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.redVF.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.history_rounded, color: AppTheme.redVF, size: 16),
                    const SizedBox(width: 8),
                    Text('آخر رقم: $_lastReceiver',
                      style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 13)),
                    const Spacer(),
                    Text('اضغط للاستخدام',
                      style: GoogleFonts.cairo(color: AppTheme.redVF, fontSize: 11)),
                  ]),
                ),
              ),
            ],

            const SizedBox(height: 16),

            _SectionLabel(label: 'الرقم السري للمحفظة'),
            const SizedBox(height: 8),
            TextField(
              controller: _pinCtrl,
              keyboardType: TextInputType.number,
              obscureText: !_pinVisible,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.cairo(color: AppTheme.white, fontSize: 18, letterSpacing: 4),
              decoration: _inputDec(
                hint: '••••••',
                suffix: IconButton(
                  icon: Icon(_pinVisible ? Icons.visibility_off : Icons.visibility, color: AppTheme.grey),
                  onPressed: () => setState(() => _pinVisible = !_pinVisible),
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: EdgeInsets.zero,
                ),
                onPressed: _loading ? null : _charge,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: _loading
                        ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                        : const LinearGradient(colors: [AppTheme.redVF, AppTheme.darkRed],
                            begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: AppTheme.redVF.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 6))],
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(width: 26, height: 26,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text('إرسال الكارت',
                              style: GoogleFonts.cairo(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                          ]),
                  ),
                ),
              ),
            ),

            if (_resultMsg != null) ...[
              const SizedBox(height: 24),
              _ResultCard(message: _resultMsg!, success: _success ?? false)
                  .animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDec({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.cairo(color: AppTheme.grey),
      filled: true,
      fillColor: AppTheme.darkCard,
      counterStyle: const TextStyle(color: AppTheme.grey),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.redVF, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    );
  }
}

class _CardDetails extends StatelessWidget {
  final CardModel card;
  const _CardDetails({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A0000), Color(0xFF0D0D0D)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.redVF.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: AppTheme.redVF.withOpacity(0.1), blurRadius: 20, spreadRadius: 2)],
      ),
      child: Row(
        children: [
          Container(width: 60, height: 60,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppTheme.redVF.withOpacity(0.15),
              border: Border.all(color: AppTheme.redVF.withOpacity(0.4), width: 1.5)),
            padding: const EdgeInsets.all(10),
            child: Image.asset('assets/images/Vodafone.png',
              errorBuilder: (_, __, ___) => const Icon(Icons.signal_cellular_alt, color: AppTheme.redVF, size: 28))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(card.name, style: GoogleFonts.cairo(color: AppTheme.white, fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Row(children: [Icon(Icons.bolt, color: AppTheme.gold, size: 14), const SizedBox(width: 4),
                Text(card.units, style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 12))]),
              Row(children: [Icon(Icons.access_time, color: Colors.blueAccent, size: 14), const SizedBox(width: 4),
                Text(card.duration, style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 12))]),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.redVF, AppTheme.darkRed]),
              borderRadius: BorderRadius.circular(14)),
            child: Text('${card.netCharge}\nجنيه',
              style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: Text(label, style: GoogleFonts.cairo(color: AppTheme.white, fontSize: 14, fontWeight: FontWeight.w600)));
}

class _ResultCard extends StatelessWidget {
  final String message;
  final bool success;
  const _ResultCard({required this.message, required this.success});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: success ? Colors.green.withOpacity(0.1) : AppTheme.darkRed.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: success ? Colors.green.withOpacity(0.5) : AppTheme.redVF.withOpacity(0.5), width: 1.5)),
      child: Text(message,
        style: GoogleFonts.cairo(color: success ? Colors.greenAccent : Colors.redAccent,
            fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center));
  }
}
