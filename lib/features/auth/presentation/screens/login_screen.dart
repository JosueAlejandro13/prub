import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../providers/auth_provider.dart';

/// Pantalla de acceso por número celular con verificación simulada y token recordado
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController(text: '1234');
  final _formKey = GlobalKey<FormState>();

  bool _codeSent = false;
  bool _isSendingCode = false;
  bool _rememberSession = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// Simula el envío del código SMS tras validar el número telefónico
  void _sendVerificationCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      AppSnackBar.showError(context, 'Por favor ingresa tu número de celular.');
      return;
    }
    if (phone.length < 8) {
      AppSnackBar.showError(context, 'El número debe tener al menos 8 dígitos.');
      return;
    }

    setState(() => _isSendingCode = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      _isSendingCode = false;
      _codeSent = true;
    });

    AppSnackBar.showInfo(context, 'Código de verificación enviado por SMS: 1234');
  }

  /// Inicia sesión con el token criptográfico y preferencia de persistencia
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();

    final success = await ref.read(authNotifierProvider.notifier).login(
          phone,
          code,
          remember: _rememberSession,
        );
    if (!success && mounted) {
      AppSnackBar.showError(context, 'No fue posible autenticar el investigador.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor(context),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.borderColor(context), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '🛸',
                          style: TextStyle(fontSize: 46),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Rick & Morty',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explorer App',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.subtextColor(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Número de celular',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textColor(context),
                        ),
                      ),
                      if (_codeSent)
                        InkWell(
                          onTap: () => setState(() => _codeSent = false),
                          child: Text(
                            'Cambiar número',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.portalGreen : AppTheme.primaryDark,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      readOnly: _codeSent,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                        color: AppTheme.textColor(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        icon: Icon(
                          _codeSent ? Icons.check_circle : Icons.phone_android,
                          color: AppTheme.primaryGreen,
                          size: 22,
                        ),
                        hintText: 'Ingresa tu número de celular',
                        hintStyle: TextStyle(
                          color: AppTheme.subtextColor(context),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Ingresa tu número de celular';
                        }
                        if (val.trim().length < 8) {
                          return 'Mínimo 8 dígitos requeridos';
                        }
                        return null;
                      },
                    ),
                  ),
                  if (_codeSent) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Código de verificación',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textColor(context),
                          ),
                        ),
                        InkWell(
                          onTap: _isSendingCode ? null : _sendVerificationCode,
                          child: Text(
                            _isSendingCode ? 'Enviando...' : 'Reenviar código',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.portalGreen : AppTheme.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: TextStyle(
                          color: AppTheme.textColor(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 4.0,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          isDense: true,
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          icon: Icon(
                            Icons.sms_outlined,
                            color: isDark ? AppTheme.portalGreen : AppTheme.primaryGreen,
                            size: 22,
                          ),
                          hintText: '1234',
                          hintStyle: TextStyle(
                            color: AppTheme.subtextColor(context),
                            fontSize: 15,
                            letterSpacing: 4.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Ingresa el código de verificación';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberSession,
                          activeColor: AppTheme.primaryGreen,
                          onChanged: (val) => setState(() => _rememberSession = val ?? true),
                        ),
                        Expanded(
                          child: Text(
                            'Recordar sesión en este dispositivo',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: (authState.isLoading || _isSendingCode)
                        ? null
                        : () {
                            if (!_codeSent) {
                              _sendVerificationCode();
                            } else {
                              _submit();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.35),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: (_isSendingCode || authState.isLoading)
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _codeSent ? 'INICIAR SESIÓN' : 'VERIFICAR NÚMERO',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 0.4,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
