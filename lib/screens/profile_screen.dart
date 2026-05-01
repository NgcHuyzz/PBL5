import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

const Color _primary = Color(0xFF8C0011);
const Color _primaryContainer = Color(0xFFB01E23);
const Color _surface = Color(0xFFFCF9F8);
const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
const Color _surfaceContainerLow = Color(0xFFF6F3F2);
const Color _surfaceVariant = Color(0xFFE5E2E1);
const Color _onSurface = Color(0xFF1B1C1C);
const Color _onSurfaceVariant = Color(0xFF5A403E);
const Color _outlineVariant = Color(0xFFE3BEBB);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _hasAccountStatus = false;
  String? _errorMessage;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.getCurrentUser();
    if (!mounted) return;

    if (result['success'] == true) {
      final data = _asMap(result['data']);
      setState(() {
        _user = User.fromJson(data);
        _hasAccountStatus = _stringValue(data['status']).isNotEmpty;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Không thể tải thông tin cá nhân';
        _hasAccountStatus = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.removeToken();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final displayName = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName.trim()
        : 'Người dùng';
    final username = user?.username.trim().isNotEmpty == true
        ? user!.username.trim()
        : '---';
    final email = user?.email.trim().isNotEmpty == true
        ? user!.email.trim()
        : '---';
    final status = user?.status.trim().isNotEmpty == true
        ? user!.status.trim()
        : '---';

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 72,
        leadingWidth: 72,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          color: _primaryContainer,
          tooltip: 'Quay lại',
        ),
        titleSpacing: 0,
        title: Text(
          'Thông tin cá nhân',
          style: GoogleFonts.manrope(
            color: _onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUser,
        color: _primary,
        child: _isLoading
            ? const _LoadingView()
            : _ProfileContent(
                displayName: displayName,
                username: username,
                email: email,
                status: status,
                showStatus: _hasAccountStatus,
                errorMessage: _errorMessage,
                onRetry: _loadUser,
                onLogout: _logout,
              ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 260),
        Center(child: CircularProgressIndicator(color: _primary)),
      ],
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final String displayName;
  final String username;
  final String email;
  final String status;
  final bool showStatus;
  final String? errorMessage;
  final Future<void> Function() onRetry;
  final VoidCallback onLogout;

  const _ProfileContent({
    required this.displayName,
    required this.username,
    required this.email,
    required this.status,
    required this.showStatus,
    required this.errorMessage,
    required this.onRetry,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 720 ? 32.0 : 28.0;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            76,
            horizontalPadding,
            56,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileHeader(displayName: displayName),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 20),
                      _ErrorBanner(message: errorMessage!, onRetry: onRetry),
                    ],
                    const SizedBox(height: 58),
                    _SectionLabel(text: 'CHI TIẾT TÀI KHOẢN'),
                    const SizedBox(height: 28),
                    _InfoPanel(
                      children: [
                        _InfoRow(
                          icon: Icons.alternate_email_rounded,
                          label: 'USERNAME',
                          value: username,
                        ),
                        _InfoRow(
                          icon: Icons.mail_rounded,
                          label: 'EMAIL',
                          value: email,
                        ),
                        _InfoRow(
                          icon: Icons.badge_rounded,
                          label: 'HỌ VÀ TÊN',
                          value: displayName,
                        ),
                        if (showStatus)
                          _InfoRow(
                            icon: Icons.verified_user_rounded,
                            label: 'TRẠNG THÁI',
                            value: status,
                          ),
                      ],
                    ),
                    const SizedBox(height: 84),
                    _LogoutButton(onPressed: onLogout),
                    const SizedBox(height: 46),
                    Text(
                      'AGRITECH ATELIER V2.4.0 • FACTORY CONTROL SYSTEM',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: _onSurfaceVariant.withValues(alpha: 0.42),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String displayName;

  const _ProfileHeader({required this.displayName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 56),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _outlineVariant.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: _onSurfaceVariant.withValues(alpha: 0.06),
            blurRadius: 42,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Column(
        children: [
          const _Avatar(),
          const SizedBox(height: 54),
          Text(
            displayName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: _onSurface,
              fontSize: 34,
              height: 1.08,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 226,
      height: 226,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 220,
              height: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF33434E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFFF6F3F2),
                  size: 132,
                ),
              ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: 0,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _primaryContainer,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: _onSurfaceVariant.withValues(alpha: 0.62),
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final List<Widget> children;

  const _InfoPanel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              Container(
                height: 2,
                color: _surfaceVariant.withValues(alpha: 0.7),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 36, 28, 36),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: _surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primary, size: 34),
          ),
          const SizedBox(width: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: _onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: GoogleFonts.inter(
                    color: _onSurface,
                    fontSize: 24,
                    height: 1.18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_primary, _primaryContainer],
          ),
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.16),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.logout_rounded, size: 34),
          label: Text(
            'Đăng xuất',
            style: GoogleFonts.manrope(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFF93000A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: const Color(0xFF93000A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: () => onRetry(),
            icon: const Icon(Icons.refresh_rounded),
            color: const Color(0xFF93000A),
            tooltip: 'Tải lại',
          ),
        ],
      ),
    );
  }
}

Map<String, dynamic> _asMap(Object? data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {};
}

String _stringValue(Object? value) {
  return value?.toString().trim() ?? '';
}
