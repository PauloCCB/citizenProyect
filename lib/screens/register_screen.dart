import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/loading_modal.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Mostrar modal de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingModal(message: 'Registrando usuario...'),
    );

    try {
      final success = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context); // Cerrar modal
        
        if (success) {
          _showSuccessSnackBar('Registro exitoso. Ya puedes iniciar sesión.');
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          _showErrorSnackBar('Error al registrar usuario. Inténtalo nuevamente.');
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('appCitizen'),
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Campo de correo electrónico
                CustomTextField(
                  hintText: 'Correo electrónico',
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
                ),
                const SizedBox(height: 16),
                // Campo de nombre
                CustomTextField(
                  hintText: 'Nombre',
                  controller: _nameController,
                  validator: (value) {
                    return _authService.validateName(value?.trim() ?? '');
                  },
                ),
                const SizedBox(height: 16),
                // Campo de apellido
                CustomTextField(
                  hintText: 'Apellido',
                  controller: _lastNameController,
                  validator: (value) {
                    return _authService.validateName(value?.trim() ?? '');
                  },
                ),
                const SizedBox(height: 16),
                // Campo de número de teléfono
                CustomTextField(
                  hintText: 'Número de teléfono',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    return _authService.validatePhoneNumber(value?.trim() ?? '');
                  },
                ),
                const SizedBox(height: 32),
                // Botón Registrarse
                CustomButton(
                  text: 'REGISTRARSE',
                  onPressed: _isLoading ? null : _register,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                // Enlace a login
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      '¿Ya tienes cuenta? Inicia sesión',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 