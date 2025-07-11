import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/loading_modal.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Mostrar modal de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingModal(message: 'Iniciando sesión...'),
    );

    try {
      final success = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context); // Cerrar modal
        
        if (success) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          _showErrorSnackBar('Error al iniciar sesión. Verifica tus credenciales.');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar modal
        _showErrorSnackBar('Error de conexión. Inténtalo nuevamente.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                // Logo
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    width: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.location_city,
                          color: AppColors.white,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Título
                const Center(
                  child: Text(
                    'CITIZEN',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // Campo de correo
                CustomTextField(
                  hintText: 'usuario@dominio.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El correo electrónico es requerido';
                    }
                    if (!_authService.validateEmail(value.trim())) {
                      return 'Ingresa un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Campo de contraseña
                CustomTextField(
                  hintText: 'Contraseña',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La contraseña es requerida';
                    }
                    if (!_authService.validatePassword(value.trim())) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.visibility_off, color: AppColors.grey),
                    onPressed: () {
                      // Implementar mostrar/ocultar contraseña
                    },
                  ),
                ),
                const SizedBox(height: 32),
                // Botón Ingresar
                CustomButton(
                  text: 'INGRESAR',
                  onPressed: _isLoading ? null : _login,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                // Botón Registrarse
                CustomButton(
                  text: 'REGISTRARSE',
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  isOutlined: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 