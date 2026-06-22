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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

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
            decoration: AppTheme.glassCard(borderColor: AppTheme.gold),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                            final result = await BalanceService.getBalance(pin: pinCtrl.text.trim());
                            if (result.success) {
                              setS(() { balance = result.balance; loading = false; });
                            } else {
                              setS(() { error = result.message ?? "تعذر الحصول على الرصيد"; loading = false; });
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
              title: _ShimmerTitle(),
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900,
                  foreground: Paint()..shader = const LinearGradient(
                    colors: [AppTheme.redVF, AppTheme.gold],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 30)))),
              centerTitle: true,
            ),
            actions: [
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
                    _SlideRoute(page: const HistoryScreen())),
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

          if (_isLoading)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _SkeletonCard(),
                  childCount: 6,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _CardTile(card: _filtered[i], index: i)
                      .animate()
                      .fadeIn(delay: (i * 20).ms, duration: 250.ms)
                      .scale(begin: const Offset(0.9, 0.9)),
                  childCount: _filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.redVF.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10))),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 80, height: 12,
                  decoration: BoxDecoration(color: AppTheme.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 6),
                Container(width: 50, height: 10,
                  decoration: BoxDecoration(color: AppTheme.grey.withOpacity(0.15), borderRadius: BorderRadius.circular(6))),
              ]),
              Container(width: double.infinity, height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.redVF.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10))),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBarBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F0000), Color(0xFF0D0000), AppTheme.black])),
      child: Stack(children: [
        Positioned(top: -30, right: -30,
          child: Container(width: 200, height: 200,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppTheme.redVF.withOpacity(0.25), Colors.transparent])))),
        Positioned(bottom: 0, left: -20,
          child: Container(width: 150, height: 150,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppTheme.gold.withOpacity(0.08), Colors.transparent])))),
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
          _SlideRoute(page: ChargeScreen(card: card))),
      child: Container(
        decoration: AppTheme.glassCard(),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.redVF.withOpacity(0.12),
                  border: Border.all(color: AppTheme.redVF.withOpacity(0.3), width: 1.5)),
                padding: const EdgeInsets.all(6),
                child: Image.asset('assets/images/card.jpg',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset('assets/images/Vodafone.png',
                    errorBuilder: (_, __, ___) => const Icon(Icons.credit_card, color: AppTheme.redVF, size: 22))),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(card.name,
                  style: GoogleFonts.cairo(color: AppTheme.white, fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.bolt, color: AppTheme.gold, size: 11),
                  const SizedBox(width: 2),
                  Expanded(child: Text(card.units,
                    style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 10),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ]),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.redVF, AppTheme.darkRed]),
                  borderRadius: BorderRadius.circular(10)),
                child: Text('${card.netCharge} ج',
                  style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  textAlign: TextAlign.center)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideRoute extends PageRouteBuilder {
  final Widget page;
  _SlideRoute({required this.page}) : super(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final slide = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      final fade = Tween(begin: 0.0, end: 1.0)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));
      return SlideTransition(position: slide,
        child: FadeTransition(opacity: fade, child: child));
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

class _ShimmerTitle extends StatefulWidget {
  @override
  State<_ShimmerTitle> createState() => _ShimmerTitleState();
}

class _ShimmerTitleState extends State<_ShimmerTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: const [AppTheme.redVF, AppTheme.gold, Colors.white, AppTheme.gold, AppTheme.redVF],
          stops: [
            0.0,
            (_ctrl.value - 0.1).clamp(0.0, 1.0),
            _ctrl.value.clamp(0.0, 1.0),
            (_ctrl.value + 0.1).clamp(0.0, 1.0),
            1.0,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds),
        child: Text('Card Vodafone',
          style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
      ),
    );
  }
}
