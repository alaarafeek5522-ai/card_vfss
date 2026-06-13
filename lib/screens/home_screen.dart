import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/card_model.dart';
import '../services/vodafone_service.dart';
import '../services/balance_service.dart';
import '../theme/app_theme.dart';
import 'charge_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<CardModel> _cards = CardModel.getAll();
  String _search = '';

  List<CardModel> get _filtered => _cards
      .where((c) => c.name.contains(_search) || c.netCharge.contains(_search))
      .toList();

  void _showBalanceDialog(BuildContext context) {
    final pinCtrl = TextEditingController();
    bool loading = false;
    bool pinVisible = false;
    String? balance;
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A0A00), Color(0xFF0D0D0D)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.gold.withOpacity(0.4), width: 1.5),
              boxShadow: [BoxShadow(color: AppTheme.gold.withOpacity(0.15), blurRadius: 30, spreadRadius: 3)],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // أيقونة العين
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.gold.withOpacity(0.15),
                      border: Border.all(color: AppTheme.gold.withOpacity(0.4), width: 1.5),
                      boxShadow: [BoxShadow(color: AppTheme.gold.withOpacity(0.2), blurRadius: 20, spreadRadius: 3)],
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.gold, size: 40),
                  ),

                  const SizedBox(height: 16),

                  Text('استعلام عن الرصيد',
                    style: GoogleFonts.cairo(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.w900)),

                  const SizedBox(height: 6),

                  Text('ادخل الرقم السري لمحفظتك',
                    style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 13)),

                  const SizedBox(height: 16),

                  Container(height: 1,
                    decoration: BoxDecoration(gradient: LinearGradient(
                      colors: [Colors.transparent, AppTheme.gold.withOpacity(0.4), Colors.transparent]))),

                  const SizedBox(height: 16),

                  // لو في رصيد يعرضه
                  if (balance != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                      ),
                      child: Column(children: [
                        Text('رصيد محفظتك',
                          style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 13)),
                        const SizedBox(height: 8),
                        Text('$balance جنيه',
                          style: GoogleFonts.cairo(color: AppTheme.gold, fontSize: 28, fontWeight: FontWeight.w900)),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.darkCard,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('إغلاق', style: GoogleFonts.cairo(color: AppTheme.white, fontWeight: FontWeight.bold)),
                      )),
                  ] else ...[
                    TextField(
                      controller: pinCtrl,
                      keyboardType: TextInputType.number,
                      obscureText: !pinVisible,
                      style: GoogleFonts.cairo(color: AppTheme.white, fontSize: 18, letterSpacing: 4),
                      decoration: InputDecoration(
                        hintText: '••••••',
                        hintStyle: GoogleFonts.cairo(color: AppTheme.grey),
                        filled: true,
                        fillColor: AppTheme.black,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppTheme.gold, width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(pinVisible ? Icons.visibility_off : Icons.visibility, color: AppTheme.grey),
                          onPressed: () => setS(() => pinVisible = !pinVisible),
                        ),
                      ),
                    ),

                    if (error != null) ...[
                      const SizedBox(height: 10),
                      Text(error!, style: GoogleFonts.cairo(color: Colors.redAccent, fontSize: 13),
                        textAlign: TextAlign.center),
                    ],

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: EdgeInsets.zero),
                        onPressed: loading ? null : () async {
                          if (pinCtrl.text.isEmpty) return;
                          setS(() { loading = true; error = null; });
                          try {
                            final isVF = await VodafoneService.isVodafoneNetwork();
                            if (!isVF) {
                              setS(() { error = "يجب استخدام داتا فودافون للاستعلام عن الرصيد"; loading = false; });
                              return;
                            }
                            final seamless = await VodafoneService.getSeamlessData();
                            final seamlessToken = seamless['seamlessToken'];
                            final msisdn = seamless['msisdn']?.toString() ?? '';
                            final token = await VodafoneService.getAccessToken(seamlessToken);
                            if (token == null) throw Exception('فشل الاتصال');
                            final result = await BalanceService.getBalance(
                              number: msisdn, pin: pinCtrl.text.trim(), token: token);
                            if (result != null) {
                              final match = RegExp(r'[\d.]+').firstMatch(result);
                              setS(() { balance = match?.group(0) ?? result; loading = false; });
                            } else {
                              setS(() { error = 'تعذر الحصول على الرصيد'; loading = false; });
                            }
                          } catch (e) {
                            setS(() { error = 'خطأ في الاتصال'; loading = false; });
                          }
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: loading
                                ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                                : const LinearGradient(colors: [AppTheme.gold, Color(0xFFB8860B)]),
                            borderRadius: BorderRadius.circular(14)),
                          child: Center(
                            child: loading
                                ? const SizedBox(width: 24, height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    const Icon(Icons.visibility_rounded, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text('استعلام', style: GoogleFonts.cairo(color: Colors.white,
                                        fontSize: 16, fontWeight: FontWeight.bold)),
                                  ]),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.black,
            flexibleSpace: FlexibleSpaceBar(
              background: _AppBarBg(),
              title: Text('Card Vodafone',
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900,
                  foreground: Paint()..shader = const LinearGradient(
                    colors: [AppTheme.redVF, AppTheme.gold],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 30)))),
              centerTitle: true,
            ),
            actions: [
              // زرار الرصيد
              GestureDetector(
                onTap: () => _showBalanceDialog(context),
                child: Container(
                  margin: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.gold, Color(0xFFB8860B)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppTheme.gold.withOpacity(0.3), blurRadius: 8)],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.remove_red_eye_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text('الرصيد', style: GoogleFonts.cairo(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.history_rounded, color: AppTheme.white),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.telegram_rounded, color: AppTheme.gold),
                onPressed: () => launchUrl(Uri.parse('https://t.me/X_marawan_X'),
                    mode: LaunchMode.externalApplication),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: GoogleFonts.cairo(color: AppTheme.white),
                decoration: InputDecoration(
                  hintText: 'ابحث عن باقة...',
                  hintStyle: GoogleFonts.cairo(color: AppTheme.grey),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.grey),
                  filled: true, fillColor: AppTheme.darkCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.redVF, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text('الباقات المتاحة',
                style: GoogleFonts.cairo(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _CardTile(card: _filtered[i], index: i)
                    .animate()
                    .fadeIn(delay: (i * 40).ms, duration: 300.ms)
                    .slideX(begin: 0.1),
                childCount: _filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBarBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0000), AppTheme.black])),
      child: Stack(children: [
        Positioned(top: -30, right: -30,
          child: Container(width: 200, height: 200,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppTheme.redVF.withOpacity(0.2), Colors.transparent])))),
      ]),
    );
  }
}

