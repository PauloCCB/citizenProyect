import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  static const String baseUrl =
      'https://citizen-api-production.up.railway.app/api';

  // Headers básicos
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers con token
  static Future<Map<String, String>> get _headersWithToken async {
    final token = await StorageService.getToken();
    final headers = Map<String, String>.from(_headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Método genérico para POST
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = requiresAuth ? await _headersWithToken : _headers;

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Método genérico para GET
  static Future<dynamic> get(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, String>? queryParams,
  }) async {
    try {
      var url = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null) {
        url = url.replace(queryParameters: queryParams);
      }

      final headers = requiresAuth ? await _headersWithToken : _headers;

      final response = await http.get(url, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Método para multipart (upload de archivos)
  static Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    File file, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', url);

      // Agregar token si es necesario
      if (requiresAuth) {
        final token = await StorageService.getToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      // Agregar archivo
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Manejo de respuestas HTTP
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final responseBody = response.body;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseBody.isEmpty) {
        return {'success': true};
      }

      try {
        final decoded = json.decode(responseBody);
        if (decoded is List) {
          return {'success': true, 'data': decoded};
        } else {
          return {'success': true, ...decoded};
        }
      } catch (e) {
        return {'success': true, 'data': responseBody};
      }
    } else {
      try {
        final errorData = json.decode(responseBody);
        final errorMessage = errorData['message'] ?? 'Error desconocido';
        throw Exception(errorMessage);
      } catch (e) {
        if (response.statusCode == 401) {
          throw Exception('Token inválido o expirado');
        } else if (response.statusCode == 400) {
          throw Exception('Datos inválidos');
        } else if (response.statusCode == 500) {
          throw Exception('Error del servidor');
        } else {
          throw Exception('Error HTTP ${response.statusCode}');
        }
      }
    }
  }
}
