import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import '../services/vodafone_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  String _status = 'جاري التحميل...';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 1500), _startChecks);
  }

  Future<void> _startChecks() async {
    setState(() => _status = 'جاري تحميل الإعدادات...');
    final config = await VodafoneService.fetchRemoteConfig();

    if (config['stopped'] == true) {
      _showStoppedDialog(config['stopped_message'] ?? 'التطبيق متوقف مؤقتاً');
      return;
    }

    if (config['force_update'] == true) {
      _showUpdateDialog(
        config['update_message'] ?? 'يوجد تحديث جديد',
        config['update_url'] ?? '',
        config['update_version'] ?? '',
        config['update_features'] ?? '',
      );
      return;
    }

    setState(() => _status = 'جاهز...');
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const HomeScreen(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _showStoppedDialog(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FancyDialog(
        icon: Icons.block_rounded,
        iconColor: Colors.red,
        gradientColors: const [Color(0xFF1A0000), Color(0xFF0D0D0D)],
        borderColor: Colors.red,
        title: 'التطبيق متوقف',
        message: msg,
        actions: [
          _FancyButton(
            label: 'خروج',
            gradient: const LinearGradient(colors: [Colors.red, Color(0xFF8B0000)]),
            onTap: () => SystemNavigator.pop(),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(String msg, String url, String version, String features) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FancyDialog(
        icon: Icons.system_update_rounded,
        iconColor: AppTheme.gold,
        gradientColors: const [Color(0xFF1A1500), Color(0xFF0D0D0D)],
        borderColor: AppTheme.gold,
        title: 'تحديث جديد ${version.isNotEmpty ? "v$version" : ""}',
        message: msg,
        features: features,
        actions: [
          _FancyButton(
            label: '⬇️  تحديث الآن',
            gradient: const LinearGradient(
              colors: [AppTheme.gold, Color(0xFFB8860B)],
            ),
            onTap: () async {
              if (url.isNotEmpty) {
                await launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Stack(
        children: [
          Positioned.fill(child: _GlowBackground()),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (_, __) => CustomPaint(
                    painter: _OrbitPainter(_rotateController.value),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) {
                        final scale = 1.0 + _pulseController.value * 0.06;
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [Color(0xFF2A0A0A), AppTheme.black],
                              ),
                              border: Border.all(
                                color: AppTheme.redVF.withOpacity(0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.redVF.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Image.asset(
                                'assets/images/Vodafone.png',
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.signal_cellular_alt,
                                  color: AppTheme.redVF,
                                  size: 70,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  '𝐂𝐚𝐫𝐝 𝐕𝐨𝐝𝐚𝐟𝐨𝐧𝐞',
                  style: GoogleFonts.cairo(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [AppTheme.redVF, Color(0xFFFF6B6B), AppTheme.gold],
                      ).createShader(const Rect.fromLTWH(0, 0, 300, 50)),
                    letterSpacing: 1.5,
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),

                const SizedBox(height: 8),

                Text(
                  'Team Mero',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gold,
                    letterSpacing: 3,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                const SizedBox(height: 4),

                Text(
                  'By developer Alaa',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppTheme.grey,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

                const SizedBox(height: 60),

                SizedBox(
                  width: 200,
                  child: Column(
                    children: [
                      Text(
                        _status,
                        style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: const LinearProgressIndicator(
                          backgroundColor: AppTheme.darkCard,
                          valueColor: AlwaysStoppedAnimation(AppTheme.redVF),
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========== Dialog فخم ==========
class _FancyDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final List<Color> gradientColors;
  final Color borderColor;
  final String title;
  final String message;
  final String? features;
  final List<Widget> actions;

  const _FancyDialog({
    required this.icon,
    required this.iconColor,
    required this.gradientColors,
    required this.borderColor,
    required this.title,
    required this.message,
    this.features,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة مع توهج
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withOpacity(0.15),
                  border: Border.all(color: iconColor.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 44),
              ),

              const SizedBox(height: 20),

              // العنوان
              Text(
                title,
                style: GoogleFonts.cairo(
                  color: AppTheme.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // فاصل
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      borderColor.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // الرسالة
              Text(
                message,
                style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),

              // المميزات لو موجودة
              if (features != null && features!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: iconColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    features!,
                    style: GoogleFonts.cairo(
                      color: iconColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 20),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}

class _FancyButton extends StatelessWidget {
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const _FancyButton({required this.label, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: EdgeInsets.zero,
          ),
          onPressed: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ========== Orbit Painter ==========
class _OrbitPainter extends CustomPainter {
  final double progress;
  _OrbitPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = cx + 18;
    final paintDash = Paint()
      ..color = AppTheme.redVF.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), r, paintDash);
    for (int i = 0; i < 3; i++) {
      final angle = 2 * pi * (progress + i / 3);
      final dx = cx + r * cos(angle);
      final dy = cy + r * sin(angle);
      final alpha = (1.0 - (i / 3)) * 255;
      final paintDot = Paint()
        ..color = AppTheme.redVF.withOpacity(alpha / 255)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dx, dy), 5 - i * 1.2, paintDot);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.progress != progress;
}

// ========== Glow Background ==========
class _GlowBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        top: -80, left: -80,
        child: Container(
          width: 300, height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [AppTheme.redVF.withOpacity(0.15), Colors.transparent],
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -100, right: -80,
        child: Container(
          width: 350, height: 350,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [AppTheme.darkRed.withOpacity(0.12), Colors.transparent],
            ),
          ),
        ),
      ),
    ]);
  }
}
