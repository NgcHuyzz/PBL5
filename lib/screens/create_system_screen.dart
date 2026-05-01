import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/system_service.dart';

class CreateSystemScreen extends StatefulWidget {
  const CreateSystemScreen({super.key});

  @override
  State<CreateSystemScreen> createState() => _CreateSystemScreenState();
}

class _CreateSystemScreenState extends State<CreateSystemScreen> {
  static const Color _primary = Color(0xFF8C0011);
  static const Color _primaryContainer = Color(0xFFB01E23);
  static const Color _secondary = Color(0xFF3B6934);
  static const Color _surface = Color(0xFFFCF9F8);
  static const Color _surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceTint = Color(0xFFB62326);
  static const Color _onSurfaceVariant = Color(0xFF5A403E);
  static const Color _outline = Color(0xFF8E706D);

  final _formKey = GlobalKey<FormState>();
  final _systemIdController = TextEditingController();
  final _systemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _systemIdController.dispose();
    _systemNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await SystemService.createSystem(
      systemId: _systemIdController.text.trim(),
      systemName: _systemNameController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      Navigator.pop(
        context,
        result['message']?.toString() ?? 'Tạo hệ thống thành công',
      );
      return;
    }

    setState(() {
      _errorMessage = result['message']?.toString() ?? 'Tạo hệ thống thất bại';
    });
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
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 36),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 64,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: Column(
                            children: [
                              _buildVisualAccent(),
                              const SizedBox(height: 56),
                              _buildFormCard(),
                            ],
                          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          IconButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            color: _primary,
            iconSize: 32,
            tooltip: 'Quay lại',
          ),
          Expanded(
            child: Text(
              'Tạo hệ thống',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: _primary,
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildVisualAccent() {
    return Container(
      width: double.infinity,
      height: 132,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _onSurfaceVariant.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuB8gWATfnfonjd7SxXqyEXmDy6wPrbfPeoFMrpwfznP3xu1SpMct-yCDdK8MdBycs6b_xwf7zNSX3DS53mf_L7b-f925P0n_LH8Usp0Rh06XK1zhqpEHfAzmNPV3EID70OicJvMmDonB5F2IZl5Z-IbT2OSXNk92QkK0r-jueI_LDuFV5a9IwWyOvxgB2edovtr9v_S3KWTDeRNifPZfVKk7CTJdirDZm_CQvaHGtR6jnpQ1U4lGu3U2aCFSi_1mCM0SAR2Ir3KC2KG',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    _primary.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(42, 42, 42, 34),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              _buildErrorBanner(_errorMessage!),
              const SizedBox(height: 28),
            ],
            _buildLabel('ID hệ thống'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _systemIdController,
              textInputAction: TextInputAction.next,
              style: _fieldTextStyle(),
              decoration: _inputDecoration(hintText: 'SYS-B-2024-001'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập ID hệ thống';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Nhập ID hệ thống đã được thiết bị đăng ký trước đó',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: _onSurfaceVariant.withValues(alpha: 0.72),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildLabel('Tên hệ thống'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _systemNameController,
              textInputAction: TextInputAction.next,
              style: _fieldTextStyle(),
              decoration: _inputDecoration(
                hintText: 'Ví dụ: Berry Conveyor 01',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên hệ thống';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            _buildLabel('Địa điểm'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _locationController,
              textInputAction: TextInputAction.next,
              style: _fieldTextStyle(),
              decoration: _inputDecoration(
                hintText: 'Ví dụ: Khu A - Xưởng đóng gói',
                prefixIcon: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFB6AEAE),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập địa điểm';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            _buildLabel('Mô tả'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descriptionController,
              minLines: 4,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              style: _fieldTextStyle(),
              decoration: _inputDecoration(
                hintText: 'Thông tin chi tiết về hệ thống giám sát...',
              ),
            ),
            const SizedBox(height: 42),
            _buildSubmitButton(),
            const SizedBox(height: 28),
            Text(
              'AGRITECH ATELIER PRECISION TOOLS V2.0',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: _outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: _onSurfaceVariant,
      ),
    );
  }

  TextStyle _fieldTextStyle() {
    return GoogleFonts.inter(fontSize: 20, color: const Color(0xFF6B7280));
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        fontSize: 20,
        color: const Color(0xFF737B8B),
      ),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: _surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
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
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 72,
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
              color: _primary.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Tạo hệ thống',
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}
