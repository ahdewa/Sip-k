import 'package:flutter/material.dart';
import 'package:simodis_jatim/screens/home_screen.dart';
import 'package:simodis_jatim/widgets/app_loading_widgets.dart';
import 'package:simodis_jatim/services/api_service.dart';
import 'package:simodis_jatim/services/api_config.dart';
import 'package:simodis_jatim/services/fcm_service.dart';
import 'package:simodis_jatim/services/url_launcher_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordObscured = true;
  bool _isLoading = false;

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final identifier = _identifierController.text.trim();
      final password = _passwordController.text;

      // 1. Coba login ke REST API Laravel terlebih dahulu
      try {
        final apiResult = await ApiService.login(
          loginInput: identifier,
          password: password,
          fcmToken: FcmService.currentToken,
        );

        if (apiResult != null && mounted) {
          // Sinkronisasi token FCM ke backend untuk user yang aktif
          FcmService.syncTokenWithBackend();
          final roleRaw = (apiResult['role'] ?? 'pegawai').toString();
          final targetRole = roleRaw == 'pegawai' ? 'user' : roleRaw;
          final roleLabel = targetRole == 'superadmin'
              ? 'Superadministrator Pusat'
              : (targetRole == 'admin'
                  ? 'Kasubag Tata Usaha & Aset'
                  : 'Pegawai / Pemohon');
          _showLoginSuccessLoading(targetRole, roleLabel);
          return;
        }
      } catch (_) {}

      // 2. Fallback jika offline atau quick-fill demo lokal
      String? targetRole;
      String roleLabel = '';
      final lowerId = identifier.toLowerCase();

      if ((lowerId == 'superadmin' ||
              lowerId == '197001011990031001' ||
              lowerId == 'superadmin@dinsos.jatimprov.go.id' ||
              lowerId == 'administrator@dinsos.jatimprov.go.id') &&
          (password == 'password' || password == 'superadmin123')) {
        targetRole = 'superadmin';
        roleLabel = 'Superadministrator Pusat';
      } else if ((lowerId == 'admin' ||
              lowerId == '197805122005011004' ||
              lowerId == '198501012010011001' ||
              lowerId == 'admin@dinsos.jatimprov.go.id') &&
          (password == 'password' || password == 'admin123')) {
        targetRole = 'admin';
        roleLabel = 'Kasubag Tata Usaha & Aset';
      } else if ((lowerId == 'pegawai' ||
              lowerId == 'user' ||
              lowerId == '199503152020121002' ||
              lowerId == 'rendy@dinsos.jatimprov.go.id') &&
          (password == 'password' || password == 'password123')) {
        targetRole = 'user';
        roleLabel = 'Pegawai / Pemohon';
      }

      if (targetRole != null && mounted) {
        _showLoginSuccessLoading(targetRole, roleLabel);
      } else if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFDC2626),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('NIP/Email atau Password salah!'),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  void _showLoginSuccessLoading(String targetRole, String roleLabel) {
    LoginSuccessDialog.show(context, roleLabel: roleLabel);

    Future.delayed(const Duration(milliseconds: 950), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context, rootNavigator: true).pop(); // Tutup loading dialog

      HomeScreen.resetPermissionSession();
      _navigateToHome(targetRole);
    });
  }

  void _navigateToHome(String targetRole) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(role: targetRole),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
      (route) => false,
    );
  }


  Future<void> _launchWhatsAppHelpdesk() async {
    final phoneNumber = ApiConfig.helpdeskWhatsappNumber;
    final message = ApiConfig.helpdeskWhatsappMessage;
    try {
      final success = await launchWhatsAppUrl(
        phoneNumber: phoneNumber,
        message: message,
      );
      if (!success && mounted) {
        final telSuccess = await launchCustomUrl('tel:$phoneNumber');
        if (!telSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tidak dapat membuka WhatsApp. Silakan hubungi ${ApiConfig.helpdeskWhatsappDisplay}.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showContactAdminDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFEBF3FC),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent_rounded, color: Color(0xFF2B5B9E), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Bantuan Akun & Lupa Sandi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kartu WhatsApp Bantuan Lupa Sandi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lock_reset_rounded, color: Color(0xFF2E7D32), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Lupa Kata Sandi?',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Silakan hubungi Admin Kasubag / Pengelola Aset Dinsos untuk verifikasi dan reset kata sandi akun Anda.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF2E3E33), height: 1.35),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone_android_rounded, size: 14, color: Color(0xFF2E7D32)),
                          SizedBox(width: 4),
                          Text(
                            '${ApiConfig.helpdeskWhatsappDisplay} (Admin Kasubag)',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _launchWhatsAppHelpdesk,
                        icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                        label: const Text(
                          'Hubungi Admin via WhatsApp',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B5B9E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24487A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/logo_sipk.png',
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: const Icon(
                              Icons.directions_car_rounded,
                              size: 40,
                              color: Color(0xFF2B5B9E),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'LOGIN MASUK',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),

                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'OVBS ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2B5B9E),
                            ),
                          ),
                          TextSpan(
                            text: 'DINSOS JATIM',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Username / NIP',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _identifierController,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        if (_passwordController.text.isNotEmpty && !_isLoading) {
                          _handleLogin();
                        } else {
                          FocusScope.of(context).requestFocus(_passwordFocusNode);
                        }
                      },
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText: 'Masukkan NIP atau Email dinas',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.person, size: 20, color: Color(0xFF94A3B8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2B5B9E), width: 1.5),
                        ),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_isLoading) {
                          _handleLogin();
                        }
                      },
                      obscureText: _isPasswordObscured,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText: 'Masukkan password',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.lock, size: 20, color: Color(0xFF94A3B8)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 20,
                            color: const Color(0xFF94A3B8),
                          ),
                          onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2B5B9E), width: 1.5),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Password wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B5B9E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Masuk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.login_rounded, size: 18),
                              ],
                            ),
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: GestureDetector(
                        onTap: _showContactAdminDialog,
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            children: [
                              TextSpan(text: 'Kendala saat login? '),
                              TextSpan(
                                text: 'Bantuan Akun',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),

                    const Text(
                      'Dinas Sosial Provinsi Jawa Timur',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}