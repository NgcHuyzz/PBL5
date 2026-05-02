import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../utils/app_sizes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _primary = Color(0xFF8C0011);
  static const Color _primaryContainer = Color(0xFFB01E23);
  static const Color _surface = Color(0xFFFCF9F8);
  static const Color _surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceTint = Color(0xFFB62326);
  static const Color _onBackground = Color(0xFF1B1C1C);
  static const Color _onSurfaceVariant = Color(0xFF5A403E);
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
                      horizontal: AppSizes.spacingXXL,
                      vertical: 32.0,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingXXL,
        vertical: AppSizes.spacingL,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.settings_rounded,
            color: _primaryContainer,
            size: AppSizes.iconMedium,
          ),
          const SizedBox(width: AppSizes.spacingM),
          Expanded(
            child: Text(
              'Hệ thống Phân loại Trái cây',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: AppSizes.fontHeadlineMedium,
                fontWeight: FontWeight.w800,
                height: 1.1,
                color: _onBackground,
              ),
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardPadding = width < 380 ? AppSizes.spacingXXL : 26.0;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 448),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
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
            const SizedBox(height: 30),
            if (_errorMessage != null) ...[
              _buildErrorBanner(_errorMessage!),
              const SizedBox(height: AppSizes.spacingXL),
            ],
            const SizedBox.shrink(),
            const SizedBox(height: AppSizes.spacingXS),
            TextFormField(
              controller: _identifierController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.inter(color: _onBackground),
              decoration: _inputDecoration(hintText: ''),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Vui lòng nhập thông tin' : null,
            ),
            const SizedBox(height: AppSizes.spacingXXL),
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
                      fontSize: AppSizes.fontCaption,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingXS),
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
                    size: AppSizes.iconMedium,
                    color: _onSurfaceVariant,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
            ),
            const SizedBox(height: 26),
            _buildLoginButton(),
            const SizedBox(height: AppSizes.spacingXXL),
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
            fontSize: AppSizes.fontDisplaySmall,
            fontWeight: FontWeight.w800,
            height: 1.12,
            color: _onBackground,
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        Text(
          'Truy cập bảng điều khiển phân loại để theo dõi các chỉ số thu hoạch của bạn.',
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontBody,
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
        fontSize: AppSizes.fontCaption,
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingL,
        vertical: AppSizes.spacingM,
      ),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        borderSide: BorderSide.none,
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: _surfaceTint, width: 2),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppSizes.radiusS),
        ),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppSizes.radiusS),
        ),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppSizes.radiusS),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD6),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFF93000A),
            size: AppSizes.iconSmall,
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: const Color(0xFF93000A),
                fontSize: AppSizes.fontCaption,
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
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_primary, _primaryContainer],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
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
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
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
                        fontSize: AppSizes.fontTitleLarge,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingS),
                    const Icon(Icons.login_rounded, size: AppSizes.iconSmall),
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
          style: GoogleFonts.inter(
            fontSize: AppSizes.fontBody,
            color: _onSurfaceVariant,
          ),
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
              fontSize: AppSizes.fontBody,
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
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
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
                    size: 34,
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: 18,
                  child: Icon(
                    Icons.grain_rounded,
                    color: Colors.white.withValues(alpha: 0.56),
                    size: 35,
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
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.spacingXXL,
        AppSizes.spacingS,
        AppSizes.spacingXXL,
        AppSizes.spacingXXL,
      ),
      child: SizedBox(height: AppSizes.fontCaption),
    );
  }
}
