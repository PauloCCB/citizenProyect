import 'dart:convert';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  // Inicializar usuario desde storage
  Future<void> initializeUser() async {
    try {
      final userData = await StorageService.getUserData();
      if (userData != null) {
        _currentUser = UserModel.fromJson(json.decode(userData));
      }
    } catch (e) {
      // Si hay error al cargar datos, limpiar storage
      await StorageService.clearAll();
    }
  }

  // Login con API
  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response['success'] == true) {
        _currentUser = UserModel.fromJson(response);

        // Guardar token y datos del usuario
        if (_currentUser!.token != null) {
          await StorageService.saveToken(_currentUser!.token!);
          await StorageService.saveUserData(
            json.encode(_currentUser!.toJson()),
          );
        }

        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Registro con API
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      final response = await ApiService.post('/auth/register', {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumer': phoneNumber, // API usa phoneNumer
        'isActive': true,
      });

      if (response['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await StorageService.clearAll();
      _currentUser = null;
    } catch (e) {
      // Aún así limpiar el usuario local
      _currentUser = null;
    }
  }

  // Verificar si el token es válido
  Future<bool> isTokenValid() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      // Hacer una llamada simple para verificar el token
      await ApiService.get(
        '/incidencia',
        requiresAuth: true,
        queryParams: {'limit': '1'},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Validaciones
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