class _CardTile extends StatelessWidget {
  final CardModel card;
  final int index;
  const _CardTile({required this.card, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ChargeScreen(card: card))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.cardBg, Color(0xFF1A0A0A)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.redVF.withOpacity(0.2), width: 1),
          boxShadow: [BoxShadow(color: AppTheme.redVF.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // أيقونة الكارت
              Container(width: 46, height: 46,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                  color: AppTheme.redVF.withOpacity(0.12),
                  border: Border.all(color: AppTheme.redVF.withOpacity(0.3), width: 1.5)),
                padding: const EdgeInsets.all(6),
                child: Image.asset('assets/images/card.jpg',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset('assets/images/Vodafone.png',
                    errorBuilder: (_, __, ___) => const Icon(Icons.credit_card, color: AppTheme.redVF, size: 22)))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(card.name, style: GoogleFonts.cairo(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.bolt, color: AppTheme.gold, size: 12), const SizedBox(width: 3),
                    Text(card.units, style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 11)),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, color: Colors.blueAccent, size: 12), const SizedBox(width: 3),
                    Text(card.duration, style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 11)),
                  ]),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.redVF, AppTheme.darkRed]),
                  borderRadius: BorderRadius.circular(12)),
                child: Text('${card.netCharge} ج',
                  style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.grey, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
