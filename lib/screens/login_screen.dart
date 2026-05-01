import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _primary = Color(0xFF8C0011);
  static const Color _primaryContainer = Color(0xFFB01E23);
  static const Color _secondary = Color(0xFF3B6934);
  static const Color _surface = Color(0xFFFCF9F8);
  static const Color _surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceTint = Color(0xFFB62326);
  static const Color _onBackground = Color(0xFF1B1C1C);
  static const Color _onSurfaceVariant = Color(0xFF5A403E);
  static const Color _outline = Color(0xFF8E706D);
  static const Color _outlineVariant = Color(0xFFE3BEBB);

  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.login(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 40,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 80,
                      ),
                      child: Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _buildLoginCard(context),
                            Positioned(
                              right: -18,
                              bottom: -22,
                              child: _buildHarvestAccent(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      color: _surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          const Icon(
            Icons.settings_rounded,
            color: _primaryContainer,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hệ thống Phân loại Trái cây',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.1,
                color: _onBackground,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardPadding = width < 380 ? 24.0 : 32.0;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 448),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: _onSurfaceVariant.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: EdgeInsets.all(cardPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeaderCopy(),
            const SizedBox(height: 36),
            if (_errorMessage != null) ...[
              _buildErrorBanner(_errorMessage!),
              const SizedBox(height: 20),
            ],
            _buildLabel('Username or Email'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _identifierController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.inter(color: _onBackground),
              decoration: _inputDecoration(hintText: 'operator@agritech.com'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Vui lòng nhập thông tin' : null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildLabel('MẬT KHẨU')),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: _primary,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Quên mật khẩu?',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _isLoading ? null : _handleLogin(),
              style: GoogleFonts.inter(color: _onBackground),
              decoration: _inputDecoration(
                hintText: '••••••••',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 21,
                    color: _onSurfaceVariant,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
            ),
            const SizedBox(height: 32),
            _buildLoginButton(),
            const SizedBox(height: 28),
            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chào mừng quay trở lại',
          style: GoogleFonts.manrope(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.12,
            color: _onBackground,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Truy cập bảng điều khiển phân loại để theo dõi các chỉ số thu hoạch của bạn.',
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.55,
            color: _onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: _onSurfaceVariant,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(color: _outlineVariant),
      filled: true,
      fillColor: _surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: _surfaceTint, width: 2),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFF93000A), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: const Color(0xFF93000A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_primary, _primaryContainer],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Đăng nhập',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.login_rounded, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Chưa có tài khoản?',
          style: GoogleFonts.inter(fontSize: 14, color: _onSurfaceVariant),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/register'),
          style: TextButton.styleFrom(
            foregroundColor: _primary,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Đăng ký',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.underline,
              decorationColor: _primary.withValues(alpha: 0.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHarvestAccent() {
    return IgnorePointer(
      child: Transform.rotate(
        angle: 0.1,
        child: Opacity(
          opacity: 0.92,
          child: Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8A002A), Color(0xFF3B6934)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _onSurfaceVariant.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 18,
                  top: 18,
                  child: Icon(
                    Icons.spa_rounded,
                    color: Colors.white.withValues(alpha: 0.62),
                    size: 42,
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: 18,
                  child: Icon(
                    Icons.grain_rounded,
                    color: Colors.white.withValues(alpha: 0.56),
                    size: 44,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Text(
        '© 2024 AGRITECH ATELIER PRECISION OPTICS',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          color: _outline,
        ),
      ),
    );
  }
}
