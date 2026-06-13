import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/card_model.dart';
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
                  filled: true,
                  fillColor: AppTheme.darkCard,
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
              Container(width: 46, height: 46,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: AppTheme.redVF.withOpacity(0.12),
                  border: Border.all(color: AppTheme.redVF.withOpacity(0.3), width: 1.5)),
                padding: const EdgeInsets.all(8),
                child: Image.asset('assets/images/Vodafone.png',
                  errorBuilder: (_, __, ___) => const Icon(Icons.signal_cellular_alt, color: AppTheme.redVF, size: 22))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(card.name, style: GoogleFonts.cairo(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.bolt, color: AppTheme.gold, size: 12),
                    const SizedBox(width: 3),
                    Text(card.units, style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 11)),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, color: Colors.blueAccent, size: 12),
                    const SizedBox(width: 3),
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
