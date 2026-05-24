import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/license_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});
  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final _keyCtrl = TextEditingController();
  bool _loading = false;
  String? _errorMsg;

  Future<void> _activate() async {
    final key = _keyCtrl.text.trim().toUpperCase();
    if (key.isEmpty) {
      setState(() => _errorMsg = 'ادخل المفتاح أولاً');
      return;
    }

    setState(() { _loading = true; _errorMsg = null; });

    final result = await LicenseService.validateKey(key);

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const HomeScreen(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      setState(() => _errorMsg = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Stack(
        children: [
          // خلفية توهج
          Positioned(top: -80, left: -80,
            child: Container(width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.redVF.withOpacity(0.15), Colors.transparent])))),
          Positioned(bottom: -100, right: -80,
            child: Container(width: 350, height: 350,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.darkRed.withOpacity(0.12), Colors.transparent])))),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // أيقونة قفل
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [AppTheme.redVF.withOpacity(0.2), Colors.transparent],
                      ),
                      border: Border.all(color: AppTheme.redVF.withOpacity(0.4), width: 2),
                      boxShadow: [BoxShadow(color: AppTheme.redVF.withOpacity(0.2), blurRadius: 30, spreadRadius: 5)],
                    ),
                    child: const Icon(Icons.lock_rounded, color: AppTheme.redVF, size: 56),
                  ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),

                  const SizedBox(height: 32),

                  Text('𝐂𝐚𝐫𝐝 𝐕𝐨𝐝𝐚𝐟𝐨𝐧𝐞',
                    style: GoogleFonts.cairo(
                      fontSize: 28, fontWeight: FontWeight.w900,
                      foreground: Paint()..shader = const LinearGradient(
                        colors: [AppTheme.redVF, Color(0xFFFF6B6B), AppTheme.gold],
                      ).createShader(const Rect.fromLTWH(0, 0, 280, 40)),
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 8),

                  Text('Team Mero',
                    style: GoogleFonts.cairo(color: AppTheme.gold, fontSize: 14, letterSpacing: 3, fontWeight: FontWeight.w700),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 40),

                  // بطاقة الإدخال
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A0000), Color(0xFF0D0D0D)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.redVF.withOpacity(0.3), width: 1.5),
                      boxShadow: [BoxShadow(color: AppTheme.redVF.withOpacity(0.1), blurRadius: 20, spreadRadius: 2)],
                    ),
                    child: Column(
                      children: [
                        Text('ادخل مفتاح التفعيل',
                          style: GoogleFonts.cairo(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.bold)),

                        const SizedBox(height: 6),

                        Text('كل مفتاح خاص بجهاز واحد فقط',
                          style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 12)),

                        const SizedBox(height: 20),

                        // حقل الإدخال
                        TextField(
                          controller: _keyCtrl,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.robotoMono(
                            color: AppTheme.gold, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 3,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'XXXX-XXXX-XXXX',
                            hintStyle: GoogleFonts.robotoMono(color: AppTheme.grey, letterSpacing: 2),
                            filled: true,
                            fillColor: AppTheme.black,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                            prefixIcon: const Icon(Icons.vpn_key_rounded, color: AppTheme.gold),
                          ),
                        ),

                        if (_errorMsg != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.4)),
                            ),
                            child: Text(_errorMsg!,
                              style: GoogleFonts.cairo(color: Colors.redAccent, fontSize: 13),
                              textAlign: TextAlign.center),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // زر التفعيل
                        SizedBox(
                          width: double.infinity, height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: EdgeInsets.zero,
                            ),
                            onPressed: _loading ? null : _activate,
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: _loading
                                    ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                                    : const LinearGradient(colors: [AppTheme.redVF, AppTheme.darkRed]),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: AppTheme.redVF.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 6))],
                              ),
                              child: Center(
                                child: _loading
                                    ? const SizedBox(width: 24, height: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        const Icon(Icons.lock_open_rounded, color: Colors.white, size: 20),
                                        const SizedBox(width: 10),
                                        Text('تفعيل', style: GoogleFonts.cairo(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                                      ]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  Text('By developer Alaa',
                    style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
