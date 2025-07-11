import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String email, String password) async {
    try {
      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulación de login exitoso
      _currentUser = UserModel(
        id: '1',
        email: email,
        name: 'Usuario',
        lastName: 'Demo',
        phoneNumber: '+51 123456789',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulación de registro exitoso
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  Future<bool> resetPassword(String email) async {
    try {
      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      return false;
    }
  }

  bool validateEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool validatePassword(String password) {
    return password.length >= 6;
  }

  String? validatePhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return 'El número de teléfono es requerido';
    }
    if (phoneNumber.length < 9) {
      return 'El número de teléfono debe tener al menos 9 dígitos';
    }
    return null;
  }

  String? validateName(String name) {
    if (name.isEmpty) {
      return 'El nombre es requerido';
    }
    if (name.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }
} 