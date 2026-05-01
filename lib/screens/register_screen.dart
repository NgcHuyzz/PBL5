import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color _primary = Color(0xFF8C0011);
  static const Color _primaryContainer = Color(0xFFB01E23);
  static const Color _secondary = Color(0xFF3B6934);
  static const Color _surface = Color(0xFFFCF9F8);
  static const Color _surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceTint = Color(0xFFB62326);
  static const Color _onBackground = Color(0xFF1B1C1C);
  static const Color _onSurfaceVariant = Color(0xFF5A403E);
  static const Color _outlineVariant = Color(0xFFE3BEBB);

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      // ✅ Register สำเร็จ
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
            content: const Text('Đăng ký thành công!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('Đăng nhập ngay'),
              ),
            ],
          ),
        );
      }
    } else {
      // ❌ Register ล้มเหลว
      String errorMessage = result['message'];

      // แปลง error code เป็นภาษาเวียดนาม
      if (result['errorCode'] == 'DUPLICATE_USERNAME') {
        errorMessage = 'Tên đăng nhập đã tồn tại';
      } else if (result['errorCode'] == 'DUPLICATE_EMAIL') {
        errorMessage = 'Email đã được sử dụng';
      }

      setState(() {
        _errorMessage = errorMessage;
      });
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
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 64,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildIdentity(),
                            const SizedBox(height: 28),
                            _buildRegisterCard(context),
                            const SizedBox(height: 32),
                            _buildDecorativeCaption(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      color: _surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: _primaryContainer,
            tooltip: 'Quay lại đăng nhập',
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Hệ thống Phân loại Trái cây',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.12,
                color: _primaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentity() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _primaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _onSurfaceVariant.withValues(alpha: 0.08),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          'Create account',
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.12,
            color: _onBackground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Join PBL5 Fruit Sorter to start intelligent classification today.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w500,
            color: _onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterCard(BuildContext context) {
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
            Text(
              'Tạo tài khoản mới',
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _onBackground,
              ),
            ),
            const SizedBox(height: 28),
            if (_errorMessage != null) ...[
              _buildErrorBanner(_errorMessage!),
              const SizedBox(height: 20),
            ],
            _buildLabel('Họ và tên'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fullNameController,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.inter(color: _onBackground),
              decoration: _inputDecoration(hintText: 'Nguyễn Văn A'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập họ tên';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildLabel('Tên đăng nhập'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.inter(color: _onBackground),
              decoration: _inputDecoration(hintText: 'nguyenvana123'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên đăng nhập';
                }
                if (value.length < 3) {
                  return 'Tên đăng nhập ít nhất 3 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildLabel('Email'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.inter(color: _onBackground),
              decoration: _inputDecoration(hintText: 'operator@agritech.com'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Email không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildLabel('Mật khẩu'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.inter(color: _onBackground),
              decoration: _inputDecoration(
                hintText: '••••••••',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                if (value.length < 6) {
                  return 'Mật khẩu ít nhất 6 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildLabel('Xác nhận mật khẩu'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _isLoading ? null : _handleRegister(),
              style: GoogleFonts.inter(color: _onBackground),
              decoration: _inputDecoration(
                hintText: '••••••••',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _onSurfaceVariant,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu';
                }
                if (value != _passwordController.text) {
                  return 'Mật khẩu không khớp';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            _buildRegisterButton(),
            const SizedBox(height: 28),
            _buildLoginLink(),
          ],
        ),
      ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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

  Widget _buildRegisterButton() {
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
          onPressed: _isLoading ? null : _handleRegister,
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
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Đăng ký',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.how_to_reg_rounded, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _outlineVariant.withValues(alpha: 0.45)),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Đã có tài khoản?',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _onSurfaceVariant,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: _primary,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Đăng nhập',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
                decorationColor: _primary.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeCaption() {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.42,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primaryContainer, _secondary],
                ),
              ),
              child: const Icon(Icons.spa_rounded, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Container(width: 42, height: 1, color: _onSurfaceVariant),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                'INDUSTRIAL HORTICULTURAL PRECISION',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: _onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
